function newStorage(size, x, y, z)
    local newStorage = {}

    newStorage.size = size
    newStorage.x = x
    newStorage.y = y
    newStorage.z = z

    return newStorage
end

return 
{
    newStorage(24, 0, 0, -1),
    newStorage(24, 0, 0, 1),
}