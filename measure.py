#!/usr/bin/env python
import time
import board
import adafruit_dht
import datetime
import os
import sqlite3

sensor = adafruit_dht.DHT22(board.D2)

n_seconds = 5

def read_values():
        try:
            temperature = sensor.temperature
            humidity = sensor.humidity

            print(temperature, humidity)

            database = "/home/pi/temperature-sensor/db/measurements.db"
            conn = sqlite3.connect(database)
            cur = conn.cursor()
            cur.execute('INSERT INTO measurements (temperature, humidity) VALUES (?, ?)', (temperature, humidity))
            conn.commit()
            conn.close()

        except RuntimeError as error:
            print(error.args[0])
            time.sleep(2.0)
        except Exception as error:
            sensor.exit()
            raise error

def read_in_loop():
    while True:
        read_values()
        time.sleep(n_seconds)

if __name__ == "__main__":
    read_in_loop()

