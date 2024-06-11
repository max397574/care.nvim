## Running tests locally

You can run tests locally,
if you have [`luarocks`](https://luarocks.org/) or `busted` installed[^1].

[^1]: The test suite assumes that `nlua` has been installed
      using luarocks into `~/.luarocks/bin/`.

You can then run:

```bash
luarocks test --local
# or
busted
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
