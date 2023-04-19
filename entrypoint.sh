#!/bin/sh


log "Starting Cloudflared tunnel"

#cloudflared tunnel run

# launch web interface
cd web && python main.py &

log "Sleeping infinitely"
while true
do
  sleep 1
done
