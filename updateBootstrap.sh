#!/bin/bash
# ============================================================================
#
# FILE:         updateBootstrap.sh
#
# SPDX-FileCopyrightText: © 2020 Alias Developers
# SPDX-FileCopyrightText: © 2016 SpectreCoin Developers
# SPDX-License-Identifier: MIT
#
# DESCRIPTION:  Helper script to update bootstrap data automatically
#
# AUTHOR:       HLXEasy
# PROJECT:      https://alias.cash/
#               https://github.com/aliascash/bootstrap-updater
#
# ============================================================================

currentDate=$(date +%Y-%m-%d)
cd || exit

testnet1=''
testnet2=''
testnet3=''

# Check if testnet bootstrap should be created
if [[ $1 = '-t' ]] ; then
    shift
    echo "Creating bootstrap for TESTNET"
    testnet1='/testnet'
    testnet2='-Testnet'
    testnet3='-testnet'
fi

echo "Wipe out current bootstrap content"
rm -f ~/Alias${testnet2}-Blockchain-*.zip
rm -rf ~/bootstrap-data${testnet3}
mkdir -p ~/bootstrap-data${testnet3}/txleveldb
echo "Done"

echo "Stop Alias daemon"
sudo systemctl stop aliaswalletd${testnet3}
echo "Done"

echo "Copy current blockchain and transaction db"
cp ~/.aliaswallet${testnet1}/blk0001.dat ~/bootstrap-data${testnet3}/
cp ~/.aliaswallet${testnet1}/txleveldb/*.ldb ~/.aliaswallet${testnet1}/txleveldb/*.log ~/.aliaswallet${testnet1}/txleveldb/CURRENT ~/.aliaswallet${testnet1}/txleveldb/MANIFEST-* ~/bootstrap-data${testnet3}/txleveldb/
echo "Done"

echo "Start Alias daemon"
sudo systemctl start aliaswalletd${testnet3}
echo "Done"

echo "Create bootstrap archive"
cd ~/bootstrap-data${testnet3} || exit
zip ~/Alias${testnet2}-Blockchain-"${currentDate}".zip -r .
cd - >/dev/null || exit
echo "Done"

if [[ $1 = '-u' ]] ; then
    shift
    echo "Upload bootstrap archive"
    scp ~/Alias${testnet2}-Blockchain-"${currentDate}".zip jenkins@download.alias.cash:/var/www/html/files/bootstrap/
    echo "Updating download link"
    # shellcheck disable=SC2029
    ssh jenkins@download.alias.cash "cd /var/www/html/files/bootstrap/ && rm -f BootstrapChain${testnet2}.zip && ln -s Alias${testnet2}-Blockchain-${currentDate}.zip BootstrapChain${testnet2}.zip"
    echo "Done"
fi
