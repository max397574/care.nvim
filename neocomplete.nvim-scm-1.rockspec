rockspec_format = '3.0'
package = "neocomplete.nvim"
version = "scm-1"
source = {
  url = "git+https://github.com/max397574/neocomplete.nvim"
}
dependencies = {
  "fzy",
}
test_dependencies = {
  "nlua",
  "fzy",
}
build = {
  type = "builtin",
  copy_directories = {
    "docs",
    "plugin",
  },
}
