vim.g.loaded_care = false
if not vim.g.loaded_care then
    require("care").initialize()
    vim.g.loaded_care = true
end
