# Configures shards
docker-compose scale shard=9
sleep 20

for i in 1 4 7; do
	secondary="tutorial_shard_$((i+1))"
	arbiter="tutorial_shard_$((i+2))"

	 mongo $(docker inspect -f '{{.NetworkSettings.IPAddress}}' "tutorial_shard_$i") <<< "
rs.initiate();
sleep(3000);
rs.add(\"$secondary\");
rs.addArb(\"$arbiter\");
	"
done
