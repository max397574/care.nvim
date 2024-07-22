-- usage: `$ nvim --clean --headless -c "set runtimepath+=." -l spec/benches/menu/draw.lua`
require("care").setup()
local core = require("care.core").new()
local entries = require("spec.data.entries").minimal(10000)
local start_time = os.clock()
core.menu:open(entries, 0)
print("Opening menu with 10000 minimal entries")
local end_time = os.clock()
local time_taken = end_time - start_time
print(time_taken, "s")
