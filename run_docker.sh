# For graphics
xhost +

docker run \
	--interactive \
	--tty \
	--rm \
	--env DISPLAY=$DISPLAY \
	--privileged \
	--volume /tmp/.X11-unix:/tmp/.X11-unix \
	-v $(pwd)/../unitree_ros:/home/forest_ws/src/unitree_ros \
	-v $(pwd)/../g1_opensot:/home/forest_ws/src/g1_opensot \
	opensot
