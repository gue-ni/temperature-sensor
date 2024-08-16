#!/bin/bash
set -e
set -x

workspace=/home/pi/temperature-sensor

date=$(date "+%Y-%m-%d")
log_file=$workspace/log/temperature.$date.log
tmp_file=/tmp/temperature.txt

data=$(tail -n 1 $log_file)

echo $data > $tmp_file

IFS=',' read -r -a array <<< "$data"

echo "First element: ${array[0]}"
echo "First element: ${array[1]}"
echo "First element: ${array[2]}"


timestamp=${array[0]}
temperature=${array[1]}
humidity=${array[2]}

image_name=plot.png

rm -rf $workspace/www
mkdir -p $workspace/www
cp $workspace/template.html $workspace/www/index.html

sed -i "s/__TIMESTAMP__/${timestamp}/g"  $workspace/www/index.html
sed -i "s/__TEMPERATURE__/${temperature}/g"  $workspace/www/index.html
sed -i "s/__HUMIDITY__/${humidity}/g"  $workspace/www/index.html
sed -i "s/__IMAGE__/${image_name}/g" $workspace/www/index.html

python $workspace/analyze.py $log_file $workspace/www/$image_name

scp -r $workspace/www/* $1
#rsync --archive --verbose $workspace/www $1
