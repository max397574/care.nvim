local Health = {}

function Health.check_format(format_function)
    local errors = {}
    local format_entry_is_correct = true
    if not format_function then
        vim.health.error("No format entry function found")
    else
        ---@diagnostic disable-next-line: missing-fields
        local formatted = format_function({
            completion_item = {
                label = "my item",
            },
            ---@diagnostic disable-next-line: missing-fields
            source = {
                ---@diagnostic disable-next-line: missing-fields
                source = {
                    name = "test_name",
                    display_name = "test name",
                },
            },
        }, {
            index = 3,
            deprecated = false,
            source_name = "test",
            -- source_display_name = "test 2",
        })
        if type(formatted) ~= "table" then
            table.insert(errors, "Format entry doesn't return a table")
            format_entry_is_correct = false
        else
            for i, chunks in ipairs(formatted) do
                if type(chunks) ~= "table" then
                    table.insert(errors, "Format entry chunks " .. i .. " isn't a table")
                    format_entry_is_correct = false
                else
                    for j, chunk in ipairs(chunks) do
                        if type(chunk) ~= "table" then
                            table.insert(errors, "Format entry chunk " .. j .. " in chunks " .. i .. " isn't a table")
                            format_entry_is_correct = false
                        elseif #chunk ~= 2 then
                            table.insert(
                                errors,
                                "Format entry chunk " .. j .. " in chunks " .. i .. " doesn't have two fields"
                            )
                            format_entry_is_correct = false
                        elseif not (type(chunk[1]) == "string" and type(chunk[2]) == "string") then
                            table.insert(
                                errors,
                                "Format entry chunk " .. j .. " in chunks " .. i .. " doesn't have two string fields"
                            )
                            format_entry_is_correct = false
                        end
                    end
                end
            end
        end
    end
    return format_entry_is_correct, errors
end

function Health.check()
    require("care").setup()
    vim.api.nvim_exec_autocmds("InsertEnter", {})
    vim.health.start("care.nvim")
    vim.health.info("Checking configuration...")
    vim.health.info("Format entry function:")
    local format_entry = require("care.config").options.ui.menu.format_entry
    local is_correct, errors = Health.check_format(format_entry)
    if is_correct then
        vim.health.info("Format entry function returns correct value")
    else
        for _, error in ipairs(errors) do
            vim.health.error(error)
        end
    end
    vim.health.info("Aligments:")
    local wrong_aligments = false
    for i, alignment in ipairs(require("care.config").options.ui.menu.alignments) do
        if not vim.tbl_contains({ nil, "left", "right", "center" }, alignment) then
            vim.health.error(
                "Field number " .. i .. ' in the aligments table is an invalid aligment ("' .. alignment .. '")'
            )
            wrong_aligments = true
        end
    end
    if not wrong_aligments then
        vim.health.info("All alignments are correct")
    end
    vim.health.info("")
    vim.health.info("Checking dependencies...")
    local has_fzy = (pcall(require, "fzy"))
    if not has_fzy then
        vim.health.error("Critical: dependency 'fzy' not found")
        vim.health.info("Check installation instructions for you package manager in the documentation")
    else
        vim.health.info("Dependency 'fzy' found")
    end
end

return Health
