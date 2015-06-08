"""
    Test the docker-compose.py with:
    - Logstash listening on 18080
    - Elasticsearch listening on 9200|9300
    
    Map the host/port assigned by docker-compose
    
"""
from socket import socket
from urllib import urlopen
import logging
logging.basicConfig(level=logging.DEBUG)

logstash = {
    'port': 18080,
    'host': 'ls.docker'}
elasticsearch = {
    'port': 9200,
    'host': 'es.docker' 
    }


def test_send_events():
    s = socket()
    s.connect((logstash['host'], logstash['port']))
    for i in range(10):
        s.send("a" * i)
    s.close()
    
def test_read_events():
    logs = urlopen("http://{host}:{port}/_search?pretty".format(**elasticsearch))
    logs = logs.read()
    assert "a" * 9 in logs
    