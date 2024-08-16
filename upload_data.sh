#!/bin/bash
set -e
set -x

workspace=/home/pi/temperature-sensor

date=$(date "+%Y-%m-%d")
log_file=$workspace/log/temperature.$date.log
tmp_file=/tmp/temperature.txt

data=$(tail -n 1 $log_file)

echo $data > $tmp_file

timestamp=$(echo $data | awk '{ print $1 }')
temperature=$(echo $data | awk '{ print $2 }')
humidity=$(echo $data | awk '{ print $3 }')

mkdir -p $workspace/www
cp $workspace/template.html $workspace/www/index.html

python $workspace/analyze.py $log_file $workspace/www/plot.png

sed -i 's/__TIMESTAMP__/$date/g'  $workspace/www/index.html
sed -i 's/__TEMPERATURE__/$temperature/g'  $workspace/www/index.html
sed -i 's/__HUMIDITY__/$humidity/g'  $workspace/www/index.html
sed -i 's/__IMAGE__/plot.png/g'  $workspace/www/index.html

#scp $tmp_file $1
scp $workspace/www $1
