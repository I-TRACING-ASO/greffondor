#!/bin/bash

IP_TO_CHECK="10.0.0.1"

if ! ping -c1 -W3 $IP_TO_CHECK &>/dev/null; then
	wg-quick down wg0
	sleep 5
	wg-quick up wg0
	sleep 5
	if ! ping -c1 -W3 $IP_TO_CHECK &>/dev/null; then
		reboot
	then
fi