#!/bin/bash

snapDir="/home/user/Desktop/archive"
poolName="deadpool"
datasetNum=0

for snapshot in $snapDir; do
    datasetName="dataset $datasetNum"
    echo "Receiving snapshot $snapshot into dataset $poolName/$datasetName..."
    sudo zfs receive "$poolName/$datasetName" < "$snapshot"
    ((datasetNum++))
done

echo "All snapshots received as individual datasets"