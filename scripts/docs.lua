-- TODO: a list of stuff to be substituted for links
-- so e.g. to the source:complete() method a link to care.entry would be added
-- the link should be on a line below the annotations
local function read_file(path)
    local file = assert(io.open(path, "r"))
    ---@type string
    return file:read("*a")
end

local function write_file(path, contents)
    local file = assert(io.open(path, "w+"))
    file:write(contents)
    file:close()
end

local function extract_match(path, pattern)
    return read_file(path):match(pattern)
end

local function read_classes(path)
    local contents = read_file(path)
    local classes = {}
    local class_strings = vim.split(contents, "\n\n")
    for i, class_string in ipairs(class_strings) do
        local class_desc =
            table.concat(vim.split(class_string:match("%-%-%- (.-)\n%-%-%-@class") or "", "\n%-%-%- "), "\n")
        local class_name = class_string:match("%-%-%-@class (.-)\n")
        local fields_string = class_string:match(".-%-%-%-@class .-\n(.*)")
        local fields = { { descriptions = {} } }
        local field_index = 1
        -- print("====")
        -- print(class_string)
        vim.iter(vim.split(fields_string, "\n")):each(function(line)
            if vim.startswith(line, "---@field") then
                fields[field_index].annotation = line:match("%-%-%-@field (.*)")
                fields[field_index].name = line:match("%-%-%-@field (..-) ")
                field_index = field_index + 1
                fields[field_index] = {}
                fields[field_index].descriptions = {}
            else
                table.insert(fields[field_index].descriptions, line:match("--- (.*)"))
            end
        end)
        table.remove(fields, #fields)
        classes[i] = {
            desc = class_desc,
            name = class_name,
            fields = {},
            methods = {},
        }
        for _, field in ipairs(fields) do
            if field.annotation:find("fun%(") then
                table.insert(classes[i].methods, field)
            else
                table.insert(classes[i].fields, field)
            end
        end
    end
    return classes
end

local docs_files = {
    { type_file = "lua/care/types/window.lua", doc_file = "docs/dev/window.md", title = "Window Util" },
    { type_file = "lua/care/types/core.lua", doc_file = "docs/dev/core.md", title = "Core" },
    { type_file = "lua/care/types/menu.lua", doc_file = "docs/dev/menu.md", title = "Menu" },
    { type_file = "lua/care/types/entry.lua", doc_file = "docs/dev/entry.md", title = "Entry" },
    { type_file = "lua/care/types/source.lua", doc_file = "docs/dev/source.md", title = "Source" },
    {
        type_file = "lua/care/types/internal_source.lua",
        doc_file = "docs/dev/internal_source.md",
        title = "Internal Source",
    },
    { type_file = "lua/care/types/context.lua", doc_file = "docs/dev/context.md", title = "Context" },
}

local function gen_title(input)
    local spaced = input:gsub("_", " ")
    local capitalized = spaced:gsub("(%a+)", function(c)
        return c:sub(1, 1):upper() .. c:sub(2)
    end)
    return capitalized
end

local function cleanup_annotation(short_class_name, annotation)
    local function substitute_fun(anno)
        if not anno:find("fun%(") then
            return anno
        end
        if annotation:find("fun%(self:") then
            if annotation:find(",") then
                return annotation:gsub(" fun%(self: .-, ", "(", 1)
            else
                return annotation:gsub(" fun%(self: .-%)", "()", 1)
            end
        else
            return annotation:gsub(" fun%(", "(", 1)
        end
    end
    -- `new` should be the only function which isn't called on an instance
    -- So uppercase letter is used
    if annotation:find("new fun") then
        short_class_name = short_class_name:sub(1, 1):upper() .. short_class_name:sub(2)
    end
    -- Methods should use `:`
    if annotation:find("%(self: ") then
        return short_class_name .. ":" .. substitute_fun(annotation)
    else
        return short_class_name .. "." .. substitute_fun(annotation)
    end
end

local function get_class_docs(path, title)
    local classes = read_classes(path)
    local contents = {
        "---",
        "title: " .. title,
        "description: Type description of " .. table.concat(
            vim.iter(classes)
                :map(function(class)
                    return class.name
                end)
                :totable(),
            ", "
        ),
        "---",
        "# " .. title,
        "",
    }
    local function format_field(field, short_class_name)
        table.insert(contents, "")
        if field.name:sub(-1) == "?" then
            table.insert(contents, "## " .. gen_title(field.name:sub(1, -2)) .. " (optional)")
        else
            table.insert(contents, "## " .. gen_title(field.name))
        end
        table.insert(contents, "`" .. cleanup_annotation(short_class_name, field.annotation) .. "`")
        table.insert(contents, "")
        table.insert(contents, table.concat(field.descriptions, "\n"))
    end
    for _, class in ipairs(classes) do
        -- table.insert(contents, "#" .. class_titles[class.name])
        table.insert(contents, class.desc, "\n")
        table.insert(contents, "# `" .. class.name .. "`\n")
        local short_class_name = class.name:match("care%.(.*)")
        if #class.methods > 0 then
            table.insert(contents, "# Methods")
            for _, field in ipairs(class.methods) do
                format_field(field, short_class_name)
            end
        end
        if #class.fields > 0 then
            table.insert(contents, "# Fields")
            for _, field in ipairs(class.fields) do
                format_field(field, short_class_name)
            end
        end
    end
    return contents
end

local function write_class_docs()
    for _, docs in ipairs(docs_files) do
        local contents = get_class_docs(docs.type_file, docs.title)
        write_file(docs.doc_file, table.concat(contents, "\n"))
    end
end
local function write_config_docs()
    local default_config = extract_match("lua/care/config.lua", "\n(---@type care.config\nconfig.defaults.-\n})")
    local default_config_block = table.concat({
        "",
        "<details>",
        "  <summary>Full Default Config</summary>",
        "",
        "```lua",
        default_config,
        "```",
        "",
        "</details>",
    }, "\n")
    local config_class = get_class_docs("lua/care/types/config.lua", "Config")
    table.insert(config_class, 6, default_config_block)
    config_class[3] = "description: Configuration for care.nvim"
    write_file("docs/config.md", table.concat(config_class, "\n"))
end

write_class_docs()
write_config_docs()
