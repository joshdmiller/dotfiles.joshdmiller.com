# Helper Commands
DOCTOOL = pyccoplus
MKD	= ./bin/mkd2html.py
COFFEE  = coffee
LESSC   = ~/Development/repos/less.js/bin/lessc

# Target Information
DOTFILES_PATH ?= $(CURDIR)/../dot-files
SUFFIX = .html

# Definitions of Sources
# TODO change from phony targets to real targets
DOTFILES := home/bashrc home/bash/alias home/bash/completion home/bash/functions home/bash/prompt home/xmonad/bin/volume.sh home/Xresources home/xmonad/xmonad.hs home/vimrc
READMES := README.markdown home/README.markdown
COFFEE_SCRIPTS := js/main.js
LESS_STYLES := css/main.css

# TODO home/bash/dircolors home/xmonad/bin/conky_bar_bottom_left home/xmonad/bin/conky_bar_bottom_right home/xmonad/bin/conky_bar

.PHONY: all clean prepare coffee less $(DOTFILES) $(READMES)

all: clean prepare $(DOTFILES) $(READMES)

clean:
	rm -rf dotfiles
	rm css/main.css
	rm js/main.js

prepare:
	mkdir -p dotfiles/home/bash
	mkdir -p dotfiles/home/xmonad/bin

coffee: js/main.js

less: css/main.css

$(COFFEE_SCRIPTS):
	$(eval BASENAME := $(basename $(@F)))
	$(COFFEE) -cl $(@D)/$(BASENAME).coffee > $@

$(LESS_STYLES):
	$(eval BASENAME := $(basename $(@F)))
	$(LESSC) $(@D)/$(BASENAME).less > $@
	
$(DOTFILES): 
	$(DOCTOOL) $(DOTFILES_PATH)/$@
	$(eval BASENAME := $(basename $(@F)))
	sed -i '/<!DOCTYPE html>/,/<body>/d' docs/$(BASENAME)$(SUFFIX)
	sed -i 's/<\/body>//' docs/$(BASENAME)$(SUFFIX)
	sed -i 's/<\/html>//' docs/$(BASENAME)$(SUFFIX)
	sed -i 's/<div id=background><\/div>//' docs/$(BASENAME)$(SUFFIX)
	mv docs/$(BASENAME)$(SUFFIX) dotfiles/$(@D)/$(@F)$(SUFFIX)

$(READMES):
	mkdir -p docs/$(@D)
	$(MKD) $(DOTFILES_PATH)/$@ > docs/$(@D)/$(@F)$(SUFFIX)
	echo '<div class="noncode">' > dotfiles/$(@D)/$(@F)$(SUFFIX)
	cat docs/$(@D)/$(@F)$(SUFFIX) >> dotfiles/$(@D)/$(@F)$(SUFFIX)
	echo '</div>' >> dotfiles/$(@D)/$(@F)$(SUFFIX)

