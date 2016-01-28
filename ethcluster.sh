# !/bin/zsh

datadir=$HOME/.ethereum/societhest

help()
{
    echo USAGE:
    echo "	ethcluster [options] command [arguments]"
    echo
    echo COMMANDS:
    echo "	create	<N>		créé N noeuds connectés sur un réseau privé"
    echo "	attach	<N>		connection à l'API json-rpc du noeud N"
    echo "	kill			détruit le cluster"
    echo "	deploy	<N> <contract>	déploie le contract sur la blockchain privée depuis le noeud N !!!!!!!!!!!!! NON IMPLÉMENTÉ"
    echo
    echo OPTIONS:
    echo "	--unlock		les comptes des noeuds sont unlock au lancement !!!! NON IMPLÉMENTÉ"
    echo "	--mine			les noeuds minent au lancement !!!! NON IMPLÉMENTÉ"
    echo "	--dir </path/to/dir>	dossier ou sont stockés les clefs et la blockchain !!!! NON IMPLÉMENTÉ"
    echo
}

kill()
{
    killall -QUIT geth
}

attach()
{
    geth attach rpc:http://localhost:810$1
}

cluster()
{
    truncate -s 0 /tmp/clusterEnodes
    local nodes=$(($1 + 1))
    
    for ((i=1 ; i<nodes; ++i)); do
    	echo 'launching node '$i'...'
    	cmd="geth --genesis $datadir/genesis.json --datadir $datadir/0$i --ipcpath $datadir/geth.ipc --port 4030$i --rpc --rpcapi admin,eth,miner --rpcport 810$i --networkid 8587"
    	nohup $cmd &>/dev/null &
    	sleep 3
    	geth --exec "admin.nodeInfo.enode" attach ipc:$datadir/geth.ipc >> /tmp/clusterEnodes
    done
    
    for ((i=1 ; i<nodes; ++i)); do
    	exclude=1
    	while read -r enode; do
    	    if [ "$i" -ne "$exclude" ]; then
    		echo "connecting node" $i "to enode" $enode
    		nohup geth --exec "admin.addPeer($enode)"  attach rpc:http://localhost:810$i &>/dev/null &
    	    fi
    	    ((exclude+=1))
    	done < /tmp/clusterEnodes
    done
}

if [ "$1" = "create" ]; then
    cluster $2
elif [ "$1" = "attach" ]; then
    attach $2
elif [ "$1" = "kill" ]; then
    kill
else
    help
fi
