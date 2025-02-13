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
		opensot

else
    echo "Docker already running."
    docker exec -it opensot /bin/bash
fi