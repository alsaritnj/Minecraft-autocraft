local craftStationPosition = 8
local receivedItemPosition = 4
local componentsPositions = {1, 2, 3, 5, 6, 7, 9, 10, 11}

local craftStationsAliases = require("craftStationsAliases")
local itemsAliases = require("aliases")
require("addAlias")


function findAliasByName(name, aliases)
	for key, val in pairs(aliases) do
		if val == name then
			return key
		end
	end

	return name
end

function getItemInSlot(slot)
    local inventoryController = require("component").inventory_controller
    local item = inventoryController.getStackInInternalSlot(slot)
    if item then
        return {itemName = item.label, itemCount = item.size}
    end
end

function addAliasIfItDoesntExist(itemName, aliases, fileToAdd)
    if not findAliasByName(itemName, aliases) then
        print("There is no alias for " .. itemName .. "in file " .. fileToAdd .. ". Do you want to create it?(Y/n):")
        if string.lower(read()) == "y" then
            print("Write alias for " .. itemName .. ":")
            addAlias(itemName, read(), fileToAdd)
        end
    end
end

print("Output file:")
local outputFile = read()

print("record/exit:")
local input
while true do
    input = read()
    if input == "exit" then
        break
    else
        local craftStationName = getItemInSlot(craftStationPosition).itemName
        local receivedItem = getItemInSlot(receivedItemPosition)
        components = {}
        for i = 1, #componentsPositions do
            components[i] = getItemInSlot(componentsPositions[i])
        end

        addAliasIfItDoesntExist(craftStationName, craftStationsAliases, "craftStationsAliases")
        addAliasIfItDoesntExist(receivedItem.itemName, itemsAliases, "aliases")
        for _, val in pairs(components) do
            addAliasIfItDoesntExist(val.itemName, itemsAliases, "aliases")
        end

        addTextToEndOfTableInFile
        (
            "{itemName = \"" .. receivedItem.itemName .. "\",\n\treceivedCount = " .. receivedItem.itemCount .. ", craftStationName = \"" craftStationName .. "\",\n\trecipe = \n\t{\n\t\t
            {itemName = "copper wire", needCount = 1}, {itemName = "rudder", needCount = 1}
        },
        materials = 
        {
            {itemName = "copper wire", needCount = 1}, {itemName = "rudder", needCount = 1}
        }
    }
            , outputFile
        )

    end

end