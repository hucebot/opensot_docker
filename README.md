opensot_docker
==============
A ```DockerFile``` based on ROS2 jazzy-desktop to run the [OpenSoT](https://github.com/ADVRHumanoids/OpenSoT) framework.

Bootstrap:
----------
Run the script ```./bootstrap.sh``` in the ```opensot_docker``` folder. This will clone the OpenSoT repository ```4.0-devel_ros2``` branch,

Build the DockerFile:
--------------------- 
Run ```docker build -t opensot_ros2 .``` in the ```opensot_docker``` folder.

Run the docker image:
----------------------
Run the script ```./run_docker.sh``` in the ```opensot_docker``` folder.

Inside the image terminal run ```terminator``` to open a new terminal. You can split this terminal horizontally using the shortcut ```Ctrl + Shift + o``` or in vertical using ```Ctrl + Shift + e```.

Compile OpenSoT:
----------------
Inside ```/home/forest_ws/code``` run:

```mkdir build```

then, inside the ```build``` folder:

```cmake -DCMAKE_INSTALL_PREFIX:STRING=/home/forest_ws/install -DCMAKE_BUILD_TYPE:STRING=Release ../OpenSoT && make -j8 && make install```

Run Python Examples:
--------------------
The Python examples can be found in ```/home/forest_ws/src/OpenSoT/bindings/python/examples```.

For the ID example using the Little Dog robot runs:

```python LittleDog_id.py```
