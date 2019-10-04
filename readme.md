
# Huginn deployment with docker-compose 

You may have to run the following to migrate again after updating huginn image

``` bash
docker-compose exec huginn rake db:migrate
```

Use `make backup` for database backups and restores.
