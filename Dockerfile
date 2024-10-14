FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Paris"

WORKDIR /deps

# Install required packages
RUN apt-get update && apt-get upgrade -y && apt-get clean  && apt-get install -y g++-10 python3-dev \
    python-is-python3 \
    python3-pip \
    git \
    ninja-build \
    cmake \
    gedit \
    build-essential \
    libopenblas-dev \
    clang unzip \
    curl \
    wget \
    software-properties-common \
    bash-completion \
    libx11-dev \
    python3-tk \
    neovim \
    libc++-dev \
    libc++abi-dev \
    libomp-dev \
    xorg-dev \
    libxcb-shm0 \
    libglu1-mesa-dev \
    libc++-dev \
    libc++abi-dev \
    libsdl2-dev \
    libxi-dev \
    libtbb-dev \
    libosmesa6-dev \
    libudev-dev \
    autoconf \
    libtool \
    libglew-dev \
    locate\
    nano \
    cmake-curses-gui \
    ffmpeg && \
    apt-get clean
    
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt-get update && apt-get install -y ros-noetic-desktop-full ros-noetic-srdfdom \
	  ros-noetic-urdf ros-noetic-geometric-shapes ros-noetic-moveit-core ros-noetic-franka-ros ros-noetic-rosmon terminator \
	  ros-noetic-moveit-ros-planning ros-noetic-moveit-ros-planning-interface

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
 
# create forest ws and use it to clone and install CONCERT's simulation package
WORKDIR /home/forest_ws
ENV HHCM_FOREST_CLONE_DEFAULT_PROTO=https
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade ttictoc hhcm-forest && forest init
RUN echo "source $PWD/setup.bash" >> ~/.bashrc

RUN forest add-recipes git@github.com:advrhumanoids/multidof_recipes.git 

# pre-install pybind11
RUN forest grow pybind11 --verbose --jobs 4 --pwd user

# custom matlogger2 
RUN forest grow matlogger2 --verbose --jobs 4 --pwd user

## HPP-FCL
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/humanoid-path-planner/hpp-fcl.git
WORKDIR /home/forest_ws/src/hpp-fcl
RUN git checkout 45e60ca7ba81e5394605f8c1097c016245d221c2
RUN git submodule init && git submodule update
WORKDIR /home/forest_ws/build/hpp-fcl
RUN cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_PYTHON_INTERFACE=OFF ../../src/hpp-fcl && make -j8 && make install

## PINOCCHIO
WORKDIR /home/forest_ws/src

RUN git clone https://github.com/stack-of-tasks/pinocchio.git
WORKDIR /home/forest_ws/src/pinocchio
RUN git submodule init && git submodule update
WORKDIR /home/forest_ws/build/pinocchio
RUN cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_WITH_URDF_SUPPORT=ON -DBUILD_WITH_COLLISION_SUPPORT=ON -DBUILD_PYTHON_INTERFACE=OFF ../../src/pinocchio && make -j8 && make install

# xbot_msgs
WORKDIR /home/forest_ws
RUN source /opt/ros/noetic/setup.bash && forest grow xbot_msgs --verbose --jobs 4 --pwd user

# xbot2_interface
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/ADVRHumanoids/xbot2_interface.git
WORKDIR /home/forest_ws/build/xbot2_interface
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DXBOT2_IFC_BUILD_TESTS=ON -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/xbot2_interface && make -j8 && make install

# osqp
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/oxfordcontrol/osqp.git
WORKDIR /home/forest_ws/src/osqp
RUN git checkout 0b34f2ef5c5eec314e7945762e1c8167e937afbd
RUN git submodule init && git submodule update
WORKDIR /home/forest_ws/build/osqp
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DDLONG=OFF -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/osqp && make -j8 && make install

# proxQP
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/Simple-Robotics/proxsuite.git
WORKDIR /home/forest_ws/src/proxsuite
RUN git submodule init && git submodule update
WORKDIR /home/forest_ws/build/proxsuite
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DBUILD_WITH_VECTORIZATION_SUPPORT=OFF -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/proxsuite && make -j8 && make install

# opensot
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/ADVRHumanoids/OpenSoT.git
WORKDIR /home/forest_ws/src/OpenSoT
RUN git checkout 4.0-devel
WORKDIR /home/forest_ws/build/OpenSoT
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DOPENSOT_SOTH_FRONT_END=ON ../../src/OpenSoT && make -j8 && make install

# reflexxes
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/ADVRHumanoids/RMLTypeII.git
WORKDIR /home/forest_ws/build/RMLTypeII
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/RMLTypeII && make -j8 && make install

# CartesI/O
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/ADVRHumanoids/CartesianInterface.git
WORKDIR /home/forest_ws/src/CartesianInterface
RUN git checkout 3.0-devel
WORKDIR /home/forest_ws/build/CartesianInterface
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCARTESIO_COMPILE_EXAMPLES=ON -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/CartesianInterface && make -j8 && make install

# cartesio_acceleration_support
WORKDIR /home/forest_ws/src
RUN git clone https://github.com/ADVRHumanoids/cartesio_acceleration_support.git
WORKDIR /home/forest_ws/src/cartesio_acceleration_support
RUN git checkout 2.0-devel
WORKDIR /home/forest_ws/build/cartesio_acceleration_support
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCARTESIO_COMPILE_EXAMPLES=ON -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/cartesio_acceleration_support && make -j8 && make install

# cartesio_collision_support
WORKDIR /home/forest_ws/src
RUN git clone -b 2.0-devel https://github.com/ADVRHumanoids/cartesio_collision_support.git
WORKDIR /home/forest_ws/build/cartesio_collision_support
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCARTESIO_COMPILE_EXAMPLES=ON -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/cartesio_collision_support && make -j8 && make install

# centauro_cartesio
WORKDIR /home/forest_ws/src
RUN git clone -b xbot2ifc https://github.com/ADVRHumanoids/centauro_cartesio.git
WORKDIR /home/forest_ws/build/centauro_cartesio
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/centauro_cartesio && make -j8 && make install

# base_estimation
WORKDIR /home/forest_ws/src
RUN git clone -b xbot2ifc https://github.com/ADVRHumanoids/base_estimation.git
WORKDIR /home/forest_ws/build/base_estimation
RUN source /opt/ros/noetic/setup.bash && source /home/forest_ws/setup.bash && cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/base_estimation && make -j8 && make install

# franka_cartesio_config
WORKDIR /opt/ros/noetic/share/franka_description/robots/panda
RUN cp panda.urdf.xacro ../ && cd .. && mv panda.urdf.xacro panda_arm.urdf.xacro
WORKDIR /home/forest_ws/src
RUN git clone -b xbot2ifc https://github.com/EnricoMingo/franka_cartesio_config.git

# Talos
RUN git clone https://github.com/hucebot/talos_cartesio_config.git  \
    &&  git clone https://github.com/pal-robotics/talos_robot.git

## Tiago
RUN git clone https://github.com/hucebot/tiago_dual_cartesio_config.git \
    && git clone -b kinetic-devel https://github.com/EnricoMingo/tiago_dual_robot.git \
    && git clone https://github.com/pal-robotics/tiago_dual_description_calibration.git \ 
    && git clone https://github.com/pal-robotics/pal_urdf_utils.git \
    && git clone -b melodic-devel https://github.com/pal-robotics/omni_base_robot.git \
    && git clone -b foxy-devel https://github.com/pal-robotics/tiago_robot.git \
    && git clone -b humble-devel https://github.com/pal-robotics/hey5_description.git \
    && git clone -b humble-devel https://github.com/pal-robotics/pmb2_robot.git \
    && git clone -b humble-devel https://github.com/EnricoMingo/pal_gripper.git

# Little Dog
RUN git clone https://github.com/EnricoMingo/LittleDog.git

RUN echo 'export ROS_PACKAGE_PATH="${ROS_PACKAGE_PATH}:/home/forest_ws/src/tiago_dual_cartesio_config:/home/forest_ws/src/tiago_dual_robot:/home/forest_ws/src/tiago_dual_description_calibration:/home/forest_ws/src/pal_urdf_utils:/home/forest_ws/src/omni_base_robot:/home/forest_ws/src/tiago_robot:/home/forest_ws/src/hey5_description:/home/forest_ws/src/pmb2_robot:/home/forest_ws/src/pal_gripper:/home/forest_ws/src/LittleDog:/home/forest_ws/src/franka_cartesio_config:/home/forest_ws/src/talos_cartesio_config:/home/forest_ws/src/talos_robot"' >> /home/forest_ws/setup.bash

# Unitree G1, make sure to mount local repos
# RUN git clone https://github.com/itsikelis/unitree_ros.git && git clone https://github.com/itsikelis/g1_opensot.git
RUN echo 'export ROS_PACKAGE_PATH="${ROS_PACKAGE_PATH}:/home/forest_ws/src/unitree_ros/robots/g1_description:/home/forest_ws/src/g1_opensot"' >> /home/forest_ws/setup.bash
