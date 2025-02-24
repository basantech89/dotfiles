.PHONY: all fish neovim starship warp zsh delete delete_fish delete_neovim delete_starship delete_warp delete_zsh

all:
	stow --verbose --target=$$HOME --restow */

fish:
	stow --verbose --target=$$HOME --restow fish

neovim:
	stow --verbose --target=$$HOME --restow nvim

starship:
	stow --verbose --target=$$HOME --restow starship

warp:
	stow --verbose --target=$$HOME --restow warp

zsh:
	stow --verbose --target=$$HOME --restow zsh

delete:
	stow --verbose --target=$$HOME --delete */

delete_fish:
	stow --verbose --target=$$HOME --delete fish

delete_neovim:
	stow --verbose --target=$$HOME --delete nvim

delete_starship:
	stow --verbose --target=$$HOME --delete starship

delete_warp:
	stow --verbose --target=$$HOME --delete warp

delete_zsh:
	stow --verbose --target=$$HOME --delete zsh
