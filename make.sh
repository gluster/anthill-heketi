#!/usr/bin/env bash

DOCKER_CMD=${DOCKER_CMD:="sudo /usr/bin/docker"} IMAGE=${IMAGE:="localhost:5000/jarrpa/anthill:dev"} make ${@}
