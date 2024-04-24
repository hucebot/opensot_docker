opensot_docker
==============
A ```DockerFile``` containing  to run the OpenSoT and CartesI/O frameworks.

Build the DockerFile:
--------------------- 
Run ```docker build -t opensot .``` in the ```opensot_docker``` folder.

It takes around 18 minutes to build.

Run the docker image:
----------------------
Run the script ```./run_docker.sh``` in the ```opensot_docker``` folder.

Inside the image terminal run ```terminator``` to open a new terminal. You can plit this terminal horizontally using the shortcut ```Ctrl + Shift + o``` or in vertical using ```Ctrl + Shift + e```.

Examples:
---------
- Terminal 1 ```roscore```
- Terminal 2 ```reset && mon launch cartesian_interface coman.launch```

[franka_cartesio_config](https://github.com/EnricoMingo/franka_cartesio_config)
- terminal 1 ```roscore```
- terminal 2 ```reset && mon launch franka_cartesio_config cartesian_control.launch```

[tiago_dual_cartesio_config](https://github.com/hucebot/tiago_dual_cartesio_config)
- terminal 1 ```roscore```
- terminal 2 ```reset && mon launch tiago_dual_cartesio_config cartesio.launch```

[talos_cartesio_config](https://github.com/hucebot/talos_cartesio_config)
- terminal 1 ```roscore```
- terminal 2 ```reset && mon launch talos_cartesio_config cartesio.launch```
  
or

- terminal 1 ```roscore```
- terminal 2 ```reset && mon launch talos_cartesio_config cartesio.launch stack:=simple_id```


IMPORTANT: right-click on the interactive marker and click on ```Continuous Ctrl``` thick to move the marker and send commands to the controlled end-effector.
