#!/bin/bash
set -e
set -x

workspace=/home/pi/temperature-sensor

date=$(date "+%Y-%m-%d")
log_dir=$workspace/log
log_file=$log_dir/temperature.$date.log
tmp_file=/tmp/temperature.txt
database=$workspace/db/measurements.db
index=$workspace/www/index.html
now=$(date)

rm -rf $workspace/www/*

sqlite3 -json $database "SELECT datetime(timestamp, 'localtime') as hour, temperature, humidity FROM measurements WHERE timestamp >= datetime('now', '-1 day')" > $workspace/www/last_24h.json
sqlite3 -json $database "SELECT datetime(timestamp, 'localtime') as hour, temperature, humidity FROM measurements WHERE timestamp >= datetime('now', '-7 day')" > $workspace/www/last_7d.json
#sqlite3 -json $database "SELECT timestamp, temperature, humidity FROM measurements" > $workspace/www/all_time.json
#sqlite3 -json $database "with cte as (select timestamp, temperature, humidity, lag(timestamp) over (order by timestamp) as prev_timestamp from measurements) select * from cte where prev_timestamp is null or ((strftime('%s', timestamp) - strftime('%s', prev_timestamp)) / 60 >= 60);" > $workspace/www/all_time.json

sqlite3 -json $database "select STRFTIME('%Y-%m-%d %H:00:00', timestamp) AS hour, AVG(m.temperature) as temperature, AVG(m.humidity) as humidity from measurements m group by hour order by hour" > $workspace/www/all_time.json

data=$(sqlite3 $database "select datetime(timestamp, 'localtime'), temperature, humidity from measurements order by timestamp desc limit 1")

all_time_temp=$(sqlite3 $database 'select printf("Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C", avg(temperature), min(temperature), max(temperature)) from measurements')
all_time_humidity=$(sqlite3 $database 'select printf("Avg=%.2f%%, Min=%.2f%%, Max=%.2f%%", avg(humidity), min(humidity), max(humidity)) from measurements')

today_temp=$(sqlite3 $database "SELECT printf(\"Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C\", AVG(temperature), MIN(temperature), MAX(temperature)) FROM measurements WHERE timestamp >= datetime('now', '-1 day')")
today_humidity=$(sqlite3 $database "SELECT printf(\"Avg=%.2f%%, Min=%.2f%%, Max=%.2f%%\", AVG(humidity), MIN(humidity), MAX(humidity)) FROM measurements WHERE timestamp >= datetime('now', '-1 day')")

last_7_days_temp=$(sqlite3 $database "SELECT printf(\"Avg=%.2f°C, Min=%.2f°C, Max=%.2f°C\", AVG(temperature), MIN(temperature), MAX(temperature)) FROM measurements WHERE timestamp >= datetime('now', '-7 day')")
last_7_days_humidity=$(sqlite3 $database "SELECT printf(\"Avg=%.2f%%, Min=%.2f%%, Max=%.2f%%\", AVG(humidity), MIN(humidity), MAX(humidity)) FROM measurements WHERE timestamp >= datetime('now', '-7 day')")



IFS='|' read -r -a array <<< "$data"

timestamp=${array[0]}
temperature=${array[1]}
humidity=${array[2]}
hostname=$(hostname)

mkdir -p $workspace/www $workspace/www/favicon
cp $workspace/web/favicon/* $workspace/www/favicon
cp $workspace/web/page.html                                           $index

sed -i "s/__NOW__/${now}/g"                                           $index
sed -i "s/__TIMESTAMP__/${timestamp}/g"                               $index
sed -i "s/__TEMPERATURE__/${temperature}/g"                           $index
sed -i "s/__HUMIDITY__/${humidity}/g"                                 $index
sed -i "s/__All_TIME_TEMPERATURE__/${all_time_temp}/g"                $index
sed -i "s/__All_TIME_HUMIDITY__/${all_time_humidity}/g"               $index
sed -i "s/__TODAY_TEMPERATURE__/${today_temp}/g"                      $index
sed -i "s/__TODAY_HUMIDITY__/${today_humidity}/g"                     $index
sed -i "s/__LAST_7_DAYS_TEMPERATURE__/${last_7_days_temp}/g"          $index
sed -i "s/__LAST_7_DAYS_HUMIDITY__/${last_7_days_humidity}/g"         $index
sed -i "s/__HOSTNAME__/${hostname}/g"                                 $index

server=root@jakobmaier.at
webroot=/var/www/project/temperature-sensor

rsync --archive --verbose --delete $workspace/www/ $server:$webroot
