# DHT22 Temperature Sensor

```
python -m venv venv
source venv/bin/activate

sudo apt install python3-dev
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# install service
cp temperature-service.service /etc/systemd/system
sudo systemctl enable temperature-service.service
```
