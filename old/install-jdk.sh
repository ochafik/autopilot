
#Dev

mkdir ~/bin ; cd ~/bin
wget http://www.java.net/download/JavaFXarm/jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz
tar -zxvf jdk-*.tar.gz

mkdir ~/src ; cd ~/src
bzr co lp:pocl
git clone git@github.com:ochafik/nativelibs4java.git
