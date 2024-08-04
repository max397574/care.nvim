# Code style

## Object-Orientation

Most of the modules are written object oriented. This decision was made because
it's way easier to create new instances of the things and associate data with
them.

The tables of which the modules consist should be named with uppercase letters
(e.g. `Menu`). This should be done in the definition and when using them.
Instances should use lowercase letters.

## Functions

You should always write functions in the form of
`[local] function <name>(<parameters>)` as opposed to
`[local <name> = function(<parameters>)`. The first notation provides the
advantage that you can directly jump to it's definition and you won't get
multiple results (the name and the anonymous function).

## Comments and annotations

Add annotations to **every** public function of a module (e.g. with neogen) and
add comments explaining what the code does. We'd like to have code which would
be understandable for outsiders. Also try to add annotations and descriptions to
local functions but this isn't as important as public ones

### Format

For The annotations we use [LuaCATS](https://luals.github.io/wiki/annotations/)
style. For types don't use a space after the `---` marker. For comments you
should. Check the annotations in `lua/care/types/` for examples.

## Types

We have files for types which are tangled from a norg file (this one?) using
lua-ls annotations. They are prefixed with `care.`. As often as possible we
should try to use the `lsp.*` types which are in neovim core.

The types are documented in the `docs/` folder and are tangled to lua type files
with [neorg](https://github.com/nvim-neorg/neorg). So if you want to change a
type annotation you should change the `.norg` file and tangle it again.
