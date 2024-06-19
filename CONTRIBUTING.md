## Running tests locally

You can run tests locally,
if you have [`luarocks`](https://luarocks.org/) or `busted` installed[^1].

[^1]: The test suite assumes that `nlua` has been installed
      using luarocks into `~/.luarocks/bin/`.

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

If you see a `module 'busted.runner'` not found error you need to update your `LUA_PATH`:

```bash
eval $(luarocks path --no-bin)
busted --lua nlua spec/mytest_spec.lua
```

## Formatting
For formatting stylua is used.
If you have stylua installed you can use
```bash
make format
```

## Type annotations
You can get third party libraries for type annotations by doing
```bash
make install_libraries
```

Then use
```bash
make gen_luarc
```
from the root directory of this repo to generate a `.luarc.json` file to configure luals to use the type annotations.

These two steps can be executed together with
```bash
make dev_setup
```

## Nix dev environment

For nix users, all of these tools are made available in a dev shell.

Run
```bash
nix develop
```

You can test-drive a minimal Neovim package with only neocomplete.nvim and its dependencies
installed by running
```bash
nix run .#nvim
```
