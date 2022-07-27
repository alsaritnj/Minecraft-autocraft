craftStationWithOneInputAndOneOutput = require("craftStationWithOneInputAndOneOutput")


return 
{
    
	{craftStationName = "workbench",

			isWorkingNow = function(this)
				return false -- return false constantly becouse workbench finish craft in function "craft"
			end,

			craft = function(this, craftableItem, craftableItemRecipe, storages, robotInventory, itemsStacks, robot, inventoryController, crafting)
				local maxCountOfItemsThatCanBeCraftedPerOneCraft, maxCountOfMaterialsPerOneCraft  = this.calculateMaxCountOfMaterialsPerOneCraft(this, craftableItem, craftableItemRecipe, itemsStacks)
				local maxCountOfItemsThatCanBeCrafted = min(craftableItem.itemCount, getCountOfItemsThatCanBeCraftedFromMaterialsFromStorages(craftableItemRecipe, storages))

				craftableItem.itemCount = craftableItem.itemCount - maxCountOfItemsThatCanBeCrafted

				if maxCountOfItemsThatCanBeCrafted < craftableItemRecipe.receivedCount and not maxCountOfItemsThatCanBeCrafted == 0 then -- this shood be deleted after test
					exception("workbench.craft() maxCountOfItemsThatCanBeCrafted < craftableItemRecipe.receivedCount and not maxCountOfItemsThatCanBeCrafted == 0")
				end

				while maxCountOfItemsThatCanBeCrafted >= craftableItemRecipe.receivedCount do
					if maxCountOfItemsThatCanBeCrafted < maxCountOfItemsThatCanBeCraftedPerOneCraft then
						maxCountOfItemsThatCanBeCraftedPerOneCraft, maxCountOfMaterialsPerOneCraft = this.calculateMaxCountOfMaterialsPerOneCraft(this, {itemName = craftableItem.itemName, itemCount = maxCountOfItemsThatCanBeCrafted}, craftableItemRecipe, itemsStacks)
					end

					this.load(this, craftableItemRecipe, maxCountOfMaterialsPerOneCraft, storages, robotInventory, itemsStacks, robot, inventoryController)
					robot.select(4)
					crafting.craft()
					this.createRecordThatItemWasCrafted(this, craftableItemRecipe, maxCountOfItemsThatCanBeCraftedPerOneCraft, robotInventory, itemsStacks)
					this.unload(this, storages, robotInventory, itemsStacks, robot, inventoryController, crafting)

					maxCountOfItemsThatCanBeCrafted = maxCountOfItemsThatCanBeCrafted - maxCountOfItemsThatCanBeCraftedPerOneCraft
				end
			end,

			checkIfCraftIsOver = function(this, robot, inventoryController)
				return true -- return true constantly becouse workbench finish craft in function "craft"
			end,

			calculateMaxCountOfMaterialsPerOneCraft = function(this, item, craftableItemRecipe, itemsStacks)
				local maxCountOfItemsThatCanBeCrafted = craftableItemRecipe.receivedCount * (math.floor(getItemStackSize(item.itemName, itemsStacks) / craftableItemRecipe.receivedCount))
				maxCountOfItemsThatCanBeCrafted = min(maxCountOfItemsThatCanBeCrafted, item.itemCount)

				return maxCountOfItemsThatCanBeCrafted, calculateNeedCountOfMaterialToCraftItem(maxCountOfItemsThatCanBeCrafted, craftableItemRecipe.receivedCount, 1)
			end,

			load = function(this, recipe, maxCountOfMaterialsPerOneCraft, storages, robotInventory, itemsStacks, robot, inventoryController) -- todo and test
				local notTakenMaterials = {}
				for i = 1, #recipe.recipe do
					if recipe.recipe[i] then
						notTakenMaterials[i] = {itemName = recipe.recipe[i].itemName, itemCount = maxCountOfMaterialsPerOneCraft} -- "itemCount = maxCountOfMaterialsPerOneCraft" becouse workbench on one craft use one pice of eqch material
					end
				end

				for i = 1, #storages do
					for j, v in pairs(notTakenMaterials) do						
						if notTakenMaterials[j] and checkIfInventoryConsistItems({v}, {storages[i]}) then
							local slot = j
							if slot > 3 then
								slot = slot + 1
							elseif slot > 6 then
								slot = slot + 1
							end

							takeItemsFromStorage(v, robotInventory, storages[i], itemsStacks, robot, inventoryController, slot)
						end
					end
				end
			end,

			unload = function(this, storages, robotInventory, itemsStacks, robot, inventoryController) -- to test
				unloadRobotInventory(robotInventory, storages, itemsStacks, robot, inventoryController)
			end,

			createRecordThatItemWasCrafted = function(this, craftableItemRecipe, maxCountOfItemsThatCanBeCraftedPerOneCraft, robotInventory, itemsStacks) -- to test
				for row = 0, 2 do
					for column = 1, 3 do
						deleteVirtualItemFromSlot(row * 4 + column, robotInventory) -- 4 is MAGIC NUMBER, it is the lenghts of the inventory side
					end
				end
				addVirtualItemToSlot({itemName = craftableItemRecipe.itemName, itemCount = maxCountOfItemsThatCanBeCraftedPerOneCraft}, robotInventory, 4, itemsStacks)
			end
	},

    craftStationWithOneInputAndOneOutput:construct("wire machine", 1, -1, 0, 7, 2),

    craftStationWithOneInputAndOneOutput:construct("rolling machine", 2, -1, 0, 7, 2),

    craftStationWithOneInputAndOneOutput:construct("compressor", 3, -1, 0, 7, 2)
}