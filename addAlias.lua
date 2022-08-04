require("addTextToEndOfTableInFile")

function addAlias(name, alias, fileName)
    addTextToEndOfTableInFile(("\"" .. alias .."\" = \"" .. name .. "\""), itemName)
end