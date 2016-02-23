MONGOD_UID=999

prepare:
	openssl rand -base64 741 > mongod.key
	sudo chown $(MONGOD_UID) mongod.key

start:
	docker-compose scale m=3
	echo "Modify provision.js with the mongod ips and run it into the master node."

