rockspec_format = '3.0'
package = "care.nvim"
version = "scm-1"
source = {
  url = "git+https://github.com/max397574/care.nvim"
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
