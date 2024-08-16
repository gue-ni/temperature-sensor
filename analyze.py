import sys
import pandas as pd
import matplotlib.pyplot as plt

def main(filename, figname):
  data = pd.read_csv(filename,  parse_dates=['time'])

  plt.figure()
  plt.gcf().autofmt_xdate()

  fig, ax1 = plt.subplots()
  fig.autofmt_xdate(rotation=45)
  ax1.set_ylabel("Temperature (°C)", color='r')
  ax1.plot(data["time"], data["temperature"], label="Temperature (°C)", color='r')
  # ax1.legend()

  ax2 = ax1.twinx()
  ax2.set_ylabel("Humidity (%)", color='b')
  ax2.plot(data['time'], data['humidity'], label='Humidity (%)', color='b')
  # ax2.legend()

  plt.title("Temperature and Humidity")

  plt.savefig(figname)

if __name__ == "__main__":
  if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <log_file> <image_out>")
    exit(1)

  filename = sys.argv[1]
  outfile = sys.argv[2]
  main(filename, outfile)