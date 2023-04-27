#!/bin/sh


echo "Starting Cloudflared tunnel"

cloudflared tunnel --url http://localhost:80   &

# launch web interface
cd web && python3 main.py &

echo "Sleeping infinitely"
while true
do
  sleep 1
done
