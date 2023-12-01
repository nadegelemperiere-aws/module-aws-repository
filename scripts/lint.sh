#!/bin/bash
# -------------------------------------------------------
# Copyright (c) [2023] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws repository with all the secure
# components required
# Bash script to launch module linting
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------

# Retrieve absolute path to this script
script=$(readlink -f $0)
scriptpath=`dirname $script`

# Launching tflint
cd ${scriptpath}/..
tflint --init
tflint --format sarif
cd ${scriptpath}