#!/bin/bash

sudo caddy run -config caddy/Caddyfile &
caddy=$!
sudo gunicorn --workers 2 --timeout 120 --bind 0.0.0.0:8060 --pythonpath backend backend:app &
gunicorn=$!
wait $caddy $gunicorn
