# !/bin/bash

mkdir $HOME/.ethereum/societhest

cp $HOME/.ethereum/geth.ipc $HOME/.ethereum/societhest

cp genesis.json $HOME/.ethereum/societhest

dir=`pwd`

cd /usr/local/bin/

ln -s dir/ethcluster.sh ./ethcluster

cd $dir
