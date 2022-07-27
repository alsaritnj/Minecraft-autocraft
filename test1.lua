function getItemStackSize(itemName, itemsStacks)--in table itemStack you shood write only those items that itemStackSize is not equal to 64
	return itemsStacks[itemName] or 64
end
function calculateNeedCountOfMaterialToCraftItem(needCountOfItem, receivedCountOfItem, needCountOfMaterialPerOneCraft)
	return needCountOfItem * needCountOfMaterialPerOneCraft / receivedCountOfItem
end

function calculateMaxCountOfMaterialsPerOneCraft(this, item, craftableItemRecipe, itemsStacks)
    local maxCountOfItemsThatCanBeCrafted = craftableItemRecipe.receivedCount * (math.floor(getItemStackSize(item.itemName, itemsStacks) / craftableItemRecipe.receivedCount))
    maxCountOfItemsThatCanBeCrafted = math.min(maxCountOfItemsThatCanBeCrafted, item.itemCount)

    return maxCountOfItemsThatCanBeCrafted, calculateNeedCountOfMaterialToCraftItem(maxCountOfItemsThatCanBeCrafted, craftableItemRecipe.receivedCount, 1)
end
craftableItemRecipe = {itemName = "stick", 
receivedCount = 4, craftStationName = "workbench", 
recipe = 
{
    {itemName = "wood", needCount = 1}, nil, nil, {itemName = "wood", needCount = 1}
}, 
materials = 
{
    {itemName = "wood", needCount = 2}
}
}


print(calculateMaxCountOfMaterialsPerOneCraft(nil, {itemName = "copper insulated wire", itemCount = 65}, craftableItemRecipe, {}))