echo "Setting dotfiles on ~/"
echo `pwd`

for FILE in aliases bashrc erlang gitconfig gitignore inputrc screenrc vimrc conf profile
do
    ln -sf `pwd`/$FILE ~/.$FILE
done
# chsh -s /bin/zsh
