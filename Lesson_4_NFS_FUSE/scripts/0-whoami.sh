#!/bin/sh

set -eux

echo "HM4"
whoami
uname -a
hostname -f
ip addr show dev eth1
