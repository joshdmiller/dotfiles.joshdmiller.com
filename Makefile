# Helper Commands
SHOCCO = shocco
HYAKKO = hyakko

# Target Information
DOTFILES_PATH ?= $(CURDIR)/../dot-files
SUFFIX = .html

all: clean prepare bash xmonad

clean:
	rm -rf home/*
	rm -rf etc/*

prepare:
	mkdir -p home/bash
	mkdir -p home/xmonad/bin

home/bash%:
	$(SHOCCO) $(DOTFILES_PATH)/$@ > $(@D)/$(@F)$(SUFFIX)

# TODO: process the docs to remove stylesheets and other nonsense
bash: home/bashrc home/bash/alias home/bash/completion home/bash/dircolors home/bash/functions home/bash/prompt

# TODO: process the docs to remove stylesheets and other nonsense
xmonad:
	$(HYAKKO) $(DOTFILES_PATH)/home/xmonad/xmonad.hs
	mv docs/xmonad.html $(CURDIR)/home/xmonad/xmonad.hs$(SUFFIX)
	rm -rf docs

