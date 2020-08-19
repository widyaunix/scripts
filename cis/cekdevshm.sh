#!/bin/bash

DEVSHM=`df | grep /dev/shm | awk '{ print $6 }'`

if [ $DEVSHM == '/dev/shm' ]
then
 echo 1
else
 echo 0
fi
