#!/usr/bin/env python
import time
import board
import adafruit_dht
import datetime

# Sensor data pin is connected to GPIO 4
sensor = adafruit_dht.DHT22(board.D4)

frequency = 5

def read_values():
        try: 
            temperature = sensor.temperature
            humidity = sensor.humidity
            now = datetime.datetime.now().isoformat()

            output = f"{now}, {temperature}°C, {humidity}%\n"

            with open("/home/pi/temperature-sensor/log/temperature.log", "a") as log:
                log.write(output)

        except RuntimeError as error:
            print(error.args[0])
            time.sleep(2.0)
        except Exception as error:
            sensor.exit()
            raise error



def read_in_loop():
    while True:
        read_values()
        time.sleep(frequency);



if __name__ == "__main__": 
    read_in_loop()

