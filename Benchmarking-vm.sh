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

#Execute YCSB test
echo "########## Executing YCSB tests###########"
sudo az acr login --name benchmarkingacr -u benchmarkingacr -p 8cEvIvrwkdndY1MyM9zBsDNpu05E=nli
sudo docker run -dit -e uri="$COSMOS_URI" -e primaryKey="$COSMOS_KEY" -e workload_type=workloadc -e ycsb_operation=load -e recordcount=$recordcount -e insertstart=$insertstart -e insertcount=$ITEM_COUNT_FOR_WRITE -e operationcount=2 -e threads=1 -e target=1 --name client1 benchmarkingacr.azurecr.io/ycsb-cosmos
sudo docker wait client1

#Copy YCSB log to storage account 
echo "########## Copying Results to Storage ###########"
sudo docker cp client1:/tmp/ycsb.log /home/benchmarking/"$VM_NAME-ycsb.log"
sudo azcopy copy "/home/benchmarking/$VM_NAME-ycsb.log" "$RESULT_STORAGE_URL"