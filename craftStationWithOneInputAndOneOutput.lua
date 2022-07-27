local craftStationWithOneInputAndOneOutput = 
{
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
		elseif (not ((this[this.inputSlotNumber].itemCount) < materialStackSize)) and (not ((this[this.inputSlotNumber].itemName) == (recipe.materials[1].itemName))) then
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

function craftStationWithOneInputAndOneOutput:construct(craftStationName, x, y, z, inputSlotNumber, outputSlotNumber)
    local newObject = {}
	
    newObject.craftStationName = craftStationName
    newObject.x = x
    newObject.y = y
    newObject.z = z
    newObject.inputSlotNumber = inputSlotNumber
    newObject.outputSlotNumber = outputSlotNumber

    newObject.content = {}

	for i = 1, max(inputSlotNumber, outputSlotNumber) do
		newObject[i] = {itemCount = 0}
		if (i ~= inputSlotNumber) and (i ~= outputSlotNumber) then
            addVirtualItemToSlot({itemName = "kostil", itemCount = 64}, newObject, i, {})
		end
	end

    setmetatable(newObject, craftStationWithOneInputAndOneOutput)
    self.__index = self

    return newObject
end



return craftStationWithOneInputAndOneOutput