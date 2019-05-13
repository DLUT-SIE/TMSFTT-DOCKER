# Build

Build backend server for RESTful apis.

```shell
$ docker build --tag=rest-apis rest-apis
```

Build Angular and Nginx server.

```shell
$ docker build --tag=web-server web-server
```

Build service for backup (full mode).

```shell
$ docker build -t --tag=full-backup:latest
```

Build service for backup (incremental mode).

```shell
$ docker build --tag=incremental-backup incremental-backup
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

After that, populate initial data manually. Use `docker exec -it <CONTAINER ID> bash` to enter the
container for populating.

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

First, Update codebase with Git.

```shell
$ git submodule foreach git pull
```

Second, build new images for containers requiring update.

> See Build part of this README.

Then, update the container with new images, take `web-server` for example.

```shell
$ docker service update --force TMSFTT_tmsftt-web-server
```

# Backup policy

* Incremental backup
	* Only for media files (from `./data/media-data`, to `./data/backup/incremental`), sync with online media files at 0:30 on a daily basis.
* Full backup
	* Daily: Only for databases, keep daily backups (to `./data/full/daily`) for last 7 days, backup process starts at 0:30 on a daily basis.
	* Weekly: For databases and media files, keep weekly backups (to `./data/full/weekly`) for last 4 weeks, backup process starts at 0:30 on every Monday.
	* Monthly: For database and media files, keep monthly backups (to `./data/full/monthly`) for last 24 months, backup process starts at 0:30 on the first day of every month.

	
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

1. Update `ALLOWED_HOSTS` in `TMSFTT/TMSFTT_prod.py`.