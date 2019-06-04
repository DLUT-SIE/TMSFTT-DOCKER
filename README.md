# Build

Normally, the images will be built automatically on Docker Hub and no actions need to be taken manually, but just in case you want to build these images by yourself, below are the commands for building the images.

Build backend server for RESTful apis. Should run in `TMSFTT-BE` directory.

```shell
$ docker build --tag=sielab303/tmsftt-rest-apis .
```

Build Angular and Nginx server. Should run in `TMSFTT-FE` directory.

```shell
$ docker build --tag=sielab303/tmsftt-web-server .
```

Build service for backup (full mode).

```shell
$ docker build --tag=sielab303/tmsftt-full-backup full-backup
```

Build service for backup (incremental mode).

```shell
$ docker build --tag=sielab303/tmsftt-incremental-backup incremental-backup
```

# Deploy

First, initialize Docker Swarm Mode.

```shell
docker swarm init
```

Then, deploy our service stack.

```shell
$ docker stack deploy -c docker-compose.yaml TMSFTT
```

After that, populate initial data manually. Use `docker exec -it <CONTAINER ID> bash` to enter the container for populating.

* Enter the container of `tmsftt-apis` to populate databases.

```python
$ python manage.py migrate
```

* Enter the container of `tmsftt-db` and create user for data pushing from DLUT-ITS.

```shell
$ mysql -uroot -p<mysql-root-password>

mysql> CREATE USER 'dlut-its'@'%' IDENTIFIED WITH mysql_native_password BY '<PASSWORD HERE>';
mysql> GRANT ALL on TMSFTT.TBL_JB_INFO TO 'dlut-its'@'%';
mysql> GRANT ALL on TMSFTT.TBL_DW_INFO TO 'dlut-its'@'%';

```

* Load time zone table into database.

```shell
$ mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql
```

# Update

The images will be built automatically after PR has been merged, wait for
Docker Hub to build (~20 minutes for `TMSFTT-FE`, ~4 minutes for `TMSFTT-BE`).

Take `tmsftt-web-server` for example.

First, after the newest image was built, pull the latest image.
```shell
$ docker pull sielab303/tmsftt-web-server
```

Second, Update the container with new image.

```shell
$ docker service update TMSFTT_tmsftt-web-server
```

# Backup policy

* Incremental backup
	* Only for media files (from `volume <media-data>`, to `volume <incremental-backups>`), sync with online media files at 0:30 on a daily basis.
* Full backup
	* Daily: Only for databases, keep daily backups (to `volume <daily-full-backups>`) for last 7 days, backup process starts at 0:30 on a daily basis.
	* Weekly: For databases and media files, keep weekly backups (to `volume <weekly-full-backups>`) for last 4 weeks, backup process starts at 0:30 on every Monday.
	* Monthly: For database and media files, keep monthly backups (to `volume <monthly-full-backups>`) for last 24 months, backup process starts at 0:30 on the first day of every month.

# Restore database

To list all available backups in the running docker container, try to run:

```shell
$ docker container exec <container-name> ls /backup
```

To restore a database from a previous backup, try to run:

```shell
$ docker container exec <container-name> /restore.sh /backup/path/to/backup.sql.gz
```

# Deploy notes

1. Update settings for `TMSFTT-BE` in `TMSFTT/TMSFTT_prod.py`, e.g. `ALLOWED_HOSTS`, `SOAP_AUTH_*`, `CAS_SERVER_URL`.
2. Update settings for `TMSFTT-FE` in `src/environments/environment_prod.ts`.