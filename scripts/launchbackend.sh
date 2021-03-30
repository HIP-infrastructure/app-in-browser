#!/bin/bash

sudo gunicorn --workers 2 --timeout 120 --bind 0.0.0.0:8060 --pythonpath backend backend:app
