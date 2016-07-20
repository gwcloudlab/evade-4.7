#!/bin/bash

ssh neel@nimbnode13 'ycsb load memcached -P /home/neel/YCSB/workloads/workloada -p "memcached.hosts=192.168.1.199" -s'
