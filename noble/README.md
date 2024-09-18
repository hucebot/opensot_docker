### Build the container
```bash
docker compose build
```

### Start the container
```bash
docker compose up -d
```

### Stop the container
```bash
docker compose down
```

### Attach terminator
```bash
docker compose exec dev terminator
```

### Compilation out-of-docker
The first time the docker is started, it is required to compile running the ```bootstrap.sh``` which is mounted inside the ```data``` folder, inside the running docker.

