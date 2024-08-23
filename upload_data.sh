#!/bin/bash
set -e
set -x

workspace=/home/pi/temperature-sensor

date=$(date "+%Y-%m-%d")
log_dir=$workspace/log
log_file=$log_dir/temperature.$date.log
tmp_file=/tmp/temperature.txt
database=$workspace/db/measurements.db
now=$(date)

#data=$(tail -n 1 $log_file)

data=$(sqlite3 db/measurements.db "select timestamp, temperature, humidity from measurements order by timestamp desc limit 1")
max_temperature=$(sqlite3 db/measurements.db "select max(temperature) from measurements")
max_humidity=$(sqlite3 db/measurements.db "select max(humidity) from measurements")

IFS='|' read -r -a array <<< "$data"

timestamp=${array[0]}
temperature=${array[1]}
humidity=${array[2]}
hostname=$(hostname)


#uuid=$(cat /proc/sys/kernel/random/uuid)
image_1=img-$(cat /proc/sys/kernel/random/uuid).png
image_2=img-$(cat /proc/sys/kernel/random/uuid).png

rm -rf $workspace/www
mkdir -p $workspace/www
cp $workspace/template.html $workspace/www/index.html

sed -i "s/__NOW__/${now}/g"  $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"  $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"  $workspace/www/index.html
sed -i "s/__TEMPERATURE__/${temperature}/g"  $workspace/www/index.html
sed -i "s/__HUMIDITY__/${humidity}/g"  $workspace/www/index.html
sed -i "s/__MAX_HUMIDITY__/${max_humidity}/g"  $workspace/www/index.html
sed -i "s/__MAX_TEMPERATURE__/${max_temperature}/g"  $workspace/www/index.html
sed -i "s/__IMAGE_1__/${image_1}/g" $workspace/www/index.html
sed -i "s/__IMAGE_2__/${image_2}/g" $workspace/www/index.html
sed -i "s/__HOSTNAME__/${hostname}/g" $workspace/www/index.html

/home/pi/temperature-sensor/venv/bin/python $workspace/analyze.py $database $workspace/www/$image_1
#/home/pi/temperature-sensor/venv/bin/python $workspace/analyze.py $log_dir/* $workspace/www/$image_2

server=root@jakobmaier.at
webroot=/var/www/project/temperature-sensor-1

rsync --archive --verbose --delete $workspace/www/ $server:$webroot
