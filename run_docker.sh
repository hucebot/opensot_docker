# For graphics
xhost +

isRunning=`docker ps -f name=opensot_ros2 | grep -c "opensot_ros2"`;

if [ $isRunning -eq 0 ]; then
	docker rm opensot_ros2
	docker run \
		--name opensot_ros2  \
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
		opensot_ros2

else
    echo "Docker already running."
    docker exec -it opensot_ros2 /bin/bash
fi
