os =
{
	sleep = function(timeout)
		print("Sleep for "..timeout.." seconds")
	end
}

sides = require("sides")

function read()
	return io.read()
end

function getAliases()
	return require("aliases")
end

function getRecipes()
	return require("recipes")
end

function getRobotInventory()
	return createEmptyInventory(require("settings").robotInventorySize)
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

function getCrafting()
	return require("component").crafting
end

function getStorages()
	local map = require("storages")
	local storages = {}

	for i = 1, #map do
		storages[i] = createEmptyInventory(map[i].size)
		storages[i].x = map[i].x
		storages[i].y = map[i].y
		storages[i].z = map[i].z
	end

	return storages
end

function getCraftStations()
	return require("craftStations")
end

function getItemsStacks()
	return require("itemsStacks")
end

function getSides()
	return require("sides")
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

function findAliasByName(name, aliases)
	for key, val in pairs(aliases) do
		if val == name then
			return key
		end
	end

	return name
end

function findCraftStation(craftStationName, craftStations)
	return findIf(craftStations, function(craftStation) return craftStation.craftStationName == craftStationName end)
end

function askUserAboutCreftableItem(recipe, aliases)
	print("Write item name and quantity")
	item = {}

	while true do
		local name = read()
		item["itemName"] = aliases[name] or name;
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
				equalEndItemAdd(needItems, {itemName = materialRecipe.itemName, itemCount = calculateNeedCountOfMaterialToCraftItem(needItems[i].itemCount, itemRecipe.receivedCount,  material.needCount)})
				oneTimeItemAdd(needRecipes, materialRecipe)
			end
		end
		
		i = i + 1
	end

	for i = 1, #needItems do
		local itemRecipe = needRecipes[findRecipe(needItems[i].itemName, needRecipes)]
		needItems[i].itemCount = itemRecipe.receivedCount * math.ceil(needItems[i].itemCount / itemRecipe.receivedCount)
		
		for j = 1, #itemRecipe.materials do
			local material = itemRecipe.materials[j]
			local materialRecipe = needRecipes[findRecipe(material.itemName, needRecipes)]

			if not materialRecipe then
				equalItemAdd(needMaterials, {itemName = material.itemName, itemCount = calculateNeedCountOfMaterialToCraftItem(needItems[i].itemCount, itemRecipe.receivedCount, material.needCount)})
			end
		end
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
			countOfItemsThatCanBeCraftedFromMaterialsFromStorages = math.floor(countOfMeterialInStorages / recipe.materials[i].needCount * recipe.receivedCount)
		else
			countOfItemsThatCanBeCraftedFromMaterialsFromStorages = min(countOfItemsThatCanBeCraftedFromMaterialsFromStorages, math.floor(countOfMeterialInStorages / recipe.materials[i].needCount))
		end
	end
	return countOfItemsThatCanBeCraftedFromMaterialsFromStorages
end

function pickUpMaterialsFromUser(needMaterials, chests, itemsStacks, aliases)
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

	print("Place the following items in chests:")
	for i = 1, #needMaterials do
		print(findAliasByName(needMaterials[i].itemName, aliases).."\t"..needMaterials[i].itemCount.."\t("..math.floor(needMaterials[i].itemCount / getItemStackSize(needMaterials[i].itemName, itemsStacks)).." and "..needMaterials[i].itemCount % getItemStackSize(needMaterials[i].itemName, itemsStacks)..")")
	end

	print("Press enter if you are done placing items in chests")
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

	local i = robot[directionName]
	while i ~= block[directionName] do
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
	if robot.x ~= block.x then
		changeFace(robot, sides.front)
		moveByOneDirection(block, robot, "x", robot.forward, robot.back)
	end
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
	local currentStorage = 0
	while not inventoryIsEmpty(robotInventory) do
		currentStorage = currentStorage + 1
		if currentStorage > #destinationStorages then
			exception("There is not enought space in the storages")
		end

		for key, val in pairs(robotInventory.content) do
			dropItemsIntoStorage({itemName = key, itemCount = val}, robotInventory, destinationStorages[currentStorage], itemsStacks, robot, inventoryController)
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

function craftItems(craftableItems, recipes, storages, craftStations, robotInventory, itemsStacks, robot, inventoryController, crafting)
	for i = 1, #craftableItems do
		craftableItems[i].recipe = recipes[findRecipe(craftableItems[i].itemName, recipes)]
	end

	while #craftableItems > 0 do
		local indexOfCraftableItem = #craftableItems

		while indexOfCraftableItem > 0 do
			local craftStation = craftStations[findCraftStation(craftableItems[indexOfCraftableItem].recipe.craftStationName, craftStations)]

			craftStation.craft(craftStation, craftableItems[indexOfCraftableItem], craftableItems[indexOfCraftableItem].recipe, storages, robotInventory, itemsStacks, robot, inventoryController, crafting)

			if craftableItems[indexOfCraftableItem].itemCount < 0 then -- shood be removed after tests
				exception("function craft: craftableItems[indexOfCraftableItem].itemCount < 0")
			end

			if craftableItems[indexOfCraftableItem].itemCount == 0 then
				table.remove(craftableItems, indexOfCraftableItem)
			end

			indexOfCraftableItem = indexOfCraftableItem - 1
		end

		os.sleep(require("settings").craftStationsUnloadCooldown)

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

		os.sleep(require("settings").craftStationsUnloadCooldown)
	end
end


function main()
	local recipes = getRecipes()
	local itemsStacks = getItemsStacks()
	local aliases = getAliases()

	local craftStations = getCraftStations()
	local storages = getStorages()

	local robotInventory = getRobotInventory()
	local robot = getRobot()
	local inventoryController = getInventoryController()
	local crafting = getCrafting()



	local craftableItem = askUserAboutCreftableItem(recipes, aliases)
	local craftableItems, needMaterials, needRecipes = getNeedItemsAndMaterialsAndRecipes(craftableItem, recipes)
	pickUpMaterialsFromUser(needMaterials, storages, itemsStacks, aliases)


	craftItems(craftableItems, needRecipes, storages, craftStations, robotInventory, itemsStacks, robot, inventoryController, crafting)

	goTo({x = 0, y = 0, z = 0}, robot)
	changeFace(robot, sides.front)
end

main()






--[[
chests = {getChests()[1]}

addVirtualItemToInventory({itemName = "copper ingot", itemCount = 1}, chests[1], {})

robot = getRobot()
robotInventory = getRobotInventory()
inventoryController = getInventoryController()

items = {{itemName = "copper wire", itemCount = 3}}

craftItems(items, getRecipes(), robotInventory, chests, {magicCraftStation}, robotInventory, {}, robot, inventoryController)

goTo({x = 0, y = 0, z = 0}, robott)
]]
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
