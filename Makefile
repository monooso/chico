.PHONY: install
install:
	asdf install
	mix deps.get
	git config core.hooksPath .githooks
