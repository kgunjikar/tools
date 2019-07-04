#!/bin/sh

COUNTER=1

while [ $COUNTER -lt 254 ]
do
   ping -i 0.1 10.1.10.$COUNTER -c 1
   COUNTER=$(( $COUNTER + 1 ))