# Helper Commands
DOCTOOL  = pyccoplus

# Target Information
DOTFILES_PATH ?= $(CURDIR)/../dot-files
SUFFIX = .html

# Definitions of Sources
# TODO change from phony targets to real targets
DOTFILES := home/bashrc home/bash/alias home/bash/completion home/bash/functions home/bash/prompt home/xmonad/bin/volume.sh install.sh home/Xresources home/xmonad/xmonad.hs home/vimrc

# TODO home/bash/dircolors home/xmonad/bin/conky_bar_bottom_left home/xmonad/bin/conky_bar_bottom_right home/xmonad/bin/conky_bar

.PHONY: all clean prepare $(DOTFILES)

all: clean prepare $(DOTFILES)

clean:
	rm -rf home/*
	rm -rf etc/*
	rm -f install.sh.html

prepare:
	mkdir -p home/bash
	mkdir -p home/xmonad/bin

$(DOTFILES): 
	$(DOCTOOL) $(DOTFILES_PATH)/$@
	$(eval BASENAME := $(basename $(@F)))
	sed -i '/<!DOCTYPE html>/,/<body>/d' docs/$(BASENAME)$(SUFFIX)
	sed -i 's/<\/body>//' docs/$(BASENAME)$(SUFFIX)
	sed -i 's/<\/html>//' docs/$(BASENAME)$(SUFFIX)
	sed -i 's/<div id=background><\/div>//' docs/$(BASENAME)$(SUFFIX)
	mv docs/$(BASENAME)$(SUFFIX) $(@D)/$(@F)$(SUFFIX)

