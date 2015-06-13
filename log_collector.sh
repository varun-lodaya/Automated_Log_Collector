#!/bin/bash

InputVariables=("$@")
user=${InputVariables[0]}
password=${InputVariables[1]}
days=${InputVariables[2]}
date=`date +"%m-%d-%Y"`
DEST_DIR=/data/ # Fill in your own destination directory

if [ -z $user ]; then
    echo "Please provide your username with this script.."
    echo "e.g) ./log_collector.sh <username>"
    exit
fi

if [ -z $days ]; then
    echo "No limit specified, collecting last 1 day of logs"
    days=0
else
    echo "Collecting last $days days of logs"
fi

days=$(expr $days - 1)

for ((index=3; index < ${#InputVariables[@]}; index++))
do
    server=${InputVariables[$index]}
    directory_name=$server-$date
    if [ -d /data/$directory_name ]; then
        sudo rm -rf /data/$directory_name
    fi

    ssh_helper.sh $user $password $server $directory_name $days

    # Now copy over the foler locally
    scp -i /home/$user/.ssh/id_rsa -r $user@$server:$/${directory_name}.tar.gz /data/
    echo "Done copying $server log"

done

