-- parts of the code adapted from https://github.com/hrsh7th/cmp-path

local NAME_REGEX = "\\%([^/\\\\:\\*?<>'\"`\\|]\\)"
local PATH_REGEX =
    vim.regex(([[\%(\%(/PAT*[^/\\\\:\\*?<>\'"`\\| .~]\)\|\%(/\.\.\)\)*/\zePAT*$]]):gsub("PAT", NAME_REGEX))

local path_source = {}

function path_source.setup()
    require("care.sources").register_source(path_source.new())
end

local function has_slash_comment()
    local commentstring = vim.bo.commentstring or ""
    local no_filetype = vim.bo.filetype == ""
    local is_slash_comment = false
    is_slash_comment = is_slash_comment or commentstring:match("/%*")
    is_slash_comment = is_slash_comment or commentstring:match("//")
    return is_slash_comment and not no_filetype
end

local function get_dirname(line_before_cursor, bufnr)
    local s = PATH_REGEX:match_str(line_before_cursor)
    if not s then
        return nil
    end

    local dirname = string.gsub(string.sub(line_before_cursor, s + 2), "%a*$", "") -- exclude '/'
    local prefix = string.sub(line_before_cursor, 1, s + 1) -- include '/'

    local buf_dirname = vim.fn.expand(("#%d:p:h"):format(bufnr))
    if vim.api.nvim_get_mode().mode == "c" then
        buf_dirname = vim.fn.getcwd()
    end
    if prefix:match("%.%./$") then
        return vim.fn.resolve(buf_dirname .. "/../" .. dirname)
    end
    if prefix:match("%./$") or prefix:match('"$') or prefix:match("'$") then
        return vim.fn.resolve(buf_dirname .. "/" .. dirname)
    end
    if prefix:match("~/$") then
        return vim.fn.resolve(vim.fn.expand("~") .. "/" .. dirname)
    end
    local env_var_name = prefix:match("%$([%a_]+)/$")
    if env_var_name then
        local env_var_value = vim.fn.getenv(env_var_name)
        if env_var_value ~= vim.NIL then
            return vim.fn.resolve(env_var_value .. "/" .. dirname)
        end
    end
    if prefix:match("/$") then
        local accept = true
        -- Ignore URL components
        accept = accept and not prefix:match("%a/$")
        -- Ignore URL scheme
        accept = accept and not prefix:match("%a+:/$") and not prefix:match("%a+://$")
        -- Ignore HTML closing tags
        accept = accept and not prefix:match("</$")
        -- Ignore math calculation
        accept = accept and not prefix:match("[%d%)]%s*/$")
        -- Ignore / comment
        accept = accept and (not prefix:match("^[%s/]*$") or not has_slash_comment())
        if accept then
            return vim.fn.resolve("/" .. dirname)
        end
    end
    return nil
end

local function get_candidates(dirname, options, callback)
    local fs, err = vim.uv.fs_scandir(dirname)
    if err or not fs then
        return callback(err, nil)
    end

    local items = {}

    local function create_item(name, fs_type)
        if not (options.include_hidden or string.sub(name, 1, 1) ~= ".") then
            return
        end

        local path = dirname .. "/" .. name
        local stat = vim.uv.fs_stat(path)
        local lstat = nil
        if stat then
            fs_type = stat.type
        elseif fs_type == "link" then
            -- Broken symlink
            lstat = vim.uv.fs_lstat(dirname)
            if not lstat then
                return
            end
        else
            return
        end

        local item = {
            label = name,
            filterText = name,
            insertText = name,
            kind = 17, -- file
            data = {
                path = path,
                type = fs_type,
                stat = stat,
                lstat = lstat,
            },
        }
        if fs_type == "directory" then
            item.kind = 19 -- folder
            item.label = name
            if options.trailing_slash then
                item.insertText = name .. "/"
            else
                item.insertText = name
            end
        end
        table.insert(items, item)
    end

    while true do
        local name, fs_type, e = vim.uv.fs_scandir_next(fs)
        if e then
            return callback(fs_type, nil)
        end
        if not name then
            break
        end
        create_item(name, fs_type)
    end

    callback(nil, items)
end

function path_source.new()
    -- local include_hidden = string.sub(context.context.line_before_cursor, context.offset, params.offset) == "."
    -- TODO: make configurable
    local options = {
        include_hidden = false,
        trailing_slash = true,
    }
    ---@type care.source
    local source = {
        name = "path",
        display_name = "path",
        keyword_pattern = NAME_REGEX .. "*",
        ---@param context care.completion_context
        complete = function(context, callback)
            local dirname = get_dirname(context.context.line_before_cursor, context.context.bufnr)
            if not dirname then
                return callback({})
            end
            get_candidates(dirname, options, function(err, candidates)
                if err then
                    return callback({})
                end
                callback(candidates)
            end)
        end,
        get_trigger_characters = function()
            return { ".", "/" }
        end,
        is_available = function()
            return true
        end,
        -- TODO: display file contents in documentation
        resolve_item = nil,
    }
    return source
end

return path_source
