require("Item")
VirtualItem = {}

function VirtualItem:create()
    local newObject= {}

    newObject.name = ""
    newObject.amount = 0
    
    setmetatable(VirtualItem ,{__index = Item})
    return newObject
end

function Item:getName()
    return self.name
end

function Item:getAmount()
    return self.amount
end

function Item:take()

end

function Item:place()

end