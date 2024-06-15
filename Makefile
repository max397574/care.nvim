test:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local)" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	luarocks test --local --lua-version 5.1

install_libraries:
	-rm -rf .libraries/
	git clone https://github.com/LuaCATS/busted ./.libraries/busted
	git clone https://github.com/LuaCATS/luassert ./.libraries/luassert
	git clone https://github.com/LuaCATS/luv ./.libraries/luv
