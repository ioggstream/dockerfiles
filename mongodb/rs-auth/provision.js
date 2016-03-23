//  Config replica *before* adding users: users will be replicated on all
//   the infrastructure. Replica authentication is based on a random key file.

//  Add the local server as master to avoid a random member to be elected
use admin;
cfg = { 
  '_id': 'r0',
  'version': 1,
  'members': [
	{'_id': 1, 'host': '172.17.0.2'}, 
  ]
};
rs.initiate(cfg);
// Wait for the master to be elected.
sleep(10000);

//  Create the administration user to modify the configuration,
//   then autenticate.
use admin;
db.createUser({'user': 'root', 'pwd':'root', roles: ['root']});
db.auth('root','root');

cfg = {
  '_id': 'r0',
  'version': 2,
  'members': [
	{'_id': 1, 'host': '172.17.0.2'}, 
	{'_id': 2, 'host': '172.17.0.3'}, 
	{'_id': 3, 'host': '172.17.0.4', 'arbiterOnly': true} 
  ]
};
rs.reconfig(cfg);
sleep(1000);

//  Add replica manager

db.createUser({'user': 'cluster', 'pwd':'cluster', roles: ['clusterAdmin']});
db.createUser({'user': 'nagios', 'pwd':'nagios', roles: ['clusterMonitor']});

//  create user *inside* the given database
use legrec;
db.createUser({'user': 'legrec', 'pwd':'legrec', roles: [{'role': 'readWrite', 'db': 'legrec'}]});

