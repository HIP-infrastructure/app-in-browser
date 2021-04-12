#!/bin/bash

if [ -f ./backend/backend.secret ]; then
    echo "./backend/backend.secret exists, exiting."
    exit 1
fi

echo -n "Enter backend username: "
read -r backend_username
echo -n "Enter backend password: "
read -rs backend_password
echo

backend_hash=`python3 -c "from werkzeug.security import generate_password_hash as g; print(g(\"$backend_password\"), end=\"\");"`

echo -n "$backend_username@$backend_hash" > ./backend/backend.secret
