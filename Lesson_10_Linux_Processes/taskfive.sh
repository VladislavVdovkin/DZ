#!/bin/bash

time nice -n -20 sudo "dd if=/dev/zero of=/tmp/otus1.txt bs=2000 count=1M" &  time nice -n 18 sudo "dd if=/dev/zero of=/tmp/otus2.txt bs=2000 count=1M" &