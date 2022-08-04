function addAlias(name, alias, fileName)
    local aliases = io.open(fileName, "r")
    local content = aliases:read("a")
    io.close(aliases)

    content =  string.gsub(content, "\n}", "") .. ",\n\t\"" .. name .."\" = \"" .. alias .. "\"\n}"

    aliases = io.open(fileName, "w")
    aliases:write(content)
    io.close(aliases)
end