FROM osrf/ros:jazzy-desktop

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Paris"

WORKDIR /deps

RUN apt-get update && apt-get upgrade -y && apt-get clean  && apt-get install -y terminator gedit locate cmake-curses-gui python3-pip python3-venv liburdfdom-dev ros-jazzy-moveit-core 

WORKDIR /home
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc

# create forest ws and use it to clone and install CONCERT's simulation package
WORKDIR /home/forest_ws
ENV HHCM_FOREST_CLONE_DEFAULT_PROTO=https
ENV PYTHONUNBUFFERED=1

# create python virtual env
RUN python3 -m venv /home/.base
RUN echo "source /home/.base/bin/activate" >> ~/.bashrc
SHELL ["bash", "-ic"]

RUN pip install --upgrade ttictoc setuptools hhcm-forest && forest init
RUN echo "source $PWD/setup.bash" >> ~/.bashrc
SHELL ["bash", "-ic"]

RUN forest add-recipes git@github.com:advrhumanoids/multidof_recipes.git --tag ros2

# pre-install pybind11 and custom matlogger2 
#RUN forest grow pybind11 --verbose --jobs 4 --pwd user && \
RUN forest grow matlogger2 --verbose --jobs 4 --pwd user
    
# HPP-FCL
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/humanoid-path-planner/hpp-fcl.git && \
    ls -a && \
    cd /home/forest_ws/src/hpp-fcl && \
    git checkout 45e60ca7ba81e5394605f8c1097c016245d221c2 && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/forest_ws/build/hpp-fcl && \
    cd /home/forest_ws/build/hpp-fcl && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_PYTHON_INTERFACE=OFF ../../src/hpp-fcl && \
    make -j8 && \
    make install

## PINOCCHIO
WORKDIR /home/forest_ws/src
RUN git clone -b devel https://github.com/stack-of-tasks/pinocchio.git && \
    cd /home/forest_ws/src/pinocchio && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/forest_ws/build/pinocchio && \
    cd /home/forest_ws/build/pinocchio && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_WITH_URDF_SUPPORT=ON -DBUILD_WITH_COLLISION_SUPPORT=ON -DBUILD_TESTING=FALSE -DBUILD_PYTHON_INTERFACE=OFF ../../src/pinocchio && \
    make -j8 && \
    make install
    

# xbot2_interface
WORKDIR /home/forest_ws/src
RUN git clone -b devel https://github.com/ADVRHumanoids/xbot2_interface.git && \
    mkdir -p /home/forest_ws/build/xbot2_interface && \
    cd /home/forest_ws/build/xbot2_interface && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DXBOT2_IFC_BUILD_TESTS=ON -DXBOT2_IFC_BUILD_ROS=OFF -DXBOT2_IFC_BUILD_ROS2=OFF -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/xbot2_interface && \
    make -j8 && \
    make install
    
# osqp
RUN git clone https://github.com/oxfordcontrol/osqp.git && \
    cd /home/forest_ws/src/osqp && \
    git checkout 0b34f2ef5c5eec314e7945762e1c8167e937afbd && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/forest_ws/build/osqp && \
    cd /home/forest_ws/build/osqp && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DDLONG=OFF -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/osqp && \
    make -j8 && \
    make install

# proxQP
RUN git clone https://github.com/Simple-Robotics/proxsuite.git && \
    cd /home/forest_ws/src/proxsuite && \
    git checkout f19f07b51f66268db1f16cbeb538e891bb6d4e21 && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/forest_ws/build/proxsuite && \
    cd /home/forest_ws/build/proxsuite && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DBUILD_WITH_VECTORIZATION_SUPPORT=OFF -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/proxsuite && \
    make -j8 && \
    make install
    
RUN apt-get update && apt-get upgrade -y && apt-get clean  && apt-get install -y libxcb-cursor0 gdb

# FCL v0.6.0 THIS IS REQUIRED TO RUN TESTS IN OPENSOT! THIS MAY CONFLICT WITH fcl v0.7 installed by default!
WORKDIR /home/forest_ws/src
RUN git clone -b v0.6.0 https://github.com/flexible-collision-library/fcl.git && \
    mkdir -p /home/forest_ws/build/fcl && \
    cd /home/forest_ws/build/fcl && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/fcl  && \
    make -j8 && \
    make install
#MANUALLY ADDING missing fclConfigVersion.cmake to retieve version informations of FCL
RUN FCL_VERSION=0.6.1 && \
    CONFIG_DIR=/home/forest_ws/install/lib/cmake/fcl && \
    mkdir -p "$CONFIG_DIR" && \
    echo "set(PACKAGE_VERSION \"$FCL_VERSION\")" > "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "if(PACKAGE_FIND_VERSION)" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "  if(PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "    set(PACKAGE_VERSION_COMPATIBLE FALSE)" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "  else()" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "    set(PACKAGE_VERSION_COMPATIBLE TRUE)" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "    if(PACKAGE_VERSION VERSION_EQUAL PACKAGE_FIND_VERSION)" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "      set(PACKAGE_VERSION_EXACT TRUE)" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "    endif()" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "  endif()" >> "$CONFIG_DIR/fclConfigVersion.cmake" && \
    echo "endif()" >> "$CONFIG_DIR/fclConfigVersion.cmake"


# qpSWIFT
RUN git clone https://github.com/qpSWIFT/qpSWIFT.git && \
    mkdir -p /home/forest_ws/build/qpSWIFT && \
    cd /home/forest_ws/build/qpSWIFT && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/qpSWIFT && \
    make -j8 && \
    make install

RUN apt-get update && apt-get upgrade -y && apt-get clean  && apt-get install -y ros-jazzy-xacro ros-jazzy-joint-state-publisher-gui libglpk-dev

WORKDIR /home 
RUN echo "export PYTHONPATH=${PYTHONPATH}:/root/.local/lib/python3.12/site-packages:/usr/lib/python3/dist-packages/" >> ~/.bashrc

RUN mkdir -p /ros2_ws/src

WORKDIR /home/ros2_ws/src
RUN git clone https://github.com/frankarobotics/franka_description.git
RUN git clone -b ros2 https://github.com/EnricoMingo/LittleDog.git
RUN git clone -b ros2 https://github.com/EnricoMingo/franka_cartesio_config.git
WORKDIR /home/ros2_ws
RUN colcon build
RUN echo "source /home/ros2_ws/install/local_setup.bash" >> ~/.bashrc

WORKDIR /home
