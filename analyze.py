import sys
import pandas as pd
import matplotlib.pyplot as plt
import sqlite3

def plot_data(data, figname):
  plt.figure()
  plt.gcf().autofmt_xdate()

  fig, ax1 = plt.subplots()
  fig.autofmt_xdate(rotation=45)
  ax1.set_ylabel("Temperature (°C)", color='r')
  ax1.plot(data.index, data["temperature"], label="Temperature (°C)", color='r')

  ax2 = ax1.twinx()
  ax2.set_ylabel("Humidity (%)", color='b')
  ax2.plot(data.index, data['humidity'], label='Humidity (%)', color='b')

  plt.title("Temperature and Humidity")
  plt.savefig(figname)

def main(database, fig_1, fig_2):

  conn = sqlite3.connect(database)

  query = "SELECT timestamp, temperature, humidity FROM measurements WHERE timestamp >= datetime('now', '-1 day')"
  data = pd.read_sql_query(query, conn)
  data['timestamp'] = pd.to_datetime(data['timestamp'])
  data.set_index('timestamp', inplace=True)

  plot_data(data, fig_1)

  query = "SELECT timestamp, temperature, humidity FROM measurements"
  data = pd.read_sql_query(query, conn)
  data['timestamp'] = pd.to_datetime(data['timestamp'])
  data.set_index('timestamp', inplace=True)

  plot_data(data, fig_2)

if __name__ == "__main__":

  if len(sys.argv) < 3:
    print(f"Usage: {sys.argv[0]} <database> <image_1> <image_2>")
    exit(1)

  database = sys.argv[1]
  image_1 = sys.argv[2]
  image_2 = sys.argv[3]
  main(database, image_1, image_2)
