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
		-v $(pwd)/launch/cartesio.launch:/home/forest_ws/src/tiago_dual_cartesio_config/launch/cartesio.launch \
		-v $(pwd)/stack/tiago_dual.stack:/home/forest_ws/src/tiago_dual_cartesio_config/stack/tiago_dual.stack \
		-v $(pwd)/launch/viz.rviz:/home/forest_ws/src/tiago_dual_cartesio_config/launch/viz.rviz \
		-v $(pwd)/python/teleop_bridge.py:/home/forest_ws/src/tiago_dual_cartesio_config/python/teleop_bridge.py \
		opensot

else
    echo "Docker already running."
    docker exec -it opensot /bin/bash
fi