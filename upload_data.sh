#!/bin/bash
set -e
set -x

workspace=/home/pi/temperature-sensor

date=$(date "+%Y-%m-%d")
log_file=$workspace/log/temperature.$date.log
tmp_file=/tmp/temperature.txt
now=$(date)

data=$(tail -n 1 $log_file)

echo $data > $tmp_file

IFS=',' read -r -a array <<< "$data"

timestamp=${array[0]}
temperature=${array[1]}
humidity=${array[2]}
hostname=$(hostname)

uuid=$(cat /proc/sys/kernel/random/uuid)
image_name=plot-$uuid.png

rm -rf $workspace/www
mkdir -p $workspace/www
cp $workspace/template.html $workspace/www/index.html

sed -i "s/__NOW__/${now}/g"  $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"  $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"  $workspace/www/index.html
sed -i "s/__TEMPERATURE__/${temperature}/g"  $workspace/www/index.html
sed -i "s/__HUMIDITY__/${humidity}/g"  $workspace/www/index.html
sed -i "s/__IMAGE__/${image_name}/g" $workspace/www/index.html
sed -i "s/__HOSTNAME__/${hostname}/g" $workspace/www/index.html

/home/pi/temperature-sensor/venv/bin/python $workspace/analyze.py $log_file $workspace/www/$image_name

server=root@jakobmaier.at
webroot=/var/www/project/temperature-sensor-2

rsync --archive --verbose --delete $workspace/www/ $server:$webroot
