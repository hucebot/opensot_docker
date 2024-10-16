# For graphics
xhost +

docker run \
	--interactive \
	--tty \
	--rm \
	--env DISPLAY=$DISPLAY \
	--privileged \
	--volume /tmp/.X11-unix:/tmp/.X11-unix \
	opensot
