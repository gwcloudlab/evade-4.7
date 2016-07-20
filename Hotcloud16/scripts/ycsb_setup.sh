#!/bin/bash

APPS=(memcached openjdk-7-jdk)

# deps
sudo apt-get update

for i in ${APPS[@]}; do
	sudo apt-get install -y $i
done

# Get and setup ycsb
cd ~
#curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.7.0/ycsb-0.7.0.tar.gz
#tar xfvz ycsb-0.7.0.tar.gz
#cd ycsb-0.7.0
git clone http://github.com/brianfrankcooper/YCSB.git
cd ./YCSB
ycsb=`pwd`

# set up database to benchmark

#############################################
############## SETUP MEMCACHED ##############
#############################################
#	deps are java and maven
#	java is installed as a dep
#############################################
#############################################

# Download dependencies and setup environment
cd ~
wget http://ftp.heanet.ie/mirrors/www.apache.org/dist/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
sudo tar xzf apache-maven-*-bin.tar.gz -C /usr/local
sudo ln -s /usr/local/apache-maven-* /usr/local/maven
sudo touch /etc/profile.d/maven.sh
sudo sh -c "echo 'export M2_HOME=/usr/local/maven' >> /etc/profile.d/maven.sh"
sudo sh -c "echo 'export PATH=${M2_HOME}/bin:${PATH}' >> /etc/profile.d/maven.sh"

# configure YCSB for memcached
cd $ycsb
mvn -pl com.yahoo.ycsb:memcached-binding -am clean package

# load data and run tests
# 	Use the following commands to do so:
# 	Load Data:
# 		./bin/ycsb load memcached -s -P workloads/workloada -p "memcached.hosts=127.0.0.1" > outputLoad.txt
# 	Run workload test:
#		./bin/ycsb run memcached -s -P workloads/workloada -p "memcached.hosts=127.0.0.1" > outputRun.txt
# OR
#
# open memcached/conf/memcached.properties
# and look at TODO in conf file.  Add hosts there
# then use the following commands:
# Load:
# 	./bin/ycsb load memcached -s -P workloads/workloada -p > outputLoad.txt
# Run:
#	./bin/ycsb run memcached -s -P workloads/workloada -p > outputRun.txt
