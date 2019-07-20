#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

COIN_DAEMON='electrad'
COIN_NAME='Electra'
COIN_TGZ='https://github.com/Electra-project/electra-core/releases/download/2.1.0/RPI-Electra-QT-2.1.0.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')

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
sudo rm $COIN_TGZ
echo
echo "Giving files correct permissions..."
sudo chmod +x electra-cli electra-tx electrad
echo
echo "Would you like to enable the wallet on startup? Recommeneded incase of power failures. Passphrase is still required for moving coins."

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
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
}

# Add some choice stuff here


# Add run wallet
# Add encrypt wallet
# Add unlock wallet
# Add swap
# Add function to not show history of commands entered to protect users info
# Add Quick Menu Option to take picture with phone or make easy to pull, add index or things to repair blockchain
# Make sure they run this script as sudo / maybe even root!
# Make sure it runs on a restart (maybe add -index in?)



