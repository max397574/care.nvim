## Running tests locally

You can run tests locally, if you have [`luarocks`](https://luarocks.org/) or
`busted` installed[^1].

[^1]:
    The test suite assumes that `nlua` has been installed using luarocks into
    `~/.luarocks/bin/`.

You can then run:

```bash
make test
```

Or if you want to run a single test file:

```bash
luarocks test spec/mytest_spec.lua --local
# or
busted spec/mytest_spec.lua
```

If you see a `module 'busted.runner'` not found error you need to update your
`LUA_PATH`:

```bash
eval $(luarocks path --no-bin)
busted --lua nlua spec/mytest_spec.lua
```

## Documentation

Documentation is mostly generated from lua-ls annotation files in the
`lua/care/types/` folder. So these should be updated to change type
descriptions.

If there are issues with the generated docs the script to generate them under
`scripts/docs.lua` should be modified.

## Formatting

For formatting stylua is used. If you have stylua installed you can use

```bash
make format
```

## Type annotations

For type annotations it is recommended to use lazydev.nvim. It can be setup with
the following options:

```lua
{
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
        library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "luvit-meta/library", words = { "vim%.uv" } },
            { path = "luassert/library", words = { "assert" } },
            { path = "busted/library", words = { "describe", "it" } },
            { path = "care.nvim/lua/care/types/" },
        },
    },
},
{ "Bilal2453/luvit-meta", lazy = true },
{ "LuaCATS/busted", lazy = true },
{ "LuaCATS/luassert", lazy = true },
```

## Nix dev environment

For nix users, all of these tools are made available in a dev shell.

Run

```bash
nix develop
```

You can test-drive a minimal Neovim package with only care.nvim and its
dependencies installed by running

```bash
nix run .#nvim
```

# Debugging tricks
Print out source configurations:
`:lua =vim.iter(require"care.sources".sources):map(function(source) return source.config end):totable()`
