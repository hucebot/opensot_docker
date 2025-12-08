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
#WORKDIR /home/forest_ws/src
#RUN git clone https://github.com/humanoid-path-planner/hpp-fcl.git && \
#    ls -a && \
#    cd /home/forest_ws/src/hpp-fcl && \
#    git checkout 45e60ca7ba81e5394605f8c1097c016245d221c2 && \
#    git submodule init && \
#    git submodule update && \
#    mkdir -p /home/forest_ws/build/hpp-fcl && \
#    cd /home/forest_ws/build/hpp-fcl && \
#    source /opt/ros/jazzy/setup.bash && \
#    source /home/forest_ws/setup.bash && \
#    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_PYTHON_INTERFACE=OFF ../../src/hpp-fcl && \
#    make -j8 && \
#    make install


# COAL
WORKDIR /home/forest_ws/src
RUN git clone -b devel https://github.com/coal-library/coal.git && \
    ls -a && \
    cd /home/forest_ws/src/coal && \
    git submodule init && \
    git submodule update && \
    mkdir -p /home/forest_ws/build/coal && \
    cd /home/forest_ws/build/coal && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_PYTHON_INTERFACE=OFF ../../src/coal && \
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
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_WITH_URDF_SUPPORT=ON -DBUILD_WITH_COLLISION_SUPPORT=OFF -DBUILD_TESTING=FALSE -DBUILD_PYTHON_INTERFACE=OFF ../../src/pinocchio && \
    make -j8 && \
    make install
    

# xbot2_interface
WORKDIR /home/forest_ws/src
RUN git clone -b devel https://github.com/hucebot/xbot2_interface.git && \   
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
    git checkout 9f58ebd7bf42fb364de995d25679dc3f675dee7f && \
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

# qpSWIFT
RUN git clone https://github.com/qpSWIFT/qpSWIFT.git && \
    mkdir -p /home/forest_ws/build/qpSWIFT && \
    cd /home/forest_ws/build/qpSWIFT && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/qpSWIFT && \
    make -j8 && \
    make install


# BLASFEO
RUN git clone https://github.com/giaf/blasfeo && \
    mkdir -p /home/forest_ws/build/blasfeo && \
    cd /home/forest_ws/build/blasfeo && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_SHARED_LIBS=ON -DBLASFEO_EXAMPLES=OFF ../../src/blasfeo && \
    make -j8 && \
    make install
RUN mkdir /home/forest_ws/install/share/cmake/lib && \
    cp /home/forest_ws/install/lib/libblasfeo.so /home/forest_ws/install/share/cmake/lib    



# HPIPM # this version is compatible with hpipm-cpp
RUN git clone https://github.com/giaf/hpipm && \
    cd /home/forest_ws/src/hpipm && \
    git checkout 5dd34e66ae884ae7c8cecad8863949380643c168 && \ 
    mkdir -p /home/forest_ws/build/hpipm && \
    cd /home/forest_ws/build/hpipm && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_SHARED_LIBS=ON -DHPIPM_TESTING=OFF -DHPIPM_FIND_BLASFEO=ON ../../src/hpipm && \
    make -j8 && \
    make install
    
# HPIPM C++
RUN git clone https://github.com/hucebot/hpipm-cpp.git && \
    mkdir -p /home/forest_ws/build/hpipm-cpp && \
    cd /home/forest_ws/build/hpipm-cpp && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../../src/hpipm-cpp && \
    make -j8 && \
    make install
    
# mujoco
RUN git clone https://github.com/deepmind/mujoco.git && \
    mkdir -p /home/forest_ws/build/mujoco && \
    cd /home/forest_ws/build/mujoco && \
    source /opt/ros/jazzy/setup.bash && \
    source /home/forest_ws/setup.bash && \
    #cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DMUJOCO_BUILD_EXAMPLES=OFF -DMUJOCO_BUILD_TESTS=OFF ../../src/mujoco && \
    cmake -DMUJOCO_BUILD_EXAMPLES=OFF -DMUJOCO_BUILD_TESTS=OFF ../../src/mujoco && \
    make -j8 && \
    make install


WORKDIR /home 
RUN apt-get update && apt-get upgrade -y && apt-get clean  && apt-get install -y ros-jazzy-xacro ros-jazzy-joint-state-publisher-gui libglpk-dev libopenblas-dev ros-jazzy-rosidl-generator-dds-idl
RUN echo "export PYTHONPATH=${PYTHONPATH}:/root/.local/lib/python3.12/site-packages:/usr/lib/python3/dist-packages/" >> ~/.bashrc

RUN mkdir -p /ros2_ws/src

WORKDIR /home/ros2_ws/src
RUN git clone -b ros2 https://github.com/EnricoMingo/iit-coman-ros-pkg.git
RUN git clone https://github.com/frankarobotics/franka_description.git
RUN git clone -b ros2 https://github.com/EnricoMingo/franka_cartesio_config.git
RUN git clone -b ros2 https://github.com/EnricoMingo/LittleDog.git

RUN git clone -b humble-devel https://github.com/pal-robotics/pmb2_robot.git
RUN git clone -b humble-devel https://github.com/pal-robotics/tiago_robot.git
RUN git clone -b humble-devel https://github.com/pal-robotics/tiago_dual_robot.git
RUN git clone -b humble-devel https://github.com/pal-robotics/omni_base_robot.git
RUN git clone -b humble-devel https://github.com/pal-robotics/pal_gripper.git
RUN git clone -b ros2 https://github.com/hucebot/tiago_dual_cartesio_config.git

RUN git clone https://github.com/unitreerobotics/unitree_ros2.git
RUN git clone -b sami https://github.com/itsikelis/huro.git

WORKDIR /home/ros2_ws
RUN colcon build
RUN echo "source /home/ros2_ws/install/local_setup.bash" >> ~/.bashrc

WORKDIR /home
