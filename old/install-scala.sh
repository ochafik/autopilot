#!/bin/bash

cd ~/bin
wget http://www.scala-lang.org/downloads/distrib/files/scala-2.10.0.tgz
tar -zxvf scala-2.10.0.tgz

echo "export SCALA_HOME=~/bin/scala-2.10.0" >> ~/.profile
echo 'export PATH=$SCALA_HOME/bin:$PATH' >> ~/.profile

