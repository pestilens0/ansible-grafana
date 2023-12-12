#!/bin/bash

# First the default zone is being set to drop, so that only the specified connections will be allowed
firewall-cmd --set-default-zone=drop

# This varialbe allows only newlines to be recognized as boundaries, without it existing rich rules wouldn't be removed properly due to spaces in between
IFS=$'\n'

# Here we simply loop over the existing rich rules and remove each one individually
existing_rules=$(firewall-cmd --list-rich-rules)
for rule in $existing_rules; do
    firewall-cmd --permanent --remove-rich-rule="$rule"
done

# Now we apply all rich rules from /etc/firewall.d
for script in /etc/firewall.d/*
do
  if [[ -x "$script" ]]; then
    bash "$script"
  fi
done

# And reload the firewall
firewall-cmd --reload
