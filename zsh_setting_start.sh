#!/bin/sh

if [ -x "$(command -v git)" ]
then
	echo "git is installed"
else
	echo "git is not installed" >&2
	exit 1
fi


sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "add plugins zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "add plugins zsh-syntax-highlighting"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "add ZSH_THEME=powerlevel10k/powerlevel10k in /.zshrc"
echo "and then install font"
echo "https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"

cp ./zshrc ~/.zshrc

zsh
