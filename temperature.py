#!/usr/bin/env python
import time
import board
import adafruit_dht

# Sensor data pin is connected to GPIO 4
sensor = adafruit_dht.DHT22(board.D4)

def read_values():
        try: 
            temperature = sensor.temperature
            humidity = sensor.humidity

            output = f"Temp={temperature}°C, Humidity={humidity}%\n"

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
        time.sleep(3.0);



if __name__ == "__main__": 
    read_in_loop()

