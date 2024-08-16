# DHT22 Temperature Sensor

If pin 4 does not work, maybe try pin 2.

```
python -m venv venv
source venv/bin/activate

sudo apt install python3-dev
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# install service
cp temperature-service.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start temperature-service.service
sudo systemctl enable temperature-service.service
```
