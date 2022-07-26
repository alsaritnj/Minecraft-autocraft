-- the separetad table for each type made for easy data enter
local workbenchRecipes = 
{
    {itemName = "copper insulated wire",
        receivedCount = 1, craftStationName = "workbench",
        recipe = 
        {
            {itemName = "copper wire", needCount = 1}, {itemName = "rubber", needCount = 1}
        },
        materials = 
        {
            {itemName = "copper wire", needCount = 1}, {itemName = "rudder", needCount = 1}
        }
    },

	{itemName = "part circuit", 
        receivedCount = 1, craftStationName = "workbench",
        recipe = 
        {
            {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1},
            {itemName = "redstone", needCount = 1}, {itemName = "iron plate", needCount = 1}, {itemName = "redstone", needCount = 1},
            {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}, {itemName = "copper insulated wire", needCount = 1}
        },
        materials = 
        {
            {itemName = "copper insulated wire", needCount = 6}, {itemName = "redstone", needCount = 2}, {itemName = "iron plate", needCount = 1}
        }
    },

	{itemName = "stick", 
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
}

local wireMachineRecipes =
{
    {itemName = "copper wire",
        receivedCount = 3, craftStationName = "wire machine",
        recipe = 
        {
            {itemName = "copper ingot", needCount = 1}
        },
        materials = 
        {
            {itemName = "copper ingot", needCount = 1}
        }
    }
}

local rollingMachineRecipes = 
{
    {itemName = "iron plate",
        receivedCount = 1, craftStationName = "rolling machine", 
        recipe = 
        {
            {itemName = "iron ingot", needCount = 1}
        }, 
        materials = 
        {
            {itemName = "iron ingot", needCount = 1}
        }
    }
}

local compressorRecipes = 
{
    {itemName = "energy crystal",
        receivedCount = 1, craftStationName = "compressor", 
        recipe = 
        {
            {itemName = "energy dust", needCount = 9}
        }, 
        materials = 
        {
            {itemName = "energy dust", needCount = 9}
        }
    }
}

-- we are merging all tables with recipes in one
local allRecipesByType = {workbenchRecipes, wireMachineRecipes, rollingMachineRecipes, compressorRecipes}

local allRawRecipes = {}
for i = 1, #allRecipesByType do
    for j = 1, #allRecipesByType[i] do
        allRawRecipes[#allRawRecipes + 1] = allRecipesByType[i][j]
    end
end

return allRawRecipes