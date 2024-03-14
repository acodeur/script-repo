for port in `seq 6391 6396`; do \
mkdir -p ./redis-${port}/conf && PORT=${port} envsubst < ./redis-cluster.tmpl > ./redis-${port}/conf/redis.conf && mkdir -p ./redis-${port}/data; \
done