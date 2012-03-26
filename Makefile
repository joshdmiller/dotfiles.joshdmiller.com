# Helper Commands
SHOCCO = shocco
HYAKKO = hyakko

# Target Information
DOTFILES_PATH ?= $(CURDIR)/../dot-files
SUFFIX = .html

# Definitions of Sources
SHELL_SCRIPTS := home/bashrc home/bash/alias home/bash/completion home/bash/dircolors home/bash/functions home/bash/prompt home/xmonad/bin/volume.sh home/xmonad/bin/conky_bar_bottom_left home/xmonad/bin/conky_bar_bottom_right home/xmonad/bin/conky_bar

.PHONY: all clean bash xmonad $(SHELL_SCRIPTS)

all: clean prepare bash xmonad

clean:
	rm -rf home/*
	rm -rf etc/*

prepare:
	mkdir -p home/bash
	mkdir -p home/xmonad/bin

$(SHELL_SCRIPTS):
	$(SHOCCO) $(DOTFILES_PATH)/$@ > $(@D)/$(@F)$(SUFFIX)
	sed -i '/<!DOCTYPE html>/,/<body>/d' $(@D)/$(@F)$(SUFFIX)
	sed -i 's/<\/body>//' $(@D)/$(@F)$(SUFFIX)
	sed -i 's/<\/html>//' $(@D)/$(@F)$(SUFFIX)
	sed -i 's/<div id=background><\/div>//' $(@D)/$(@F)$(SUFFIX)

bash: home/bashrc home/bash/alias home/bash/completion home/bash/dircolors home/bash/functions home/bash/prompt

xmonad: home/xmonad/bin/volume.sh home/xmonad/bin/conky_bar_bottom_left home/xmonad/bin/conky_bar_bottom_right home/xmonad/bin/conky_bar
	$(HYAKKO) $(DOTFILES_PATH)/home/xmonad/xmonad.hs
	sed -i 's/<\/body>//' docs/xmonad.html
	sed -i 's/<\/html>//' docs/xmonad.html
	sed -i 's/<div id="background"><\/div>//' docs/xmonad.html
	sed '/<!DOCTYPE html>/,/<body>/d' docs/xmonad.html > $(CURDIR)/home/xmonad/xmonad.hs$(SUFFIX)
	rm -rf docs

