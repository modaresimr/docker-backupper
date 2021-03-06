# More VOLUMERIZE Options on [volumerize](https://github.com/blacklabelops/volumerize)
Example run 
```docker build -t docker_backupper .```

```
docker run -d  \
--name backuppper \
-v robocup.org-log:/source/robocup.org-log:ro \
-v robocup.org-system:/source/robocup.org-system:ro \
-v portainer_data:/source/portainer_data:ro \
-v ispconfig_web_www:/source/ispconfig_web_www:ro \
-v volumerize-cache:/volumerize-cache \
-v volumerize-restore:/restore \
-e VOLUMERIZE_SOURCE=/source \
-e VOLUMERIZE_TARGET=s3://s3.us-west-2.amazonaws.com/robocupbackup/aws2 \
-e VOLUMERIZE_RESTORE=/restore \
-e "VOLUMERIZE_DUPLICITY_OPTIONS=" \
-e AWS_ACCESS_KEY_ID=accesskey \
-e AWS_SECRET_ACCESS_KEY=secretkey \
-e TZ=Europe/Paris \
-e "VOLUMERIZE_JOBBER_TIME=0 0 3 * * *" \
-e MYSQL_USERNAME=user \
-e MYSQL_PASSWORD=password \
-e MYSQL_HOST=172.17.0.1 \
-e VOLUMERIZE_FULL_IF_OLDER_THAN=14D \
-e REMOVE_ALL_BUT_N_FULL=4 \
--restart=always \ 
docker_backupper
```
# Using a prepost strategy to create mySQL backups

Volumerize can execute scripts before and after the backup process.

With this prepost strategy you can create a .sql backup of your MySQL containers and save it with Volumerize.

## Environment Variables

Aside of the required environment variables by Volumerize, this prepost strategy will require a couple of extra variables.

| Name           | Description                                                |
| -------------- | ---------------------------------------------------------- |
| MYSQL_USERNAME | Username of the user who will perform the restore or dump. |
| MYSQL_PASSWORD | Password of the user who will perform the restore or dump. |
| MYSQL_HOST     | IP or domain of the host machine.                          |
| MYSQL_DATABASE | Database to restore. (only available for restore)          |	

## Example with Docker Compose

```YAML
version: "3"

services:
  mariadb:
    image: mariadb
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=1234
      - MYSQL_DATABASE=somedatabase
    volumes:
      - mariadb:/var/lib/mysql

  volumerize:
    build: .
    environment:
      - VOLUMERIZE_SOURCE=/source
      - VOLUMERIZE_TARGET=file:///backup
      - MYSQL_USERNAME=root
      - MYSQL_PASSWORD=1234
      - MYSQL_HOST=mariadb
    volumes:
      - volumerize-cache:/volumerize-cache
      - backup:/backup
    depends_on:
      - mariadb

volumes:
  volumerize-cache:
  mariadb:
  backup:
```

Then execute `docker-compose exec volumerize backup` to create a backup of your database and `docker-compose exec volumerize restore` to restore it from your backup.


# Container Scripts

This image creates at container startup some convenience scripts.
Under the hood blacklabelops/volumerize uses duplicity. To pass script parameters, see here for duplicity command line options: [Duplicity CLI Options](http://duplicity.nongnu.org/duplicity.1.html#sect5)

| Script | Description |
|--------|-------------|
|list-files| prepare the list of current files in the backup 
| backup | Creates an backup with the containers configuration |
| backupFull | Creates a full backup with the containers configuration |
| backupIncremental | Creates an incremental backup with the containers configuration |
| list | List all available backups |
| verify | Compare the latest backup to your local files |
| restore | Be Careful! Triggers an immediate force restore to ${VOLUMERIZE_RESTORE}(default=/restore/) containers folder with the latest backup. To access the file easily you can mount this folder in your local machine |
|restoremysql|Be Careful! Triggers an immediate force restore to your mysql database|
|restorepgsql|Be Careful! Triggers an immediate force restore to your pgsql database|
| periodicBackup | Same script that will be triggered by the periodic schedule |
| startContainers | Starts the specified Docker containers |
| stopContainers | Stops the specified Docker containers |
| remove-older-than | Delete older backups ([Time formats](http://duplicity.nongnu.org/duplicity.1.html#toc8))|
| cleanCacheLocks | Cleanup of old Cache locks. |
| prepoststrategy `$execution_phase` `$duplicity_action` | Execute all `.sh` files for the specified exeuction phase and duplicity action in alphabetical order. |

`$execution_phase` must be `preAction` or `postAction`.

`$duplicity_action` must be `backup`, `verify` or `restpore`.

Example triggering script inside running container:

~~~~
$ docker exec volumerize backup
~~~~

> Executes script `backup` inside container with name `volumerize`

Example passing script parameter:

~~~~
$ docker exec volumerize backup --dry-run
~~~~

> `--dry-run` will simulate not execute the backup procedure.

###Example restoremysql 
```restoremysql dbname [-t time]
# example to restore a db from 2 day ago
# restoremysql roundcube -t 2D
# more info on time format http://duplicity.nongnu.org/vers8/duplicity.1.html#sect8
```
###Example restore a file 
```restore --file-to-restore relativepath [-t time]
# example to restore a file from 2 hour ago
# restore --file-to-restore robocup.org-system/image/ -t 2h 
```
