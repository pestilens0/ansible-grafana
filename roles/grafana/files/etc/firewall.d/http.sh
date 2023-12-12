#!/bin/bash
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.8.0/24" port port="8080" protocol="tcp" accept'
