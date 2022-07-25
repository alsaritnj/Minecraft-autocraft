function read()
	return io.read()
end

robotInventorySize = 16
chestsCount = 3
chestSize = 27

sides = {bottom = 0, top = 1, back = 2, front = 3, right = 4, left = 5} -- require("sides")

os =
{
	sleep = function(timeout)
		print("Sleep for "..timeout.." seconds")
	end
}

function getRecipes()-- shood take data from file
	return
	{
		{itemName = "copper wire", receivedCount = 3, craftStationName = "wire machine", recipe = {{itemName = "copper ingot", needCount = 1}}, materials = {{itemName = "copper ingot", needCount = 1}}},
		{itemName = "iron plate", receivedCount = 1, craftStationName = "rolling machine", recipe = {{itemName = "iron ingot", needCount = 1}}, materials = {{itemName = "iron ingot", needCount = 1}}},
		{itemName = "copper insulated wire", receivedCount = 1, craftStationName = "workbench", recipe = {{itemName = "copper wire", needCount = 1}, {itemName = "rubber", needCount = 1}}, materials = {{itemName = "copper wire", needCount = 1}, {itemName = "rudder", needCount = 1}}},
		{itemName = "part circuit", receivedCount = 1, craftStationName = "workbench", recipe = {{itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "redstone", needCount = 1}, {itemName = "iron plate", needCount = 1}, {itemName = "redstone", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}}, materials = {{itemName = "copper insulated wire", needCount = 6}, {itemName = "redstone", needCount = 2}, {itemName = "iron plate", needCount = 1}}},
		{itemName = "energy crystal", receivedCount = 1, craftStationName = "compressor", recipe = {{itemName = "energy dust", needCount = 9}}, materials = {{itemName = "energy dust", needCount = 9}}},
		{itemName = "stick", receivedCount = 4, craftStationName = "workbench", recipe = {{itemName = "wood", needCount = 1}, nil, nil, {itemName = "wood", needCount = 1}}, materials = {{itemName = "wood", needCount = 2}}}
	}
end

function getRobotInventory()-- shood take data from file
	return createEmptyInventory(robotInventorySize)
end

function getRobot()
	local robot = require("robot")
	robot.x = 0
	robot.y = 0
	robot.z = 0
	robot.face = sides.front
	return robot
end

function getInventoryController()
	return require("component").inventory_controller
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

function getItemsStacks()-- shood take data from file
	return {}
end

function max(var1, var2)
	if var1 > var2 then
		return var1
	else
		return var2
	end
end

function min(var1, var2)
	if var1 < var2 then
		return var1
	else
		return var2
	end
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

function calculateNeedMaterialsToCraftItem(craftableItemCount, recipe)
	local needMaterials = {} -- (itemName, itemCount)

	for i = 1, #recipe.materials do
		needMaterials[i] = {}
		needMaterials[i].itemName = recipe.materials[i].itemName
		needMaterials[i].itemCount = calculateNeedCountOfMaterialToCraftItem(craftableItemCount, recipe.receivedCount, recipe.materials[i].needCount)
	end

	return needMaterials
end

function findRecipe(itemName, recipes)
	return findIf(recipes, function(tableEl) return tableEl.itemName == itemName end)
end

function findCraftStation(craftStationName, craftStations)
	return findIf(craftStations, function(craftStation) return craftStation.craftStationName == craftStationName end)
end

function askUserAboutCreftableItem(recipe)
	print("Write item name and quantity")
	item = {}

	while true do
		item["itemName"] = read();
		if findRecipe(item.itemName, recipe) then
			break;
		else
			print("There is no recipe for the item you enter")
		end
	end

	while true do
		item["itemCount"] = tonumber(read());
		if item.itemCount > 0 then
			break
		else
			print("The number of elements can't be less than one")
		end
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

function inventoryIsEmpty(inventory)
	for _, _ in pairs(inventory.content) do
		return false
	end
	return true
end

function addVirtualItemToSlot(addableItem, inventory, slotToAdd, itemsStacks)
	if (inventory[slotToAdd].itemName == addableItem.itemName) or (not inventory[slotToAdd].itemName) then
		local changes = {slot = slotToAdd, itemName = addableItem.itemName}

		inventory[slotToAdd].itemName = addableItem.itemName
		local remainingSpaceInSlot = getItemStackSize(addableItem.itemName, itemsStacks) - inventory[slotToAdd].itemCount

		if addableItem.itemCount > remainingSpaceInSlot then-- the same code with the code that in "else", you shood fix this when you will refact this function
			if inventory.content[addableItem.itemName] then
				inventory.content[addableItem.itemName] = inventory.content[addableItem.itemName] + remainingSpaceInSlot
			else
				inventory.content[addableItem.itemName] = remainingSpaceInSlot
			end

			inventory[slotToAdd].itemCount = inventory[slotToAdd].itemCount + remainingSpaceInSlot
			changes.itemCountChange = remainingSpaceInSlot
			addableItem.itemCount = addableItem.itemCount - remainingSpaceInSlot
		else
			if inventory.content[addableItem.itemName] then
				inventory.content[addableItem.itemName] = inventory.content[addableItem.itemName] + addableItem.itemCount
			else
				inventory.content[addableItem.itemName] = addableItem.itemCount
			end

			inventory[slotToAdd].itemCount = inventory[slotToAdd].itemCount + addableItem.itemCount
			changes.itemCountChange = addableItem.itemCount
			addableItem.itemCount = 0
		end

		return changes
	end
end

function deleteVirtualItemFromSlot(slotToDelete, inventory, deleteCount)
	local nameOfDeletableItem = inventory[slotToDelete].itemName
	if  nameOfDeletableItem then
		local changes = {slot = slotToDelete, itemName = nameOfDeletableItem}

		if deleteCount and deleteCount <= inventory[slotToDelete].itemCount then
			inventory[slotToDelete].itemCount = inventory[slotToDelete].itemCount - deleteCount
			changes.itemCountChange = -deleteCount
			inventory.content[nameOfDeletableItem] = inventory.content[nameOfDeletableItem] - deleteCount
		else
			inventory.content[nameOfDeletableItem] = inventory.content[nameOfDeletableItem] - inventory[slotToDelete].itemCount
			changes.itemCountChange = -inventory[slotToDelete].itemCount
			inventory[slotToDelete].itemCount = 0
		end

		if inventory.content[nameOfDeletableItem] < 0 then-- if the function work right, than this "if" does't need. But I haven't make all tests yet...
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

		return changes
	end
end

function transferVirtualItemBetweenSlots(sourceSlot, sourceInventory, destinationSlot, destinationInventory, itemsStacks, count) -- untested
	local countOfItemsThatShouldBeTransferred = count or sourceInventory[sourceSlot].itemCount
	if sourceInventory[sourceSlot].itemCount < countOfItemsThatShouldBeTransferred then
		countOfItemsThatShouldBeTransferred = sourceInventory[sourceSlot].itemCount
	end

	local transferableItem = {itemName = sourceInventory[sourceSlot].itemName, itemCount = countOfItemsThatShouldBeTransferred}
	local changes = {sourceSlot = sourceSlot, destinationSlot = destinationSlot, itemName = transferableItem.itemName}
	changes.itemCountChange = addVirtualItemToSlot(transferableItem, destinationInventory, destinationSlot, itemsStacks).itemCountChange
	deleteVirtualItemFromSlot(sourceSlot, sourceInventory, ((count or sourceInventory[sourceSlot].itemCount) - transferableItem.itemCount))
	return changes
end

function addVirtualItemToInventory(addableItem, inventory, itemsStacks)
	local itemStackSize = getItemStackSize(addableItem.itemName, itemsStacks)
	local changes = {}

	while addableItem.itemCount > 0 do
		local slotToAddItem = findIf(inventory, function(slot) return slot.itemCount == 0 or (slot.itemName == addableItem.itemName and slot.itemCount < itemStackSize) end) -- ПО-ХУЙ -- unoptimised, but work :) LUA!!!

		if not slotToAddItem then
			break;
		end

		changes[#changes + 1] = addVirtualItemToSlot(addableItem, inventory, slotToAddItem, itemsStacks)
	end

	return changes
end

function deleteVirtualItemFromInventory(deletableItem, inventory)
	local changes = {}

	while deletableItem.itemCount > 0 do
		local slotToDeleteItem = findIf(inventory, function(slot) return slot.itemName == deletableItem.itemName end)

		if not slotToDeleteItem then
			break;
		end

		if deletableItem.itemCount > inventory[slotToDeleteItem].itemCount then
			deletableItem.itemCount = deletableItem.itemCount - inventory[slotToDeleteItem].itemCount
			changes[#changes + 1] =  deleteVirtualItemFromSlot(slotToDeleteItem, inventory)
		else
			changes[#changes + 1] =  deleteVirtualItemFromSlot(slotToDeleteItem, inventory, deletableItem.itemCount)
			deletableItem.itemCount = 0
		end
	end

	return changes
end

function transferVirtualItemBetweenInventories(transferableItem, sourceInventory, destinationInventory, itemsStacks, destinationSlot)-- destinationSlot is crutch. this thing shood be tested
	local transferableItemStack = getItemStackSize(transferableItem.itemName, itemsStacks)
	local changes = {}

	while transferableItem.itemCount > 0 do
		local slotFromWhichWeWillTransfer = findIf(sourceInventory, function(slot) return transferableItem.itemName == slot.itemName end)
		local sloToWhichWeWillTransfer = destinationSlot or findIf(destinationInventory, function(slot) return slot.itemCount == 0 or (slot.itemName == transferableItem.itemName and slot.itemCount < transferableItemStack) end)

		if not slotFromWhichWeWillTransfer or not sloToWhichWeWillTransfer then
			break
		end

		if transferableItem == sourceInventory[slotFromWhichWeWillTransfer] or transferableItem == destinationInventory[sloToWhichWeWillTransfer] then
			exception("transferVirtualItemBetweenInventories: the transferableItem can't be an item from the sourceInventory or the destinationInventory")
		end

		local countOfItemsInSlotFromWhichWeWillTransferBeforeTransfer = sourceInventory[slotFromWhichWeWillTransfer].itemCount
		changes[#changes + 1] = transferVirtualItemBetweenSlots(slotFromWhichWeWillTransfer, sourceInventory, sloToWhichWeWillTransfer, destinationInventory, itemsStacks, transferableItem.itemCount)
		transferableItem.itemCount = transferableItem.itemCount - (countOfItemsInSlotFromWhichWeWillTransferBeforeTransfer - sourceInventory[slotFromWhichWeWillTransfer].itemCount)
	end
	return changes
end

function findItemsInInventories(items, storages)
	local needItemsInStorages = {}
	local dontFindedItems = {}
	for i = 1, #items do
		dontFindedItems[items[i].itemName] = items[i].itemCount
	end

	for i = 1, #storages do
		needItemsInStorages[i] = {}
		for j = 1, #storages[i] do
			if storages[i][j].itemName and dontFindedItems[storages[i][j].itemName] then
				local takingItemCount = min(storages[i][j].itemCount, dontFindedItems[storages[i][j].itemName])
				needItemsInStorages[i][j] = {itemName = storages[i][j].itemName, itemCount = takingItemCount}
				dontFindedItems[storages[i][j].itemName] = dontFindedItems[storages[i][j].itemName] - takingItemCount

				if dontFindedItems[storages[i][j].itemName] < 0 then -- shood be removed after tests
					exception("dontFindedItems[storages[i][j].itemName] < 0")
				end

				if dontFindedItems[storages[i][j].itemName] == 0 then
					dontFindedItems[storages[i][j].itemName] = nil

					local listOfDontFindedItemsIsNotEmpty = false
					for _, _ in pairs(dontFindedItems) do
						listOfDontFindedItemsIsNotEmpty = true
						break
					end
					if not listOfDontFindedItemsIsNotEmpty then
						return needItemsInStorages
					end
				end
			end
		end
	end

	for _, _ in pairs(dontFindedItems) do
		return nil
	end

	return needItemsInStorages
end

function checkIfInventoryConsistItems(items, inventory)
	local dontFindedItems = {}
	for i = 1, #items do
		dontFindedItems[items[i].itemName] = items[i].itemCount
	end

	for i = 1, #inventory do
		for key, val in pairs(dontFindedItems) do
			if inventory[i].content[key] then
				dontFindedItems[key] = dontFindedItems[key] - inventory[i].content[key]

				if dontFindedItems[key] <= 0 then
					dontFindedItems[key] = nil

					local listOfDontFindedItemsIsNotEmpty = false
					for _, _ in pairs(dontFindedItems) do
						listOfDontFindedItemsIsNotEmpty = true
						break
					end

					if not listOfDontFindedItemsIsNotEmpty then
						return true
					end
				end
			end
		end
	end

	return false
end

function findInventoriesThatContainMaterials(inventories, materials)
	local inventoriesThatContainMaterials = {} -- {inventoryIndex{materialName = count}}
	for i = 1, #inventories do
		inventoriesThatContainMaterials[i] = {}
		for j = 1, #materials do
			if checkIfInventoryConsistItems({{itemName = materials[j].itemName, itemCount = 1}}, {inventories[i]}) then
				inventoriesThatContainMaterials[i][materials[j].itemName] = inventories[i].content[materials[j].itemName]
			end

		end
	end

	return inventoriesThatContainMaterials
end

function getCountOfItemsThatCanBeCraftedFromMaterialsFromStorages(recipe, storages)
	local countOfItemsThatCanBeCraftedFromMaterialsFromStorages

	for i = 1, #recipe.materials do
		local countOfMeterialInStorages = 0
		for j = 1, #storages do
			countOfMeterialInStorages = countOfMeterialInStorages + (storages[j].content[recipe.materials[i].itemName] or 0)
		end

		if not countOfItemsThatCanBeCraftedFromMaterialsFromStorages then
			countOfItemsThatCanBeCraftedFromMaterialsFromStorages = math.floor(countOfMeterialInStorages / recipe.materials[i].itemCount)
		else
			countOfItemsThatCanBeCraftedFromMaterialsFromStorages = min(countOfItemsThatCanBeCraftedFromMaterialsFromStorages, math.floor(countOfMeterialInStorages / recipe.materials[i].itemCount))
		end
	end

	return countOfItemsThatCanBeCraftedFromMaterialsFromStorages
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



function moveByOneDirection(block, robot, directionName, positiveStepMoveFunction, negativeStepMoveFunction)
	local step = 0
	local moveFunction
	local deltaCords = (block[directionName] - robot[directionName])
	if deltaCords > 0 then
		step = 1
		moveFunction = positiveStepMoveFunction
	elseif deltaCords < 0 then
		step = -1
		moveFunction = negativeStepMoveFunction
	end

	i = robot[directionName]
	while i ~= math.abs(block[directionName]) do
		moveFunction()
		i = i + step
	end

	robot[directionName] = block[directionName]
end

function changeFace(robot, side)
	local requiredSidesToNormalSides = {}
	requiredSidesToNormalSides[sides.front] = 0
	requiredSidesToNormalSides[sides.right] = 1
	requiredSidesToNormalSides[sides.back] = 2
	requiredSidesToNormalSides[sides.left] = 3

	local rotation = requiredSidesToNormalSides[side] - requiredSidesToNormalSides[robot.face]
	if rotation == -3 then
		rotation = 1
	elseif rotation == 3 then
		rotation = -1
	elseif rotation == -2  then
		rotation = 2
	end

	if rotation == 1 then
		robot.turnRight()
	elseif rotation == -1 then
		robot.turnLeft()
	elseif rotation == 2 then
		robot.turnAround()
	end

	robot.face = side
end

function goTo(block, robot)
	changeFace(robot, sides.front)
	moveByOneDirection(block, robot, "x", robot.forward, robot.back)
end

function standFaceBlock(block, robot)
	goTo(block, robot)

	local z = block.z - robot.z
	if z < 0 then
		changeFace(robot, sides.left)
	elseif z > 0 then
		changeFace(robot, sides.right)
	end
end



function dropItemsIntoInventoryFollowingTheListOfVirtualInventoryChanges(side, changes, robot, inventoryController)
	for i = 1, #changes do
		robot.select(changes[i].sourceSlot)
		inventoryController.dropIntoSlot(side, changes[i].destinationSlot, changes[i].itemCountChange)
	end
end

function takeItemsFromInventoryFollowingTheListOfVirtualInventoryChanges(side, changes, robot, inventoryController)
	for i = 1, #changes do
		robot.select(changes[i].destinationSlot)
		inventoryController.suckFromSlot(side, changes[i].sourceSlot, changes[i].itemCountChange)
	end
end

function dropItemsIntoSlot(robotInventorySlot, robotInventory, destinationSlot, destinationInventory, itemsStacks, count, side, robot, inventoryController)
	dropItemsIntoInventoryFollowingTheListOfVirtualInventoryChanges(side, {transferVirtualItemBetweenSlots(robotInventorySlot, robotInventory,  destinationSlot, destinationInventory, itemsStacks, count)}, robot, inventoryController)
end

function dropItemsIntoInventory(items, robotInventory, destinationInventory, itemsStacks, side, robot, inventoryController)
	dropItemsIntoInventoryFollowingTheListOfVirtualInventoryChanges(side, transferVirtualItemBetweenInventories(items, robotInventory, destinationInventory, itemsStacks), robot, inventoryController)
end

function takeItemsFromSlot(robotInventorySlot, robotInventory, sourceSlot, sourceInventory, itemsStacks, count, side, robot, inventoryController)
	takeItemsFromInventoryFollowingTheListOfVirtualInventoryChanges(side, {transferVirtualItemBetweenSlots(sourceSlot, sourceInventory, robotInventorySlot, robotInventory, itemsStacks, count)}, robot, inventoryController)
end

function takeItemsFromInventory(items, robotInventory, sourceInventory, itemsStacks, side, robot, inventoryController, destinationSlot)
	takeItemsFromInventoryFollowingTheListOfVirtualInventoryChanges(side, transferVirtualItemBetweenInventories(items, sourceInventory, robotInventory, itemsStacks, destinationSlot), robot, inventoryController)
end

function takeItemsFromStorage(items, robotInventory, sourceStorage, itemsStacks, robot, inventoryController, destinationSlot)
	standFaceBlock(sourceStorage, robot)
	local side = sides.front
	if robot.face == sides.front then
		side = sides.bottom
	end
	takeItemsFromInventory(items, robotInventory, sourceStorage, itemsStacks, side, robot, inventoryController, destinationSlot)
end

function dropItemsIntoStorage(items, robotInventory, destinationStorage, itemsStacks, robot, inventoryController)
	standFaceBlock(destinationStorage, robot)
	local side = sides.front
	if robot.face == sides.front then
		side = sides.bottom
	end
	dropItemsIntoInventory(items, robotInventory, destinationStorage, itemsStacks, side, robot, inventoryController)
end

function unloadRobotInventory(robotInventory, destinationStorages, itemsStacks, robot, inventoryController) -- to test
	local currentStorage = 1
	while not inventoryIsEmpty(robotInventory) do
		for key, val in pairs(robotInventory.content) do
			dropItemsIntoStorage({itemName = key, itemCount = val}, robotInventory, destinationStorages[currentStorage], itemsStacks, robot, inventoryController)
		end

		currentStorage = currentStorage + 1
		if currentStorage > #destinationStorages then
			exception("There is not enought space in the storages")
		end
	end
end

function transferItems(itemsToTransfer, sourceStorages, destinationStorages, robotInventory, itemsStacks, robot, inventoryController) -- to test ('couse unloadRobotInventory())
	local j = 1
	local jShoodBeIncremented

	for i = 1, #sourceStorages do
		j = 1
		while j <= #itemsToTransfer do
			jShoodBeIncremented = true
			takeItemsFromStorage(itemsToTransfer[j], robotInventory, sourceStorages[i], itemsStacks, robot, inventoryController)
			if itemsToTransfer[j].itemCount < 0 then exception("itemsToTransfer[j].itemCount < 0") end-- shood be removed after tests

			if itemsToTransfer[j].itemCount == 0 then
				table.remove(itemsToTransfer, j)
				jShoodBeIncremented = false
			end

			if robotInventory[#robotInventory].itemName then
				unloadRobotInventory(robotInventory, destinationStorages, itemsStacks, robot, inventoryController)
				jShoodBeIncremented = false
			end

			if jShoodBeIncremented then
				j = j + 1
			end
		end

		if #itemsToTransfer == 0 then
			break
		end
	end
	if not inventoryIsEmpty(robotInventory) then
		unloadRobotInventory(robotInventory, destinationStorages, itemsStacks, robot, inventoryController)
	end
end

function craftItems(craftableItems, recipes, robotInventory, storages, craftStations, robotInventory, itemsStacks, robot, inventoryController)
	for i = 1, #craftableItems do
		craftableItems[i].recipe = recipes[findRecipe(craftableItems[i].itemName, recipes)]
	end

	while #craftableItems > 0 do
		local indexOfCraftableItem = #craftableItems

		while indexOfCraftableItem > 0 do
			local craftStation = craftStations[findCraftStation(craftableItems[indexOfCraftableItem].recipe.craftStationName, craftStations)]
			craftStation.craft(craftStation, craftableItems[indexOfCraftableItem], craftableItems[indexOfCraftableItem].recipe, storages, robotInventory, itemsStacks, robot, inventoryController)

			if craftableItems[indexOfCraftableItem].itemCount < 0 then -- shood be removed after tests
				exception("function craft: craftableItems[indexOfCraftableItem].itemCount < 0")
			end

			if craftableItems[indexOfCraftableItem].itemCount == 0 then
				table.remove(craftableItems, indexOfCraftableItem)
				--indexOfCraftableItem = indexOfCraftableItem + 1
			end

			indexOfCraftableItem = indexOfCraftableItem - 1
		end

		os.sleep(10)

		for i = 1, #craftStations do
			if craftStations[i].isWorkingNow(craftStations[i]) and craftStations[i].checkIfCraftIsOver(craftStations[i], robot, inventoryController) then
				craftStations[i].unload(craftStations[i], storages, robotInventory, itemsStacks, robot, inventoryController)
			end
		end
	end

	local allCraftStationsDontWork = false
	while not allCraftStationsDontWork do
		allCraftStationsDontWork = true

		for i = 1, #craftStations do
			if craftStations[i].isWorkingNow(craftStations[i]) then
				allCraftStationsDontWork = false
				if craftStations[i].checkIfCraftIsOver(craftStations[i], robot, inventoryController) then
					craftStations[i].unload(craftStations[i], storages, robotInventory, itemsStacks, robot, inventoryController)
				end
			end
		end

		os.sleep(10)
	end
end




function main()
	local recipes = getRecipes()
	local craftableItem = askUserAboutCreftableItem(recipes)
	local craftableItems, needMaterials, needRecipes = getNeedItemsAndMaterialsAndRecipes(craftableItem, recipes)

	local chests = getChests()
	local robotInventory = getRobotInventory()

	pickUpMaterialsFromUser(needMaterials, chests, {})
	--craftItems(craftableItems, recipes, robotInventory, chests, itemsStacks)
	--for i = 1, #craftableItems do
	--	print(craftableItems[i].itemName.." "..craftableItems[i].itemCount)
	--end




end

--main()


magicCraftStation =
{
		craftStationName = "wire machine",
		x = 1, y = -1, z = 0,
		inputSlotNumber = 7,
		outputSlotNumber = 2,

		construct = function()
			magicCraftStation.content = {}
			for i = 1, magicCraftStation.inputSlotNumber do
				magicCraftStation[i] = {itemCount = 0}
				if (i ~= magicCraftStation.inputSlotNumber) and (i ~= magicCraftStation.outputSlotNumber) then
					addVirtualItemToSlot({itemName = "kostil", itemCount = 64}, magicCraftStation, i, {})
				end
			end
		end,

		isWorkingNow = function(this)
			return this[this.inputSlotNumber].itemCount ~= 0
		end,

		getRemainingInputSpaceForTheItem = function(this, itemName, recipe, itemsStacks)
			local remainingSpaceForTheItemInOutputSlot
			local remainingSpaceForTheMaterialInInputSlot
			local itemStackSize = getItemStackSize(itemName, itemsStacks)
			local materialStackSize = getItemStackSize(recipe.materials[1].itemName, itemsStacks)

			if not this[this.outputSlotNumber].itemName then
				remainingSpaceForTheItemInOutputSlot = itemStackSize
			elseif this[this.outputSlotNumber].itemCount < itemStackSize and this[this.outputSlotNumber].itemName == itemName then
				remainingSpaceForTheItemInOutputSlot = itemStackSize - this[this.outputSlotNumber].itemCount
			else
				remainingSpaceForTheItemInOutputSlot = 0
			end

			if not this[this.inputSlotNumber].itemName then
				remainingSpaceForTheMaterialInInputSlot = materialStackSize
			elseif not this[this.inputSlotNumber].itemCount < materialStackSize and not this[this.inputSlotNumber].itemName == recipe.materials[1].itemName then
				remainingSpaceForTheMaterialInInputSlot = materialStackSize - not this[this.inputSlotNumber].itemCount
			else
				remainingSpaceForTheMaterialInInputSlot = 0
			end

			local maxCountOfMaterials = calculateNeedCountOfMaterialToCraftItem(remainingSpaceForTheItemInOutputSlot, recipe.receivedCount, recipe.recipe[1].needCount)
			maxCountOfMaterials = math.floor(maxCountOfMaterials)
			if maxCountOfMaterials > remainingSpaceForTheMaterialInInputSlot then
				maxCountOfMaterials = remainingSpaceForTheMaterialInInputSlot
			end

			countOfItemThatWeGetFromMaxCountOfMaterials = math.floor(recipe.receivedCount * maxCountOfMaterials / recipe.recipe[1].needCount)

			return min(countOfItemThatWeGetFromMaxCountOfMaterials, remainingSpaceForTheItemInOutputSlot)
		end,

		load = function(this, storages, itemsToLoad, robotInventory, itemsStacks, robot, inventoryController)
			transferItems(itemsToLoad, storages, {this}, robotInventory, itemsStacks, robot, inventoryController)
		end,

		unload = function(this, storages, robotInventory, itemsStacks, robot, inventoryController)
			transferItems({{itemName = this[this.outputSlotNumber].itemName, itemCount = this[this.outputSlotNumber].itemCount}}, {this}, storages, robotInventory, itemsStacks, robot, inventoryController)
			deleteVirtualItemFromSlot(this.inputSlotNumber, this)
			deleteVirtualItemFromSlot(this.outputSlotNumber, this)
		end,

		createRecordThatItemIsBeingCrafted = function(this, item)
			addVirtualItemToSlot(item, this, this.outputSlotNumber, {})
		end,

		craft = function(this, craftableItem, craftableItemRecipe, storages, robotInventory, itemsStacks, robot, inventoryController)
			countOfItemsThatCanBeCrafted = min(this.getRemainingInputSpaceForTheItem(this, craftableItem.itemName, craftableItemRecipe, itemsStacks), craftableItem.itemCount)

			local needMaterials = calculateNeedMaterialsToCraftItem(countOfItemsThatCanBeCrafted, craftableItemRecipe)

			if countOfItemsThatCanBeCrafted > 0 and checkIfInventoryConsistItems(needMaterials, storages) then
				this.createRecordThatItemIsBeingCrafted(this, {itemName = craftableItem.itemName, itemCount = countOfItemsThatCanBeCrafted})
				this.load(this, storages, needMaterials, robotInventory, itemsStacks, robot, inventoryController)
				craftableItem.itemCount = craftableItem.itemCount - countOfItemsThatCanBeCrafted
			end
		end,

		checkIfCraftIsOver = function(this, robot, inventoryController)
			standFaceBlock(this, robot)
			local side = sides.front
			if robot.face == sides.front then
				side = sides.bottom
			end
			return inventoryController.getStackInSlot(side, this.inputSlotNumber) == nil
		end
}

magicCraftStation.construct()


workbenchInRobotInvenoryWithSizeOfRobotInventoryEqual4 =
{
		craftStationName = "workbench",

		isWorkingNow = function(this)
			return false -- return false constantly becouse workbench finish craft in function "craft"
		end,		

		craft = function(this, craftableItem, craftableItemRecipe, storages, robotInventory, itemsStacks, robot, inventoryController, crafting)
			local maxCountOfItemsThatCanBeCraftedPerOneCraft, maxCountOfMaterialsPerOneCraft  = this.calculateMaxCountOfMaterialsPerOneCraft(this, craftableItem, craftableItemRecipe, itemsStacks)
			--local needMaterials = calculateNeedMaterialsToCraftItem(maxCountOfItemsThatCanBeCraftedPerOneCraft, craftableItemRecipe)
			local maxCountOfItemsThatCanBeCrafted = min(craftableItem.itemCount, getCountOfItemsThatCanBeCraftedFromMaterialsFromStorages(craftableItemRecipe, storages))

			craftableItem.itemCount = craftableItem.itemCount - maxCountOfItemsThatCanBeCrafted

			if maxCountOfItemsThatCanBeCrafted < craftableItemRecipe.receivedCount and not maxCountOfItemsThatCanBeCrafted == 0 then -- this shood be deleted after test
				exception("workbench.craft() maxCountOfItemsThatCanBeCrafted < craftableItemRecipe.receivedCount and not maxCountOfItemsThatCanBeCrafted == 0")
			end

			while maxCountOfItemsThatCanBeCrafted >= craftableItemRecipe.receivedCount do
				if maxCountOfItemsThatCanBeCrafted < maxCountOfItemsThatCanBeCraftedPerOneCraft then
					maxCountOfItemsThatCanBeCraftedPerOneCraft, maxCountOfMaterialsPerOneCraft = this.calculateMaxCountOfMaterialsPerOneCraft(this, {itemName = craftableItem.itemName, itemCount = maxCountOfItemsThatCanBeCrafted}, craftableItemRecipe, itemsStacks)
					--needMaterials = calculateNeedMaterialsToCraftItem(maxCountOfItemsThatCanBeCraftedPerOneCraft, craftableItemRecipe)
				end

				this.load(this, craftableItemRecipe, maxCountOfMaterialsPerOneCraft, storages, robotInventory, itemsStacks, robot, inventoryController)
				crafting.craft()
				this.createRecordThatItemWasCrafted(this,...) -- the function removes items from the craft grid and adds a craft result to the first slot
				this.unload(this, storages, robotInventory, itemsStacks, robot, inventoryController, crafting)

				maxCountOfItemsThatCanBeCrafted = maxCountOfItemsThatCanBeCrafted - maxCountOfItemsThatCanBeCraftedPerOneCraft
			end
		end,

		checkIfCraftIsOver = function(this, robot, inventoryController)
			return true -- return true constantly becouse workbench finish craft in function "craft"
		end,

		calculateMaxCountOfMaterialsPerOneCraft = function(this, item, craftableItemRecipe, itemsStacks)
			local maxCountOfItemsThatCanBeCrafted

			local firstEmptySlotInCraft = findIf(craftableItemRecipe.recipe, function(el) return not el end)
			if (firstEmptySlotInCraft and (firstEmptySlotInCraft >= 1 and firstEmptySlotInCraft <= 3)) or (#craftableItemRecipe.recipe < 3) then
				maxCountOfItemsThatCanBeCrafted = craftableItemRecipe.receivedCount
			else
				maxCountOfItemsThatCanBeCrafted = craftableItemRecipe.receivedCount * (math.floor(getItemStackSize(item.itemName, itemsStacks) / craftableItemRecipe.receivedCount))
			end

			maxCountOfItemsThatCanBeCrafted = min(maxCountOfItemsThatCanBeCrafted, item.itemCount)

			for i = 1, #craftableItemRecipe.recipe do
				if craftableItemRecipe.recipe[i] then
					if calculateNeedCountOfMaterialToCraftItem(maxCountOfItemsThatCanBeCrafted, craftableItemRecipe.receivedCount, craftableItemRecipe.recipe[i].needCount) > getItemStackSize(craftableItemRecipe.recipe[i].itemName, itemsStacks) then
						maxCountOfItemsThatCanBeCrafted = getItemStackSize(craftableItemRecipe.recipe[i].itemName, itemsStacks) * craftableItemRecipe.receivedCount /  craftableItemRecipe.recipe[i].needCount
					end
				end
			end

			local maxCountOfMaterialsPerOneCraft = {}
			for i = 1, #craftableItemRecipe.recipe do
				if craftableItemRecipe.recipe[i] then
					craftableItemRecipe.recipe[i] = calculateNeedCountOfMaterialToCraftItem(maxCountOfItemsThatCanBeCrafted, craftableItemRecipe.receivedCount, craftableItemRecipe.recipe[i].needCount)
				else
					craftableItemRecipe.recipe[i] = 0
				end
			end

			return maxCountOfItemsThatCanBeCrafted, maxCountOfMaterialsPerOneCraft
		end,

		load = function(this, recipe, maxCountOfMaterialsPerOneCraft, storages, robotInventory, itemsStacks, robot, inventoryController) -- to test
			local notTakenMaterials = {}
			for i = 1, #recipe.recipe do
				if recipe.recipe[i] then
					notTakenMaterials[i] = {itemName = recipe.recipe[i].itemName, itemCount = maxCountOfMaterialsPerOneCraft} -- "itemCount = maxCountOfMaterialsPerOneCraft" becouse workbench on one craft use one pice of eqch material
				end
			end

			for i = 1, #storages do
				for j = 1, #notTakenMaterials do
					if notTakenMaterials[j] and checkIfInventoryConsistItems({notTakenMaterials[j]}, {storages[i]}) then
						takeItemsFromStorage(notTakenMaterials[j], robotInventory, storages[i], itemsStacks, robot, inventoryController, j)
					end
				end
			end
		end,

		unload = function(this, storages, robotInventory, itemsStacks, robot, inventoryController) -- to test
			unloadRobotInventory(robotInventory, storages, itemsStacks, robot, inventoryController)
		end,

		createRecordThatItemWasCrafted = function(this, craftableItemRecipe, maxCountOfItemsThatCanBeCraftedPerOneCraft, robotInventory, itemsStacks) -- to test
				for column = 1, 3 do
					deleteVirtualItemFromSlot(row * 4 + column, robotInventory) -- 4 is MAGIC NUMBER, it is the lenghts of the inventory side
				end
			end

			addVirtualItemToInventory({itemName = craftableItemRecipe.itemName, itemCount = maxCountOfItemsThatCanBeCraftedPerOneCraft}, robotInventory, itemsStacks)
		end
}




exit()

robott =
{
	x = 0, y = 0, z = 0, face = sides.front,
	forward = function()
		print("Robot go forward")
	end,

	back = function()
		print("Robot go back")
	end,

	turnRight = function()
		print("Robot turn right")
	end,

	turnLeft = function()
		rint("Robot turn left")
	end,

	turnAround = function()
		print("Robot turn around")
	end,

	select = function(slot)
		print("Robot select slot "..slot)
	end
}

ict =
{
	dropIntoSlot = function(side, slot, count)
		print("Inventory controller drop "..count.." items to "..slot.." slot in storage on the "..side.." side")
	end,

	suckFromSlot = function(side, slot, count)
		print("Inventory controller suck "..count.." items from "..slot.." slot from storage on the "..side.." side")
	end,

	getStackInSlot = function(side, slot)
		print("Inventory controller get count of items in "..slot.." slot in inventory on the "..side.." side")
		return 0
	end
}

chests = {getChests()[1]}

addVirtualItemToInventory({itemName = "copper ingot", itemCount = 1}, chests[1], {})

robot = getRobot()
robotInventory = getRobotInventory()
inventoryController = getInventoryController()

items = {{itemName = "copper wire", itemCount = 3}}

craftItems(items, getRecipes(), robotInventory, chests, {magicCraftStation}, robotInventory, {}, robot, inventoryController)

goTo({x = 0, y = 0, z = 0}, robott)

-- craftableItem(itemName, itemCount)
-- recipe(itemName, receivedCount, craftStationName, recipe(...(itemName, needCount)...), materials(...(itemName, needCount)...))
-- itemsStacks(itemName = itemStackSize)
-- inventory(..(itemName, itemCount).., content(..(itemName = itemCount)..))
-- cords(x, y, z)

-- craftStation
--(
--	craftStationName,
--	craft = function(this, craftableItem, craftableItemRecipe, itemsStacks, storages, robot, inventoryController, ),
--	checkIfCraftIsOver = function(this, robot, inventoryController): bool,
--	isWorkingNow = (function(this): bool),
--	unload = function(this, storages, robot, inventoryController)
--)

--проверь короче в функцию на конкретную переменная ссылка даеться или значение
--и ище там если таблицу кидать в функцию то если в этой таблицу была переменная то она ссылка или нет

--todo:
--в короче в этуй ну та эта короче эта addVirtualItemToSlot корроче там если item.itemCount <0 то не чекаеться это да помнишь2
