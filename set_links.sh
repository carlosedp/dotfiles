echo "Setting dotfiles on ~/"
echo `pwd`

for FILE in `pwd`/rc/*
do
    ln -sf $FILE ~/.$(basename $FILE)
done

ln -sf ~/Google\ Drive/Configs/ssh ~/.ssh
