day := $(shell date "+%Y-%m-%d")
db  = huginn

LOCAL_BACKUP_DIR = ./backup
backup_file := ${LOCAL_BACKUP_DIR}/${day}.sql

export COMPOSE_INTERACTIVE_NO_CLI=1
export PATH := /usr/local/bin:${PATH}

.PHONY: default
default: backup clean

.PHONY: backup
backup:
	# make a new backup
	@mkdir -p ./backup
	docker-compose exec -T db pg_dump -U postgres -Fp -d ${db} | gzip > ${backup_file}.gz

# override day in command line to change backup file
# 	make restore day=2019-07-03
.PHONY: restore
restore:
	# restore backup
	$(eval container_id := $(shell docker-compose ps -q db) )
	zcat ${backup_file}.gz | docker exec -i ${container_id} psql -U postgres -d ${db}

.PHONY: clean
clean:
	# delete backups older than 30 days
	find ${LOCAL_BACKUP_DIR} -type f -mtime +30 -delete
