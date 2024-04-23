# For graphics
xhost +

docker run \
            --interactive \
            --tty \
            --rm \
            --env DISPLAY=$DISPLAY \
            --privileged \
            --gpus 'all,"capabilities=compute,utility,graphics"' \
            --volume /tmp/.X11-unix:/tmp/.X11-unix  \
            --volume /dev:/dev \
            opensot
            #--volume $(pwd):/home/code \
            #--volume /home/enrico/catkin_ws/external/kangaroo_mujoco:/home/code/kangaroo_mujoco \
            #--device=/dev/dri/card0  kangarl
    
