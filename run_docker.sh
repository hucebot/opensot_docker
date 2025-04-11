# For graphics
xhost +

isRunning=`docker ps -f name=opensot | grep -c "opensot"`;

if [ $isRunning -eq 0 ]; then
	docker rm opensot
	docker run \
		--name opensot  \
		--interactive \
		--tty \
		--net host \
		--rm \
		--env DISPLAY=$DISPLAY \
		--privileged \
		--volume /tmp/.X11-unix:/tmp/.X11-unix \
		-v `pwd`/../cartesio_collision_avoidance:/ros_ws/src/cartesio_collision_avoidance \
		-v `pwd`/../cartesio_collision_avoidance/launch/cartesio.launch:/home/forest_ws/src/tiago_dual_cartesio_config/launch/cartesio.launch \
		opensot

else
    echo "Docker already running."
    docker exec -it opensot /bin/bash
fi