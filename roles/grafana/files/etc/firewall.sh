#!/bin/bash

firewall-cmd --complete-reload

firewall-cmd --set-default-zone=drop

for script in /etc/firewall.d/*
do
  if [[ -x "$script" ]]; then
    bash "$script"
  fi
done

firewall-cmd --reload

