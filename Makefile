create-folders:
	@mkdir -p data/redis-master1 \
	         data/redis-master2 \
	         data/redis-master3 \
	         data/redis-replica1 \
	         data/redis-replica2 \
	         data/redis-replica3
	@sudo chmod -R 777 data

create-cluster:
	@$(MAKE) create-folders
	@sudo docker compose up -d
	@docker exec -it -w / redis-master1 redis-cli -a $(REDIS_PASSWORD) --cluster create \
        redis-master1:7000 \
        redis-master2:7001 \
        redis-master3:7002 \
        redis-replica1:7003 \
        redis-replica2:7004 \
        redis-replica3:7005 \
        --cluster-replicas 1