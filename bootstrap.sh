#!/bin/bash

mkdir -p code
cd code

if [ ! -d "OpenSoT" ]; then
  echo "OpenSoT folder does not exist. Cloning..."
  git clone -b 4.0-devel_ros2 https://github.com/hucebot/OpenSoT.git
  echo "...done!"
fi

cd ..
echo "Finished boostrap!"
