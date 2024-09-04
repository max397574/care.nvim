local Health = {}

function Health.check()
    vim.health.start("neorg")
    vim.health.info("Checking configuration...")
    -- check format function with example entry and see if it returns valid thing
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
