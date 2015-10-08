# Configures shards
docker-compose scale shard=3
sleep 2

for i in 1 4 7 ; do
	primary="tutorial_shard_$i"
	secondary="tutorial_shard_$((i+1))"
	arbiter="tutorial_shard_$((i+2))"

	mongo $(docker inspect -f '{{.NetworkSettings.IPAddress}}' "$primary")  <<< "
rs.initiate({
  _id: \"rs\", 
  members: [ 
    { _id: 0, host: \"$primary\" }
  ]
});
sleep(3000);
rs.add(\"$secondary\");
rs.addArb(\"$arbiter\");
"


done
