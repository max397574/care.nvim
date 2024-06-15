local function tofile(fname, text)
    local f = io.open(fname, "w")
    if not f then
        error(("failed to write: %s"):format(f))
    else
        print(("Written to: %s"):format(fname))
        f:write(text)
        f:close()
    end
end

local out = nil
local i = 1
while i <= #_G.arg do
    if _G.arg[i] == "--out" then
        out = assert(_G.arg[i + 1], "--out <outfile> needed")
        i = i + 1
    end
    i = i + 1
end

local libraries = {
    [["./.libraries/busted/library/"]],
    [["./.libraries/luassert/library/"]],
    [["./.libraries/luv/library/"]],
    '"' .. vim.fn.expand("$VIMRUNTIME" .. "/lua", false, true)[1] .. '"',
}

local lines = {
    "{",
    [[  "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",]],
    [[  "runtime.version": "LuaJIT",]],
}
table.insert(lines, '  "workspace.library": [\n    ' .. table.concat(libraries, ",\n    ") .. "\n  ]")
table.insert(lines, "}")

tofile(out, table.concat(lines, "\n"))
