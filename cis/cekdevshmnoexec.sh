#!/bin/bash

#DEVSHM=`df | grep /dev/shm | awk '{ print $6 }'`
#NOSUID=`mount | grep /dev/shm | awk '{ print $6 }' | grep nosuid`
NOEXEC=`mount | grep /dev/shm | awk '{ print $6 }' | grep noexec`

if [ $NOEXEC ]
then
 echo 1
else
 echo 0
fi
