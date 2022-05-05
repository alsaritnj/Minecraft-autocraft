function read()
	return io.read()
end

robotInventorySize = 16
chestsCount = 1
chestSize = 27


function getRecipes()-- shood take data from file
	return
	{
		{itemName = "copper wire", receivedCount = 3, craftStationName = "wire machine", recipe = {{itemName = "copper ingot", needCount = 1}}, materials = {{itemName = "copper ingot", needCount = 1}}},
		{itemName = "iron plate", receivedCount = 1, craftStationName = "rolling machine", recipe = {{itemName = "iron ingot", needCount = 1}}, materials = {{itemName = "iron ingot", needCount = 1}}},
		{itemName = "copper insulated wire", receivedCount = 1, craftStationName = "workbench", recipe = {{itemName = "copper wire", needCount = 1}, {itemName = "rubber", needCount = 1}}, materials = {{itemName = "copper wire", needCount = 1}, {itemName = "rudder", needCount = 1}}},
		{itemName = "part circuit", receivedCount = 1, craftStationName = "workbench", recipe = {{itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "redstone", needCount = 1}, {itemName = "iron plate", needCount = 1}, {itemName = "redstone", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}}, materials = {{itemName = "copper insulated wire", needCount = 6}, {itemName = "redstone", needCount = 2}, {itemName = "iron plate", needCount = 1}}}
	}
end

function getRobotInventory()-- shood take data from file
	return createEmptyInventory(robotInventorySize)
end

function getChests()-- shood take data from file
	local chests = {}
	for i = 1, chestsCount do
		chests[i] = createEmptyInventory(chestSize)
		chests[i].x = 0
		chests[i].y = 0
		chests[i].z = 0
	end
	return chests	
end

function getItemStack()-- shood take data from file
	return {}
end

function findIf(array, pred)
	for i = 1, #array do
		if pred(array[i]) then
			return i
		end
	end
	return nil
end

function equalItemAdd(array, addableItem)
	local index = findIf(array, function(tableEl) return tableEl.itemName == addableItem.itemName end)
	if index then
		array[index].itemCount = array[index].itemCount + addableItem.itemCount
	else
		array[#array + 1] = addableItem
	end
end

function equalEndItemAdd(array, addableItem)
	local index = findIf(array, function(tableEl) return tableEl.itemName == addableItem.itemName end)
	array[#array + 1] = addableItem
	if index then
		array[#array].itemCount = array[#array].itemCount + array[index].itemCount
		table.remove(array, index)
	end
end

function oneTimeItemAdd(array, addableItem)
	local index = findIf(array, function(tableEl) return tableEl.itemName == addableItem.itemName end)
	if not index then
		array[#array+1] = addableItem
	end
end

function findRecipe(itemName, recipes)
	return findIf(recipes, function(tableEl) return tableEl.itemName == itemName end)
end

function askUserAboutCreftableItem(recipe)
	print("Write item name and quantity")
	item = {}

	::itemNameInput::
	item["itemName"] = read();
	if not findRecipe(item.itemName, recipe) then
		print("There is no recipe for the item you enter")
		goto itemNameInput
	end

	::itemCountInput::
	item["itemCount"] = tonumber(read());
	if(item.itemCount < 1) then
		print("The number of elements can't be less than one")
		goto itemCountInput
	end
	
	return item;
	
end

function getNeedItemsAndMaterialsAndRecipes(craftableItem, recipes)
	-- needItems = {itemName, needItemCount} -- items, that can be crafted
	-- needMaterials = {itemName, needItemCount} -- items, that can't be crafted, they are shood be applyed from a user
	local needItems = {}
	local needMaterials = {}
	local needRecipes = {}

	needItems[1] = craftableItem

	local i = 1
	while i <= #needItems do
		local itemRecipe = recipes[findRecipe(needItems[i].itemName, recipes)]
		oneTimeItemAdd(needRecipes, itemRecipe)
		for j = 1, #itemRecipe.materials do
			local material = itemRecipe.materials[j]
			local materialRecipe = recipes[findRecipe(material.itemName, recipes)]
			
			if materialRecipe then
				equalEndItemAdd(needItems, {itemName = materialRecipe.itemName, itemCount = needItems[i].itemCount * material.needCount / itemRecipe.receivedCount})
				oneTimeItemAdd(needRecipes, materialRecipe)
			else
				equalItemAdd(needMaterials, {itemName = material.itemName, itemCount = needItems[i].itemCount * material.needCount / itemRecipe.receivedCount})
			end
		end

		i = i + 1
	end
	return needItems, needMaterials, needRecipes
end


function getItemStackSize(itemName, itemsStacks)--in table itemStack you shood write only those items that itemStackSize is not equal to 64
	return itemsStacks[itemName] or 64
end

function addItemToSlot(addableItem, inventory, slotToAdd)
	inventory[slotToAdd] = addableItem
	
	if inventory.content[addableItem.itemName] then
		inventory.content[addableItem.itemName] = inventory.content[addableItem.itemName] + addableItem.itemCount
	else
		inventory.content[addableItem.itemName] = addableItem.itemCount
	end
end

function addItemToInventory(item, inventory, itemsStacks)
	local itemStackSize = getItemStackSize(item.itemName, itemsStacks)
	local inventoryChange = {}--(slot, itemName, itemCountChange)
	
	while item.itemCount > 0 do
		slotToAddItem = findIf(inventory, function(slot) return slot.itemCount == 0 or (slot.itemName == item.itemName and slot.itemCount < itemStackSize) end)
		
		if not slotToAddItem then
			break;
		end
		
		local remainingSpaceInSlot = itemStackSize - inventory[slotToAddItem].itemCount
		
		if item.itemCount > remainingSpaceInSlot then
			item.itemCount = item.itemCount - remainingSpaceInSlot
			addItemToSlot({itemName = item.itemName, itemCount = inventory[slotToAddItem].itemCount + remainingSpaceInSlot}, inventory, slotToAddItem)
			inventoryChange[#inventoryChange + 1] = {slot = slotToAddItem, itemName = item.itemName, itemCountChange = remainingSpaceInSlot}
		else
			addItemToSlot({itemName = item.itemName, itemCount = inventory[slotToAddItem].itemCount + item.itemCount}, inventory, slotToAddItem)
			inventoryChange[#inventoryChange + 1] = {slot = slotToAddItem, itemName = item.itemName, itemCountChange = item.itemCount}
			item.itemCount = 0			
		end
	end
	return inventoryChange
end

function pickUpMaterialsFromUser(needMaterials, chests, itemsStacks)
	
	
	local currentChest = 1
	local i = 1
	while i <= #needMaterials do
		item = {itemName = needMaterials[i].itemName, itemCount = needMaterials[i].itemCount} -- yes, that realy need, we can't place needMaterials[i] to addItemToInventory, becouse in this case needMaterials[i] will change
		addItemToInventory(item, chests[currentChest], itemsStacks)
		if not item.itemCount == 0 then
			currentChest = currentChest + 1
			break -- becouse we shood't need to increment i
		end
		
		i = i + 1
	end
	
	print("Put the next items into chests")
	for i = 1, #needMaterials do
		print(needMaterials[i].itemName.."\t"..needMaterials[i].itemCount)
	end

	print("Do you want to see how items shood lay in chests?(Y/N)")
	local input = read()
	if input == "y" or input == "Y" then
		for i = 1, #chests do
			print("Chest "..i)
			for j = 1, #chests[i] do
				print(j.." "..tostring(chests[i][j].itemName).."\t".. chests[i][j].itemCount)
			end
		end
	end
	
	print("If you finish put items in chests, then press enter")
end

function createEmptyInventory(size)
	local inventory = {content = {}}
	for i = 1, size do
			inventory[i] = {}
			inventory[i].itemName = nil
			inventory[i].itemCount = 0
	end
	return inventory
end

function main()
	local recipes = getRecipes()
	local craftableItem = askUserAboutCreftableItem(recipes);
	local needItems, needMaterials, needRecipes = getNeedItemsAndMaterialsAndRecipes(craftableItem, recipes)
	
	local chests = getChests()
	local robotInventory = getRobotInventory()
	
	pickUpMaterialsFromUser(needMaterials, chests)
	--craftItems(craftableItems, recipes, robotInventory, chestInventory, itemsStacks)
end

main()

-- craftableItem(itemName, itemCount)
-- recipe(itemName, receivedCount, craftStationName, recipe(...(itemName, needCount)...), materials(...(itemName, needCount)...))
-- itemsStacks(itemName = itemStackSize)
-- inventory(..(itemName, itemCount).., content(..(itemName = itemCount)..))
-- block(x, y, z)