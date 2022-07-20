#!/bin/bash
git pull
mkdir -p build
sudo singularity build build/pyclesperanto.sif Singularity
