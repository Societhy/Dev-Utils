#!/bin/bash

help()
{
    echo USAGE:
    echo "	ethcluster [options] command [arguments]"
    echo
    echo COMMANDS:
    echo "	create	<N>		créé N noeuds connectés sur un réseau privé"
    echo "	attach	<N>		connection à l'API json-rpc du noeud N"
    echo "	kill			détruit le cluster"
    echo
    echo OPTIONS:
    echo "	--unlock		les comptes des noeuds sont unlock au lancement"
    echo "	--mine			les noeuds minent au lancement"
    echo "	--dir </path/to/dir>	dossier ou sont stockés les clefs et la blockchain"
    echo
}

kill()
{
    sudo killall -QUIT geth
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
    	nohup sudo geth --genesis $datadir/genesis.json --datadir $datadir/0$i --ipcpath $datadir/geth.ipc --port 4030$i --rpc --rpcport 810$i --rpcapi "web3,admin,eth,personal,net" --rpccorsdomain '*' --networkid 8587 $mine $unlock &>/dev/null &
	mine=''
    	sleep 5
    	addr=`sudo geth --exec "admin.nodeInfo.enode" attach rpc:http://localhost:810$i | grep \"` 
    	echo $addr >> /tmp/clusterEnodes
    done
    
    for ((i=1 ; i<nodes; ++i)); do
    	exclude=1
    	while read -r enode; do
    	    if [ "$i" -ne "$exclude" ]; then
    		echo "connecting node" $i "to enode" $enode
    		sudo geth --exec "admin.addPeer($enode)"  attach rpc:http://localhost:810$i
    		sleep 1
    	    fi
    	    ((exclude+=1))
    	done < /tmp/clusterEnodes
    done
}

mine=''
unlock=''
usrdir=$HOME
datadir=$usrdir/.ethereum/societhest
ethdir=$usrdir/.ethereum
nbArg=$#
for ((i=0; i<nbArg; ++i)); do
    if [ "$1" = "create" ]; then
	sudo ls>/dev/null
	cluster $2
	break
    elif [ "$1" = "attach" ]; then
	attach $2
	break
    elif [ "$1" = "kill" ]; then
	sudo ls>/dev/null
	kill
	break
    elif [ "$1" = "--mine" ]; then
	mine="--mine --minerthreads 1"
    elif [ "$1" = "--unlock" ]; then
	unlock="--unlock 0 --password /dev/null"
    elif [ "$1" = "--dir" ]; then
	datadir=$2
	shift
    else
	help
    fi
    shift
done
