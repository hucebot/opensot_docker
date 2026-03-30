# For graphics
xhost +

isRunning=`docker ps -f name=opensot_caps | grep -c "opensot_caps"`;

if [ $isRunning -eq 0 ]; then
	docker rm opensot_caps
	docker run \
		--security-opt seccomp=unconfined \
		--name opensot_caps  \
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
		--volume $(pwd)/code/climbingrobot_description:/home/ros2_ws/src/climbingrobot_description \
		opensot_caps

else
    echo "Docker already running."
    docker exec -it opensot_caps /bin/bash
fi
