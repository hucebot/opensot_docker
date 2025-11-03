# For graphics
xhost +

isRunning=`docker ps -f name=opensot | grep -c "opensot"`;

if [ $isRunning -eq 0 ]; then
	docker rm opensot
	docker run \
		--security-opt seccomp=unconfined \
		--name opensot  \
		--interactive \
		--tty \
		--net host \
		--rm \
		--env DISPLAY=$DISPLAY \
		--env ROS_DOMAIN_ID=69 \
		--privileged \
		--volume /tmp/.X11-unix:/tmp/.X11-unix \
		--volume $(pwd)/code:/home/forest_ws/code \
		--volume /home/enrico/Qt/:/home/Qt \
		opensot

else
    echo "Docker already running."
    docker exec -it opensot /bin/bash
fi
