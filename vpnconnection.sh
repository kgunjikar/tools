#! /bin/bash

nmcli con

read -p "Enter up/down(case sensitive)" str
echo $str

if [ "$str" == "up" ]; then
  nmcli con up id "VPN connection 1" --ask
  exit
fi

if [ "$str" == "down" ]; then
  nmcli con down id "VPN connection 1" --ask
  exit
fi
