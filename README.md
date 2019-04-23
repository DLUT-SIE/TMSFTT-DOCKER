# Build

Build backend server for RESTful apis.

```
$ docker build --tag=tmsftt-apis:1.0 rest-api
```

Build Angular and Nginx server.

```
$ docker build --tag=tmsftt-web-server:1.0 web-server
```

# Deploy

First, start Docker Swarm Mode.

```
docker swarm init
```

Then, deploy our service stack.

```
$ docker stack deploy -c docker-compose.yaml TMSFTT
```

After that, populate initial data manually. Use `docker exec -it <CONTAINER ID> bash` to enter the
container for populating.

1. Enter the container of `tmsftt-apis` and run `python manage.py migrate` to populate databases.
2. Enter the container of `tmsftt-db` and create user for data pushing from DLUT-ITS.

```
CREATE USER 'dlut-its'@'%' IDENTIFIED WITH mysql_native_password BY '<PASSWORD HERE>';
GRANT ALL on TMSFTT.TBL_JB_INFO TO 'dlut-its'@'%';
GRANT ALL on TMSFTT.TBL_DW_INFO TO 'dlut-its'@'%';
```

# Update

First, build image for the update.
> See Build part of this README.

Then, <TBD>