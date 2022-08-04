return function addAlias(name, alias)
    local aliases = io.open("aliases", "r")
    local content = aliases:read("a")
    io.close(aliases)

    content =  string.gsub(content, "\n}", "") .. ",\n\t\"" .. name .."\" = \"" .. alias .. "\"\n}"

    aliases = io.open("aliases", "w")
    aliases:write(content)
    io.close(aliases)
end