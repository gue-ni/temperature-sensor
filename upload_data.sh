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

rm -rf $workspace/www/*

sqlite3 -json $database "SELECT timestamp, temperature, humidity FROM measurements WHERE timestamp >= datetime('now', '-1 day')" > $workspace/www/last_24h.json
# sqlite3 -json $database "SELECT timestamp, temperature, humidity FROM measurements WHERE timestamp >= datetime('now', '-7 day')" > $workspace/www/last_7d.json
sqlite3 -json $database "SELECT timestamp, temperature, humidity FROM measurements" > $workspace/www/all_time.json

data=$(sqlite3 $database "select datetime(timestamp, 'localtime'), temperature, humidity from measurements order by timestamp desc limit 1")

all_time_temp=$(sqlite3 $database 'select printf("Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C", avg(temperature), min(temperature), max(temperature)) from measurements')
all_time_humidity=$(sqlite3 $database 'select printf("Avg=%.2f%%, Min=%.2f%%, Max=%.2f%%", avg(humidity), min(humidity), max(humidity)) from measurements')

today_temp=$(sqlite3 $database "SELECT printf(\"Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C\", AVG(temperature), MIN(temperature), MAX(temperature)) FROM measurements WHERE timestamp >= datetime('now', '-1 day')")
today_humidity=$(sqlite3 $database "SELECT printf(\"Avg=%.2f%%, Min=%.2f%%, Max=%.2f%%\", AVG(humidity), MIN(humidity), MAX(humidity)) FROM measurements WHERE timestamp >= datetime('now', '-1 day')")


IFS='|' read -r -a array <<< "$data"

timestamp=${array[0]}
temperature=${array[1]}
humidity=${array[2]}
hostname=$(hostname)

image_1=$(cat /proc/sys/kernel/random/uuid).png
image_2=$(cat /proc/sys/kernel/random/uuid).png

mkdir -p $workspace/www $workspace/www/favicon
cp $workspace/web/favicon/* $workspace/www/favicon
cp $workspace/web/page.html $workspace/www/index.html

sed -i "s/__NOW__/${now}/g"                               $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"                   $workspace/www/index.html
sed -i "s/__TIMESTAMP__/${timestamp}/g"                   $workspace/www/index.html
sed -i "s/__TEMPERATURE__/${temperature}/g"               $workspace/www/index.html
sed -i "s/__HUMIDITY__/${humidity}/g"                     $workspace/www/index.html
sed -i "s/__All_TIME_TEMPERATURE__/${all_time_temp}/g"    $workspace/www/index.html
sed -i "s/__All_TIME_HUMIDITY__/${all_time_humidity}/g"   $workspace/www/index.html
sed -i "s/__TODAY_TEMPERATURE__/${today_temp}/g"          $workspace/www/index.html
sed -i "s/__TODAY_HUMIDITY__/${today_humidity}/g"         $workspace/www/index.html
sed -i "s/__IMAGE_1__/${image_1}/g"                       $workspace/www/index.html
sed -i "s/__IMAGE_2__/${image_2}/g"                       $workspace/www/index.html
sed -i "s/__HOSTNAME__/${hostname}/g"                     $workspace/www/index.html

# /home/pi/temperature-sensor/venv/bin/python $workspace/analyze.py $database $workspace/www/$image_1 $workspace/www/$image_2

server=root@jakobmaier.at
webroot=/var/www/project/temperature-sensor

rsync --archive --verbose --delete $workspace/www/ $server:$webroot
