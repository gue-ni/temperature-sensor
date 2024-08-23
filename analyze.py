import sys
import pandas as pd
import matplotlib.pyplot as plt
import sqlite3

def main(database, figname):

  conn = sqlite3.connect(database)

  query = "SELECT timestamp, temperature, humidity FROM measurements"
  data = pd.read_sql_query(query, conn)


  plt.figure()
  plt.gcf().autofmt_xdate()

  fig, ax1 = plt.subplots()
  fig.autofmt_xdate(rotation=45)
  ax1.set_ylabel("Temperature (°C)", color='r')
  ax1.plot(data["timestamp"], data["temperature"], label="Temperature (°C)", color='r')
  # ax1.legend()

  ax2 = ax1.twinx()
  ax2.set_ylabel("Humidity (%)", color='b')
  ax2.plot(data['timestamp'], data['humidity'], label='Humidity (%)', color='b')
  # ax2.legend()

  plt.title("Temperature and Humidity")

  plt.savefig(figname)

if __name__ == "__main__":

  if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <database> <image_out>")
    exit(1)

  database = sys.argv[1]
  print(database)
  outfile = sys.argv[len(sys.argv) - 1]
  main(database, outfile)
