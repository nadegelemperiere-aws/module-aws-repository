#!/bin/bash
# -------------------------------------------------------
# Copyright (c) [2023] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws repository with all the secure
# components required
# Bash script to tests in a container
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------

# Retrieve absolute path to this script
script=$(readlink -f $0)
scriptpath=`dirname $script`

# Launch tests in docker container
docker run  -it --rm \
            --volume $scriptpath/../:/home/test/module:rw \
            --volume $scriptpath/../../vault/:/home/test/vault \
            --env VAULT_KEY=$VAULT_KEY \
            --workdir /home/test/module \
            nadegelemperiere/terraform-python-awscli:v3.0.0 \
            ./scripts/robot.sh -k VAULT_KEY $@
