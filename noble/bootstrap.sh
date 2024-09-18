#!/bin/bash

mkdir -p forest_ws
cd forest_ws
forest init
forest add-recipes git@github.com:advrhumanoids/multidof_recipes.git -t ros2
forest grow all -j8 
