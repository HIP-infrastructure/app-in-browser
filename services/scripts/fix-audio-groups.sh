#!/bin/bash

# ensure that the user passed in parameter is part of the right audio groups

HIP_USER=$1

echo -n "Adding user $HIP_USER into the right audio groups... "

usermod --groups audio,pulse,pulse-access --append $HIP_USER

echo "done."
