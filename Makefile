
CONTAINER_BACKUP_DIR = /backup
LOCAL_BACKUP_DIR     := .$(CONTAINER_BACKUP_DIR)
day := $(shell date "+%Y-%m-%d")
db  = huginn
backup_file := ${CONTAINER_BACKUP_DIR}/${day}.db

export COMPOSE_INTERACTIVE_NO_CLI=1

.PHONY: default

default: backup clean

.PHONY: backup

backup:
	# make a new backup
	docker-compose exec -T db pg_dump -U postgres -Fc -d ${db} -f "${backup_file}"
	docker-compose exec -T db chown 1000:1000 "${backup_file}"

.PHONY: restore

# override day in command line to change backup file
# 	make restore day=2019-07-03
restore:
	# restore backup
	docker-compose exec db pg_restore -U postgres -Fc -d ${db} ${backup_file}

.PHONY: clean

clean: old_files := $(subst ./,/,$(shell find ${LOCAL_BACKUP_DIR} -type f -mtime +30 -name "*.db"))

clean:
	# delete backups older than 30 days
	@if [ -n "${old_files}" ]; then \
		docker-compose exec -T db rm -v ${old_files}; \
	else \
		echo "Nothing to clean"; \
	fi
