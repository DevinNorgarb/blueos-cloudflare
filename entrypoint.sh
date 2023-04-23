#!/bin/sh


echo "Starting Cloudflared tunnel"

#cloudflared tunnel run

# launch web interface
cd web && python main.py &

echo "Sleeping infinitely"
while true
do
  sleep 1
done
