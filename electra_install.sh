#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

COIN_DAEMON='electrad'
COIN_NAME='Electra'
COIN_TGZ='https://github.com/Electra-project/electra-core/releases/download/2.1.0/RPI-Electrad-CLI-TX-2.1.0.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
CONFIG_FILE='electra.conf'
CONFIGFOLDER='/root/.Electra'

clear
echo
echo "Automated download and run script for Electra Wallet created by: Electra User Support Team"
echo

read -p "Press [Enter] to continue setup."

echo
echo
echo "Changing location to /usr/local/bin..."
cd /usr/local/bin
echo
echo "Downloading file..."
echo
sudo wget -q $COIN_TGZ --no-check-certificate
echo
echo "Obtaining unzip program if not installed already..."
sudo apt-get install unzip
echo
echo "Unzipping file..."
echo
unzip $COIN_ZIP
echo
echo "Deleting zip file..."
sudo rm $COIN_ZIP
echo
echo "Giving files correct permissions..."
sudo chmod +x electra-cli electra-tx electrad
echo
while true; do
    read -p "Would you like to enable the wallet on startup? Recommeneded incase of power failures. Passphrase is still required for moving coins." yn
    case $yn in
        [Yy]* ) function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
ExecStart=$COIN_PATH$COIN_DAEMON -daemon -reindex -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
} break;;
        [Nn]* ) exit;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

 echo -e "Checking if swap space is needed."
 PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
 SWAP=$(swapon -s)
 if [[ "$PHYMEM" -lt "2"  &&  -z "$SWAP" ]]
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "${GREEN}The server running with at least 2G of RAM, or a SWAP file is already in place.${NC}"
 fi
 clear

mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
#rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF

clear

sudo cp ~/.electra/wallet.dat ~/Documents

# Add wallet is ready to use and common functions here!

# confirm reindex works properly or remove it takes too long
# Add function to not show history of commands entered to protect users info
# Add Quick Menu Option to take picture with phone or make easy to pull, add index or things to repair blockchain
# Make sure they run this script as sudo / maybe even root!
# Make sure it runs on a restart (maybe add -index in?)
# Create backup
# wallet needs full sync before staking check against blockexplorer
# add auto unlock wallet after restart



