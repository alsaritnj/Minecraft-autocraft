return 
{
    inventory_controller = 
    {
        dropIntoSlot = function(side, slot, count)
			print("Inventory controller drop "..count.." items to "..slot.." slot in storage on the "..side.." side")
		end,

		suckFromSlot = function(side, slot, count)
			print("Inventory controller suck "..count.." items from "..slot.." slot from storage on the "..side.." side")
		end,

		getStackInSlot = function(side, slot)
			print("Inventory controller get count of items in "..slot.." slot in inventory on the "..side.." side")
		end
    },

    crafting = 
    {
        craft = function()
            print("Crafting craft something")
        end
    }
}