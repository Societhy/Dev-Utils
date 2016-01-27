mkdir $HOME/.ethereum/societhest

git clone git@github.com:Societhy/Dev-Utils.git

cd Dev-Utils

chmod +x ethcluster.sh

cp genesis.json $HOME/.ethereum/societhest

ln ethcluster.sh /usr/local/bin/ethcluster
