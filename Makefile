.PHONY: test cover build release install format

i install d deps:
	mix deps.get

t test:
	mix test

c cover:
	mix test --cover

b build:
	make install
	export MIX_ENV=dev && mix escript.build

r release:
	make install
	export MIX_ENV=prod && mix escript.build

f format:
	mix format
