#!/bin/bash

snapDir="/home/user/Desktop/archive"
poolName="deadpool"

for snapshot in $snapDir/*.zfs; do
    datasetName=$(basename "$snapshot" .zfs)
    echo "Receiving snapshot $snapshot into dataset $poolName/$datasetName..."
    sudo zfs receive "$poolName/$datasetName" < "$snapshot"
done

echo "All snapshots received as individual datasets"