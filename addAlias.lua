function addAlias(name, alias)
    local aliases = io.open("aliases.lua", "r")
    local content = aliases:read("a")
    io.close(aliases)

    content =  string.gsub(content, "\n}", "") .. ",\n\t\"" .. name .."\" = \"" .. alias .. "\"\n}"

    aliases = io.open("aliases.lua", "w")
    aliases:write(content)
    io.close(aliases)
end