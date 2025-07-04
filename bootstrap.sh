#!/bin/bash

mkdir -p code
cd code

if [ ! -d "OpenSoT" ]; then
  echo "OpenSoT folder does not exist. Cloning..."
  git clone -b 4.0-devel_ros2 git@github.com:ADVRHumanoids/OpenSoT
  echo "...done!"
fi

cd ..
echo "Finished boostrap!"
