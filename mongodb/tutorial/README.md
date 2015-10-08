# Mongo Tutorial

## Replica Set
Create a replica set with:

    #docker-compose scale rs=3
    or
    #docker-compose scale dc1=3 dc=2

Replace the tutorial string in rs.json

    #sed -e "s/tutorial/yourprefix/g" rs.json 

Pass it to your intended primary (tutorial_dc1_1)

    #mongo $PRIMARY_IP < rs.json


## Sharded Replica Set
Create 9 mongo serves - the rs has the same name. You can
configure their rs manually.

    #docker-compose scale shard=9

Otherwise just run a sharded-replicaset generator.

    #setup-shard.sh

