test:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local)" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	luarocks test --local --lua-version 5.1

format:
	stylua lua/ spec/
