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

data=$(sqlite3 $database "select datetime(timestamp, 'localtime'), temperature, humidity from measurements order by timestamp desc limit 1")

max_temperature=$(sqlite3 $database 'select printf("Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C", avg(temperature), min(temperature), max(temperature)) from measurements')
min_temperature=$(sqlite3 $database 'select printf("Avg=%.2f%%, Min=%.2f%%, Max=%.2f%%", avg(humidity), min(humidity), max(humidity)) from measurements')

avg_temperature=$(sqlite3 $database "SELECT printf(\"Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C\", AVG(temperature), MIN(temperature), MAX(temperature)) FROM measurements WHERE timestamp >= datetime('now', '-1 day')")

max_humidity=$(sqlite3 $database "select max(humidity) from measurements")
min_humidity=$(sqlite3 $database "select min(humidity) from measurements")

IFS='|' read -r -a array <<< "$data"

timestamp=${array[0]}
temperature=${array[1]}
humidity=${array[2]}
hostname=$(hostname)

image_1=$(cat /proc/sys/kernel/random/uuid).png
image_2=$(cat /proc/sys/kernel/random/uuid).png

rm -rf $workspace/www
mkdir -p $workspace/www
cp $workspace/template.html $workspace/www/index.html

sed -i "s/__NOW__/${now}/g"                           $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"               $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"               $workspace/www/index.html
sed -i "s/__TEMPERATURE__/${temperature}/g"           $workspace/www/index.html
sed -i "s/__HUMIDITY__/${humidity}/g"                 $workspace/www/index.html
sed -i "s/__MAX_HUMIDITY__/${max_humidity}/g"         $workspace/www/index.html
sed -i "s/__MIN_HUMIDITY__/${min_humidity}/g"         $workspace/www/index.html
sed -i "s/__MAX_TEMPERATURE__/${max_temperature}/g"   $workspace/www/index.html
sed -i "s/__MIN_TEMPERATURE__/${min_temperature}/g"   $workspace/www/index.html
sed -i "s/__AVG_TEMPERATURE__/${avg_temperature}/g"   $workspace/www/index.html
sed -i "s/__IMAGE_1__/${image_1}/g"                   $workspace/www/index.html
sed -i "s/__IMAGE_2__/${image_2}/g"                   $workspace/www/index.html
sed -i "s/__HOSTNAME__/${hostname}/g"                 $workspace/www/index.html

/home/pi/temperature-sensor/venv/bin/python $workspace/analyze.py $database $workspace/www/$image_1 $workspace/www/$image_2

server=root@jakobmaier.at
webroot=/var/www/project/temperature-sensor

rsync --archive --verbose --delete $workspace/www/ $server:$webroot
