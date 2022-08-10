-- the separetad table for each type made for easy data enter
local workbenchRecipes = 
{
    {itemName = "Heat Vent",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Iron Plate", needCount = 1}, {itemName = "Iron Bars", needCount = 1}, 
			{itemName = "Iron Plate", needCount = 1}, {itemName = "Electric Motor", needCount = 1}, {itemName = "Iron Plate", needCount = 1}, 
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Iron Plate", needCount = 1}, {itemName = "Iron Bars", needCount = 1}
		},
		materials =
		{
			{itemName = "Iron Bars", needCount = 4}, {itemName = "Iron Plate", needCount = 4}, {itemName = "Electric Motor", needCount = 1}
		}
	},
	{itemName = "Reactor Heat Vent",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Copper Plate", needCount = 1}, {itemName = "Copper Plate", needCount = 1}, {itemName = "Copper Plate", needCount = 1}, 
			{itemName = "Copper Plate", needCount = 1}, {itemName = "Heat Vent", needCount = 1}, {itemName = "Copper Plate", needCount = 1}, 
			{itemName = "Copper Plate", needCount = 1}, {itemName = "Copper Plate", needCount = 1}, {itemName = "Copper Plate", needCount = 1}
		},
		materials =
		{
			{itemName = "Copper Plate", needCount = 8}, {itemName = "Heat Vent", needCount = 1}
		}
	},
	{itemName = "Overclocked Heat Vent",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			nil, {itemName = "Gold Plate", needCount = 1}, nil, 
			{itemName = "Gold Plate", needCount = 1}, {itemName = "Reactor Heat Vent", needCount = 1}, {itemName = "Gold Plate", needCount = 1}, 
			nil, {itemName = "Gold Plate", needCount = 1}, nil
		},
		materials =
		{
			{itemName = "Gold Plate", needCount = 4}, {itemName = "Reactor Heat Vent", needCount = 1}
		}
	},
	{itemName = "Component Heat Vent",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Tin Plate", needCount = 1}, {itemName = "Iron Bars", needCount = 1}, 
			{itemName = "Tin Plate", needCount = 1}, {itemName = "Heat Vent", needCount = 1}, {itemName = "Tin Plate", needCount = 1}, 
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Tin Plate", needCount = 1}, {itemName = "Iron Bars", needCount = 1}
		},
		materials =
		{
			{itemName = "Iron Bars", needCount = 4}, {itemName = "Tin Plate", needCount = 4}, {itemName = "Heat Vent", needCount = 1}
		}
	},
	{itemName = "Advanced Heat Vent",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Heat Vent", needCount = 1}, {itemName = "Iron Bars", needCount = 1}, 
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Diamond", needCount = 1}, {itemName = "Iron Bars", needCount = 1}, 
			{itemName = "Iron Bars", needCount = 1}, {itemName = "Heat Vent", needCount = 1}, {itemName = "Iron Bars", needCount = 1}
		},
		materials =
		{
			{itemName = "Iron Bars", needCount = 6}, {itemName = "Heat Vent", needCount = 2}, {itemName = "Diamond", needCount = 1}
		}
	},
	{itemName = "Insulated Copper Cable",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Copper Cable", needCount = 1}, {itemName = "Rubber", needCount = 1}, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		
		materials =
		{
			{itemName = "Copper Cable", needCount = 1}, {itemName = "Rubber", needCount = 1}
		}
	},
	{itemName = "Insulated Tin Cable",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Tin Cable", needCount = 1}, {itemName = "Rubber", needCount = 1}, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Tin Cable", needCount = 1}, {itemName = "Rubber", needCount = 1}
		}
	},
	{itemName = "Electric Motor",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			nil, {itemName = "Tin Item Casing", needCount = 1}, nil, 
			{itemName = "Coil", needCount = 1}, {itemName = "Iron Ingot", needCount = 1}, {itemName = "Coil", needCount = 1}, 
			nil, {itemName = "Tin Item Casing", needCount = 1}, nil
		},
		materials =
		{
			{itemName = "Tin Item Casing", needCount = 2}, {itemName = "Coil", needCount = 2}, {itemName = "Iron Ingot", needCount = 1}
		}
	},
	{itemName = "Electronic Circuit",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Insulated Copper Cable", needCount = 1}, {itemName = "Insulated Copper Cable", needCount = 1}, {itemName = "Insulated Copper Cable", needCount = 1}, 
			{itemName = "Redstone", needCount = 1}, {itemName = "Iron Plate", needCount = 1}, {itemName = "Redstone", needCount = 1}, 
			{itemName = "Insulated Copper Cable", needCount = 1}, {itemName = "Insulated Copper Cable", needCount = 1}, {itemName = "Insulated Copper Cable", needCount = 1}
		},
		materials =
		{
			{itemName = "Insulated Copper Cable", needCount = 6}, {itemName = "Redstone", needCount = 2}, {itemName = "Iron Plate", needCount = 1}
		}
	},
	{itemName = "Transistor",
		receivedCount = 8, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Iron Ingot", needCount = 1}, {itemName = "Iron Ingot", needCount = 1}, {itemName = "Iron Ingot", needCount = 1}, 
			{itemName = "Gold Nugget", needCount = 1}, {itemName = "Paper", needCount = 1}, {itemName = "Gold Nugget", needCount = 1}, 
			nil, {itemName = "Redstone", needCount = 1}, nil
		},
		materials =
		{
			{itemName = "Iron Ingot", needCount = 3}, {itemName = "Gold Nugget", needCount = 2}, {itemName = "Paper", needCount = 1}, 
			{itemName = "Redstone", needCount = 1}
		}
	},
	{itemName = "Coil",
		receivedCount = 1, craftStationName = "CraftingTable",
		recipe =
		{
			{itemName = "Copper Cable", needCount = 1}, {itemName = "Copper Cable", needCount = 1}, {itemName = "Copper Cable", needCount = 1}, 
			{itemName = "Copper Cable", needCount = 1}, {itemName = "Iron Ingot", needCount = 1}, {itemName = "Copper Cable", needCount = 1}, 
			{itemName = "Copper Cable", needCount = 1}, {itemName = "Copper Cable", needCount = 1}, {itemName = "Copper Cable", needCount = 1}
		},
		materials =
		{
			{itemName = "Copper Cable", needCount = 8}, {itemName = "Iron Ingot", needCount = 1}
		}
	},
}

local wireMachineRecipes =
{
    {itemName = "Copper Cable",
		receivedCount = 3, craftStationName = "WireMachine",
		recipe =
		{
			{itemName = "Copper Ingot", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Copper Ingot", needCount = 1}
		}
	},
	{itemName = "Tin Cable",
		receivedCount = 3, craftStationName = "WireMachine",
		recipe =
		{
			{itemName = "Tin Ingot", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Tin Ingot", needCount = 1}
		}
	},
}

local rollingMachineRecipes = 
{
   	{itemName = "Iron Item Casing",
		receivedCount = 2, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Iron Plate", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Iron Plate", needCount = 1}
		}
	},
	{itemName = "Copper Item Casing",
		receivedCount = 2, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Copper Plate", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Copper Plate", needCount = 1}
		}
	},
	{itemName = "Tin Item Casing",
		receivedCount = 2, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Tin Plate", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Tin Plate", needCount = 1}
		}
	},
	{itemName = "Copper Plate",
		receivedCount = 1, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Copper Ingot", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Copper Ingot", needCount = 1}
		}
	},
	{itemName = "Tin Plate",
		receivedCount = 1, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Tin Ingot", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Tin Ingot", needCount = 1}
		}
	},
	{itemName = "Iron Plate",
		receivedCount = 1, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Iron Ingot", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Iron Ingot", needCount = 1}
		}
	},
	{itemName = "Gold Plate",
		receivedCount = 1, craftStationName = "RollingMachine",
		recipe =
		{
			{itemName = "Gold Ingot", needCount = 1}, nil, nil, 
			nil, nil, nil, 
			nil, nil, nil
		},
		materials =
		{
			{itemName = "Gold Ingot", needCount = 1}
		}
	}
}

local compressorRecipes = 
{
    
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