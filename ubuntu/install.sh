#!/bin/bash

# 查找名为 "main" 的进程ID
pid=$(pgrep -f "main")

if [ -n "$pid" ]; then
  echo "Found process with ID: $pid"
  echo "Killing process..."
  kill "$pid"
  echo "Process killed."
else
  echo "Process not found."
fi

echo "Installing 帕鲁面板..."
sudo rm -rf /root/palu
sudo mkdir /root/palu
sudo cd /root/palu
sudo wget -O /root/palu/main http://palu.d.hsy.com/main
sudo chmod 777 /root/palu/main

systemd_unit=hsy-palu
cat <<EOF > $systemd_unit.service
[Unit]
Description=$systemd_unit.service

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=30s
ExecStart=/root/palu/main

[Install]
WantedBy=multi-user.target
EOF

sudo mv $systemd_unit.service /usr/lib/systemd/system/
echo "Starting pal面板..."
sudo systemctl enable $systemd_unit
sudo systemctl restart $systemd_unit
sudo systemctl -l --no-pager status $systemd_unit

if systemctl --quiet is-active "$systemd_unit"
then
    echo -e "\nPalMb is running successfully, enjoy!"
else
    echo -e "\nThere were some problems with the installation, please conteact hsy.com."
fi
