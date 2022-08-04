function addTextToEndOfTableInFile(text, fileName)
    local file = io.open(fileName, "r")
    local content = file:read("a")
    io.close(file)

    file = io.open(fileName, "w")
    file:write(string.gsub(content, "\n}", "") .. ",\n\t" .. text .. "\n}")
    io.close(file)
end