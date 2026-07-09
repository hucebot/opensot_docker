FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Paris"

WORKDIR /deps

RUN apt-get update && apt-get upgrade -y && apt-get clean  && apt-get install -y terminator gedit locate cmake-curses-gui python3-pip python3-venv liburdfdom-dev git-all libeigen3-dev libboost-all-dev libhdf5-dev liboctomap-dev octovis libassimp-dev

WORKDIR /home

# create python virtual env
RUN python3 -m venv /home/.base
RUN echo "source /home/.base/bin/activate" >> ~/.bashrc
SHELL ["bash", "-ic"]

RUN pip3 install --upgrade jinja2 typeguard ttictoc "setuptools<81"


WORKDIR /home/src/
RUN git clone -b master https://github.com/hucebot/MatLogger2.git && \
    mkdir -p /home/build/MatLogger2 && \
    cd /home/build/MatLogger2 && \
    cmake -DCMAKE_BUILD_TYPE:STRING=Release ../../src/MatLogger2 && \
    make -j8 && \
    make install
    
WORKDIR /home/src
RUN git clone -b devel https://github.com/coal-library/coal.git && \
    ls -a && \
    cd /home/src/coal && \
    git checkout 9856e007971225d6948a8feff6da5b36cc6beacd && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/build/coal && \
    cd /home/build/coal && \
    cmake -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_PYTHON_INTERFACE=OFF ../../src/coal && \
    make -j8 && \
    make install
    
# this version allows still to use aligned_vector
WORKDIR /home/src
RUN git clone -b devel https://github.com/stack-of-tasks/pinocchio.git && \
    cd /home/src/pinocchio && \
    git checkout 4b2ed738b8342c6820ac12597ef2b3e32ddddd97 && \ 
    git submodule init && \
    git submodule update && \
    mkdir -p /home/build/pinocchio && \
    cd /home/build/pinocchio && \
    cmake -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_WITH_URDF_SUPPORT=ON -DBUILD_WITH_COLLISION_SUPPORT=OFF -DBUILD_TESTING=FALSE -DBUILD_PYTHON_INTERFACE=OFF ../../src/pinocchio && \
    make -j8 && \
    make install
 
# these are needed by xbot2_interface    
RUN apt install -y software-properties-common && add-apt-repository universe && apt update && apt install curl -y && \
    export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}') && \
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" && \
    dpkg -i /tmp/ros2-apt-source.deb && apt update && apt upgrade && apt-get install -y ros-humble-urdf ros-humble-srdfdom ros-humble-geometric-shapes 
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

RUN apt-get install -y libgtest-dev pybind11-dev libccd-dev
WORKDIR /home/src
RUN git clone -b devel https://github.com/hucebot/xbot2_interface.git && \   
    mkdir -p /home/build/xbot2_interface && \
    cd /home/build/xbot2_interface && \
    cmake -DXBOT2_IFC_BUILD_TESTS=ON -DXBOT2_IFC_BUILD_ROS=OFF -DXBOT2_IFC_BUILD_ROS2=OFF -DCMAKE_BUILD_TYPE:STRING=Release -DBoost_USE_DEBUG_RUNTIME=OFF ../../src/xbot2_interface && \
    make -j8 && \
    make install
    
WORKDIR /home/src
RUN git clone https://github.com/oxfordcontrol/osqp.git && \
    cd /home/src/osqp && \
    git checkout 0b34f2ef5c5eec314e7945762e1c8167e937afbd && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/build/osqp && \
    cd /home/build/osqp && \
    cmake -DDLONG=OFF -DCMAKE_BUILD_TYPE:STRING=Release ../../src/osqp && \
    make -j8 && \
    make install

RUN git clone https://github.com/Simple-Robotics/proxsuite.git && \
    cd /home/src/proxsuite && \
    git checkout 9f58ebd7bf42fb364de995d25679dc3f675dee7f && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/build/proxsuite && \
    cd /home/build/proxsuite && \
    cmake -DBUILD_WITH_VECTORIZATION_SUPPORT=OFF -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE:STRING=Release ../../src/proxsuite && \
    make -j8 && \
    make install

RUN git clone https://github.com/qpSWIFT/qpSWIFT.git && \
    cd /home/src/qpSWIFT && \
    git checkout 24608b671d0e7ecde4d14ee8530d1656d6940fd1 && \
    mkdir -p /home/build/qpSWIFT && \
    cd /home/build/qpSWIFT && \
    cmake -DCMAKE_BUILD_TYPE:STRING=Release ../../src/qpSWIFT && \
    make -j8 && \
    make install

RUN git clone https://github.com/hucebot/OpenSoT.git && \
    cd /home/src/OpenSoT && \
    git checkout 2bf8b6d382afbf7e7763ddd8af1065418623f78f && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/build/OpenSoT && \
    cd /home/build/OpenSoT && \
    cmake -DCMAKE_BUILD_TYPE:STRING=Release -DOPENSOT_COMPILE_EXAMPLES=ON -DOPENSOT_COMPILE_TESTS=ON ../../src/OpenSoT && \
    make -j8 && \
    make install
        
RUN python3 -m pip install numpy viser matplotlib h5py yourdfpy

#RUN echo "export PYTHONPATH=${PYTHONPATH}:/root/.local/lib/python3.12/site-packages:/usr/lib/python3/dist-packages/" >> ~/.bashrc
RUN ldconfig

