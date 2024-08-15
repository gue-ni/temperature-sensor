#!/bin/bash
set -e
set -x

today=$(date "+%Y-%m-%d")
log_file=/home/pi/temperature-sensor/log/temperature.$today.log
tmp_file=/tmp/temperature.txt

tail -n 1 $log_file > $tmp_file

scp $tmp_file $1

