# For graphics
xhost +

isRunning=`docker ps -f name=opensot | grep -c "opensot"`;

if [ $isRunning -eq 0 ]; then
    #docker remove opensot
    docker rm -f opensot
    docker run \
		--gpus 'all,"capabilities=compute,utility,graphics"' \
		--env NVIDIA_DRIVER_CAPABILITIES=all \
        --name opensot  \
        --interactive \
        --tty \
        --net host \
        --env DISPLAY=$DISPLAY \
        --privileged \
        --volume /tmp/.X11-unix:/tmp/.X11-unix \
        opensot

else
    echo "Docker already running."
    docker exec -it opensot /bin/bash
fi