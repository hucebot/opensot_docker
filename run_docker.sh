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
		--volume $(pwd)/unitree_ros:/home/forest_ws/src/unitree_ros \
    		--volume $(pwd)/g1_opensot:/home/forest_ws/src/g1_opensot \
		opensot

else
    echo "Docker already running."
    docker exec -it opensot /bin/bash
fi
