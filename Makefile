# Helper Commands
SHOCCO = shocco
HYAKKO = hyakko

# Target Information
DOTFILES_PATH ?= $(CURDIR)/../dot-files
SUFFIX = .html

all: clean bash xmonad

clean:
	rm -rf home/*
	rm -rf etc/*

# TODO: change to patterns to avboid repetition
# TODO: process the docs to remove stylesheets and other nonsense
bash:
	mkdir -p home/bash
	$(SHOCCO) $(DOTFILES_PATH)/home/bashrc > $(CURDIR)/home/bashrc$(SUFFIX)
	$(SHOCCO) $(DOTFILES_PATH)/home/bash/alias > $(CURDIR)/home/bash/alias$(SUFFIX)
	$(SHOCCO) $(DOTFILES_PATH)/home/bash/completion > $(CURDIR)/home/bash/completion$(SUFFIX)
	$(SHOCCO) $(DOTFILES_PATH)/home/bash/dircolors > $(CURDIR)/home/bash/dircolors$(SUFFIX)
	$(SHOCCO) $(DOTFILES_PATH)/home/bash/functions > $(CURDIR)/home/bash/functions$(SUFFIX)
	$(SHOCCO) $(DOTFILES_PATH)/home/bash/prompt > $(CURDIR)/home/bash/prompt$(SUFFIX)

xmonad:
	mkdir -p home/xmonad/bin
	$(HYAKKO) $(DOTFILES_PATH)/home/xmonad/xmonad.hs
	mv docs/xmonad.html $(CURDIR)/home/xmonad/xmonad.hs$(SUFFIX)
	rm -rf docs

