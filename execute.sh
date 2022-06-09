#!/bin/sh
echo "########## Sleeping to wait for Automatic Upgrades complete ###########"
sleep 180
echo "########## Awoke! Ready to procees with the Script ###########"

echo "##########Storage SAS###########: $RESULT_STORAGE_URL"
echo "##########VM Name###########: $VM_NAME"
echo "##########ITEM_COUNT_FOR_WRITE###########: $ITEM_COUNT_FOR_WRITE"
echo "##########MACHINE_INDEX###########: $MACHINE_INDEX"

insertstart=$((ITEM_COUNT_FOR_WRITE* (MACHINE_INDEX-1)))
recordcount=$((ITEM_COUNT_FOR_WRITE* MACHINE_INDEX))

#Install Software
echo "########## Installing azcopy ###########"
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

#Build YCSB from source and create a docker container
echo "##########Cloning YCSB ##########"
git clone -b addingDockerScripts --single-branch https://github.com/simplynaveen20/YCSB.git
cd  YCSB
echo "########## Building YCSB ##########"
mvn -pl site.ycsb:azurecosmos-binding -am clean package
cp -r  ./azurecosmos/target/ /tmp/ycsb
cp -r ./azurecosmos/conf/* /tmp/ycsb
cd /tmp/ycsb/
echo "########## Extracting YCSB binary ##########"
tar xfvz ycsb-azurecosmos-binding-0.18.0-SNAPSHOT.tar.gz
cp ./run.sh ./ycsb-azurecosmos-binding-0.18.0-SNAPSHOT
cp ./azurecosmos.properties ./ycsb-azurecosmos-binding-0.18.0-SNAPSHOT
cd ./ycsb-azurecosmos-binding-0.18.0-SNAPSHOT

#Execute YCSB test
echo "########## Executing YCSB tests###########"
uri="$COSMOS_URI" primaryKey="$COSMOS_KEY" workload_type=workloadc ycsb_operation=load recordcount=$recordcount insertstart=$insertstart insertcount=$ITEM_COUNT_FOR_WRITE operationcount=2 threads=1 target=1 sh run.sh

#Copy YCSB log to storage account 
echo "########## Copying Results to Storage ###########"
cp /tmp/ycsb.log /home/benchmarking/"$VM_NAME-ycsb.log"
sudo azcopy copy "/home/benchmarking/$VM_NAME-ycsb.log" "$RESULT_STORAGE_URL"
