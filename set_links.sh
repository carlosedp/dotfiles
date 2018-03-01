echo "Setting dotfiles on ~/"
cd ~/

for FILE in aliases bashrc erlang gitconfig gitignore inputrc screenrc ssh
do
    ln -sf ./$FILE ~/.$FILE
done
# chsh -s /bin/zsh
