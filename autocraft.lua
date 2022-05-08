function read()
	return io.read()
end

robotInventorySize = 16
chestsCount = 3
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

function calculateNeedCountOfMaterialToCraftItem(needCountOfItem, receivedCountOfItem, needCountOfMaterialPerOneCraft)
	return needCountOfItem * needCountOfMaterialPerOneCraft / receivedCountOfItem
end

function calculateNeedMaterialsToCraftItem(craftableItem, recipes)
	local needMaterials = {} -- (itemName, itemCount)
	local craftableItemRecipe = findRecipe(craftableItem.itemName, recipes)
	
	if not craftableItemRecipe then
		return nil -- по хорошему надо бросать эксцепшен
	end
	
	for i = 1, #craftableItemRecipe.materials do
		needMaterials[i] = {}
		needMaterials[i].itemName = craftableItemRecipe.materials[i].itemName
		needMaterials[i].itemCount = calculateNeedCountOfMaterialToCraftItem(craftableItem.itemCount, craftableItemRecipe.receivedCount, craftableItemRecipe.materials[i].needCount)
	end
	
	return needMaterials
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
	-- needItems = {itemName, itemCount} -- items, that can be crafted
	-- needMaterials = {itemName, itemCount} -- items, that can't be crafted, they are shood be applyed from a user
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
				equalEndItemAdd(needItems, {itemName = materialRecipe.itemName, itemCount = calculateNeedCountOfMaterialToCraftItem(needItems[i].itemCount, itemRecipe.receivedCount,  material.needCount)})-- needItems[i].itemCount * material.needCount / itemRecipe.receivedCount})
				oneTimeItemAdd(needRecipes, materialRecipe)
			else
				equalItemAdd(needMaterials, {itemName = material.itemName, itemCount = calculateNeedCountOfMaterialToCraftItem(needItems[i].itemCount, itemRecipe.receivedCount, material.needCount)})-- needItems[i].itemCount * material.needCount / itemRecipe.receivedCount})
			end
		end

		i = i + 1
	end
	return needItems, needMaterials, needRecipes
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

function getItemStackSize(itemName, itemsStacks)--in table itemStack you shood write only those items that itemStackSize is not equal to 64
	return itemsStacks[itemName] or 64
end

function addVirtualItemToSlot(addableItem, inventory, slotToAdd, itemsStacks)
	if (inventory[slotToAdd].itemName == addableItem.itemName) or (not inventory[slotToAdd].itemName) then
		inventory[slotToAdd].itemName = addableItem.itemName
		local remainingSpaceInSlot = getItemStackSize(addableItem.itemName, itemsStacks) - inventory[slotToAdd].itemCount
		if addableItem.itemCount > remainingSpaceInSlot then-- the same code with the code that in "else", you shood fix this when you will refact this function
			if inventory.content[addableItem.itemName] then
				inventory.content[addableItem.itemName] = inventory.content[addableItem.itemName] + remainingSpaceInSlot
			else
				inventory.content[addableItem.itemName] = remainingSpaceInSlot
			end
			
			inventory[slotToAdd].itemCount = inventory[slotToAdd].itemCount + remainingSpaceInSlot
			addableItem.itemCount = addableItem.itemCount - remainingSpaceInSlot
		else
			if inventory.content[addableItem.itemName] then
				inventory.content[addableItem.itemName] = inventory.content[addableItem.itemName] + addableItem.itemCount
			else
				inventory.content[addableItem.itemName] = addableItem.itemCount
			end
			
			inventory[slotToAdd].itemCount = inventory[slotToAdd].itemCount + addableItem.itemCount
			addableItem.itemCount = 0
		end
	end
end

function deleteVirtualItemFromSlot(slotToDelete, inventory, deleteCount)
	local nameOfDeletableItem = inventory[slotToDelete].itemName
	if  nameOfDeletableItem then
		if deleteCount and deleteCount <= inventory[slotToDelete].itemCount then
			inventory[slotToDelete].itemCount = inventory[slotToDelete].itemCount - deleteCount
			inventory.content[nameOfDeletableItem] = inventory.content[nameOfDeletableItem] - deleteCount
		else
			inventory.content[nameOfDeletableItem] = inventory.content[nameOfDeletableItem] - inventory[slotToDelete].itemCount
			inventory[slotToDelete].itemCount = 0
		end
		
		if inventory.content[nameOfDeletableItem] < 0 then-- if the function work right, than this "if" does't need. But I haven't male all tests yet...
			exception("inposible(uncorrect function work):inventory.content[nameOfDeletableItem] < 0")
		end
		if inventory[slotToDelete].itemCount == 0 then
			inventory[slotToDelete].itemName = nil
			inventory[slotToDelete].itemCount = 0
		end
		
		if inventory.content[nameOfDeletableItem] < 0 then-- if the function work right, than this "if" does't need.  But I haven't make all tests yet...
			exception("inposible(uncorrect function work):inventory.content[nameOfDeletableItem] < 0")
		end
		if inventory.content[nameOfDeletableItem] == 0 then
			inventory.content[nameOfDeletableItem] = nil
		end
	end
end

function transferVirtualItemBetweenSlots(sourceSlot, sourceInventory, destinationSlot, destinationInventory, itemsStacks, count) -- untested
	local countOfItemsThatShouldBeTransferred = count or sourceInventory[sourceSlot].itemCount
	if sourceInventory[sourceSlot].itemCount < countOfItemsThatShouldBeTransferred then
		countOfItemsThatShouldBeTransferred = sourceInventory[sourceSlot].itemCount
	end
	
	local transferableItem = {itemName = sourceInventory[sourceSlot].itemName, itemCount = countOfItemsThatShouldBeTransferred}
	addVirtualItemToSlot(transferableItem, destinationInventory, destinationSlot, itemsStacks)
	
	deleteVirtualItemFromSlot(sourceSlot, sourceInventory, ((count or sourceInventory[sourceSlot].itemCount) - transferableItem.itemCount))
end

function addVirtualItemToInventory(addableItem, inventory, itemsStacks)
	local itemStackSize = getItemStackSize(addableItem.itemName, itemsStacks)
	
	while addableItem.itemCount > 0 do
		local slotToAddItem = findIf(inventory, function(slot) return slot.itemCount == 0 or (slot.itemName == addableItem.itemName and slot.itemCount < itemStackSize) end) -- ПО-ХУЙ -- unoptimised, but work :) LUA!!!
		
		if not slotToAddItem then
			break;
		end
		
		addVirtualItemToSlot(addableItem, inventory, slotToAddItem, itemsStacks)
	end
end

function deleteVirtualItemFromInventory(deletableItem, inventory)
	while deletableItem.itemCount > 0 do
		local slotToDeleteItem = findIf(inventory, function(slot) return slot.itemName == deletableItem.itemName end)
		
		if not slotToDeleteItem then
			break;
		end
		
		if deletableItem.itemCount > inventory[slotToDeleteItem].itemCount then
			deletableItem.itemCount = deletableItem.itemCount - inventory[slotToDeleteItem].itemCount
			deleteVirtualItemFromSlot(slotToDeleteItem, inventory)
		else
			deleteVirtualItemFromSlot(slotToDeleteItem, inventory, deletableItem.itemCount)
			deletableItem.itemCount = 0
		end
	end
end

function transferVirtualItemBetweenInventories(transferableItem, sourceInventory, destinationInventory, itemsStacks)
	transferableItemStack = getItemStackSize(transferableItem.itemName, itemsStacks)
	
	while transferableItem.itemCount > 0 do
		local slotFromWhichWeWillTransfer = findIf(sourceInventory, function(slot) return transferableItem.itemName == slot.itemName end)
		local sloToWhichWeWillTransfer = findIf(destinationInventory, function(slot) return slot.itemCount == 0 or (slot.itemName == transferableItem.itemName and slot.itemCount < transferableItemStack) end)
		
		if not slotFromWhichWeWillTransfer or not sloToWhichWeWillTransfer then
			break
		end
		
		local countOfItemsInSlotFromWhichWeWillTransferBeforeTransfer = sourceInventory[sloToWhichWeWillTransfer].itemCount
		
		transferVirtualItemBetweenSlots(slotFromWhichWeWillTransfer, sourceInventory, sloToWhichWeWillTransfer, destinationInventory, itemsStacks, transferableItem.itemCount)
		transferableItem.itemCount = transferableItem.itemCount - (countOfItemsInSlotFromWhichWeWillTransferBeforeTransfer - sourceInventory[slotFromWhichWeWillTransfer].itemCount)
	end
end

function pickUpMaterialsFromUser(needMaterials, chests, itemsStacks)
	local currentChest = 1
	local item
	local i = 1
	
	while i <= #needMaterials do
		if not item or item.itemCount == 0 then
			item = {itemName = needMaterials[i].itemName, itemCount = needMaterials[i].itemCount} -- yes, that realy need, we can't place needMaterials[i] to addVirtualItemToInventory, becouse in this case needMaterials[i] will change
		end
		
		addVirtualItemToInventory(item, chests[currentChest], itemsStacks)
		
		if not (item.itemCount == 0) then
			currentChest = currentChest + 1
			i = i - 1
			if currentChest > #chests then
				exception()
			end
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
	
	print("If you finish put items in chests, then press the enter")
	read()
end


function craftItems(craftableItems, recipes, robotInventory, chests, itemsStacks, craftStations, robot, inventoryController)
	for i = 1, #craftableItems do
		craftableItems[i].needMaterials = calculateNeedMaterialsToCraftItem(craftableItems[i], recipes)
	end
	
	local busyCraftStations = {}
	
	while #craftableItems > 0 do
		local indexOfCraftableItem = #craftableItems
		
		while indexOfCraftableItem > 0 do
			local craftableItem = craftableItems[indexOfCraftableItem]
			local placesOfMaterialsInChests = findItemsInInventories(craftableItem.needMaterials, chests)
			local craftableItemRecipe = findRecipe(craftableItem.itemName, recipes)
			local craftStation = findCraftStation(craftableItemRecipe.craftStationName, craftStations)
			
			if placesOfMaterialsInChests and craftStation.getRemainingInputSpace(craftStation, craftableItem) > 0 then
				craftStation.craft(craftStation, craftableItem, craftableItemRecipe, robot, inventoryController)
				busyCraftStations[#busyCraftStations] = craftStation
				
				if craftableItem.itemCount == 0 then
					table.remove(craftableItems, indexOfCraftableItem)
				else
					craftableItems[indexOfCraftableItem].itemCount = craftableItem.itemCount
				end
			
			end
			
			indexOfCraftableItem = indexOfCraftableItem - 1
			
			if indexOfCraftableItem == 0 then
				local i = 1
				while i <= #busyCraftStations do
					if busyCraftStations[i].checkIfCraftIsOver(busyCraftStations[i], robot) then
						 busyCraftStations[i].unload(busyCraftStations[i], chests, robot, inventoryController)
						 table.remove(busyCraftStations, i)
						 i = i - 1
					end
					i = i + 1
				end
			end
		end
		os.sleep(30)--temporary (all in this function temporary :( )
	end
end

function main()
	local recipes = getRecipes()
	local craftableItem = askUserAboutCreftableItem(recipes);
	local craftableItems, needMaterials, needRecipes = getNeedItemsAndMaterialsAndRecipes(craftableItem, recipes)
	
	local chests = getChests()
	local robotInventory = getRobotInventory()
	
	pickUpMaterialsFromUser(needMaterials, chests, {})
	--craftItems(craftableItems, recipes, robotInventory, chests, itemsStacks)
	--for i = 1, #craftableItems do
	--	print(craftableItems[i].itemName.." "..craftableItems[i].itemCount)
	--end
	
	local craftStation = 
	{
		craftStationName = "wire machine",
		x = 1, y = 0, z = 0,
		inventory,
		getRemainingInputSpace = function(this, item)
		
		
		end,
		craft = function(this, craftableItem, craftableItemRecipe, robot, inventoryController)
		
		
		end,
		checkIfCraftIsOver = function(this, robot)
		
		
		end,
		unload = function(this, chests, robot, inventoryController)
		
		
		end
	}
	
	
end

--main()

ch1 = getChests()[1]
ch2 = getChests()[2]

addVirtualItemToInventory({itemName = "popcorn", itemCount = 40}, ch1, {})

for i = 1, #ch1 do
	print(i.." "..tostring(ch1[i].itemName).."\t".. ch1[i].itemCount.."\t\t\t"..tostring(ch2[i].itemName).."\t".. ch2[i].itemCount)
end

--transferVirtualItemBetweenInventories({itemName = "popcorn", itemCount = 170}, ch1, ch2, {})
transferVirtualItemBetweenSlots(1, ch1, 1, ch2, {}, 50)

print()
print()

for i = 1, #ch1 do
	print(i.." "..tostring(ch1[i].itemName).."\t".. ch1[i].itemCount.."\t\t\t"..tostring(ch2[i].itemName).."\t".. ch2[i].itemCount)
end


-- craftableItem(itemName, itemCount)
-- recipe(itemName, receivedCount, craftStationName, recipe(...(itemName, needCount)...), materials(...(itemName, needCount)...))
-- itemsStacks(itemName = itemStackSize)
-- inventory(..(itemName, itemCount).., content(..(itemName = itemCount)..))
-- cords(x, y, z)
-- craftStation(craftStationName, x, y, z, inventory, function getRemainingInputSpace(this, item), function craft(this, craftableItem, craftableItemRecipe, robot, inventoryController), function checkIfCraftIsOver(this, robot) function unload(this, chests, robot, inventoryController))
--проверь короче в функцию на конкретную переменная ссылка даеться или значение
--и ище там если таблицу кидать в функцию то если в этой таблицу была переменная то она ссылка или нет