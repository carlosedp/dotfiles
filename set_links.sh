echo "Setting dotfiles on ~/"
echo `pwd`

for FILE in `pwd`/rc/*
do
    if [[ -f ~/.$(basename $FILE) || -d ~/.$(basename $FILE) ]] && [ ! -L ~/.$(basename $FILE) ]; then
      mv ~/.$(basename $FILE) ~/.$(basename $FILE)-old
    fi
    ln -sf $FILE ~/.$(basename $FILE)
done

ln -sf ~/Google\ Drive/SSH_Keys ~/.ssh
