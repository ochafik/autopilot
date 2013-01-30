#!/bin/bash

function fail() {
  echo "`tput bold``tput setaf 1`#" >&2
  echo "#" >&2
  echo "# ERROR: $@" >&2
  echo "#" >&2
  echo "#`tput sgr0`" >&2
  exit 1
}

function log_info() {
    #echo "# $@" >&2
    echo "`tput bold`$@`tput sgr0`" >&2
}

[[ "$USER" != "root" ]] || fail "Please don't run as root."

sudo apt-get -y install llvm clang openjdk-6-jdk maven2 autoconf libtool libhwloc-dev bzr subversion git screen || fail "Failed to install core dependencies"
sudo apt-get clean || fail "Failed to clean packages"

PUBKEY_FILE="$HOME/.ssh/id_rsa.pub"
if [[ ! -f "$PUBKEY_FILE" ]]; then
  ssh-keygen -t rsa -C "olivier.chafik@gmail.com" || fail "Failed to generate ssh key"
  cat "$PUBKEY_FILE" || fail "No public key"
fi

mkdir ~/bin 2>/dev/null ; cd ~/bin

function getMD5Sum() {
    FILE="$1"
    md5sum "$FILE" | awk '{ print $1 }'
}

JDK8_DIR="$HOME/bin/jdk1.8.0"
if [[ ! -d "$JDK8_DIR" ]]; then
    # http://www.java.net/download/JavaFXarm/jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz
    JDK8_ARCHIVE="jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz"
    JDK8_MD5SUM="0f934082dc18f538b5f2c0ecf9fec1e2"
    
    if [[ ! -f "$JDK8_ARCHIVE" || "`getMD5Sum "$JDK8_ARCHIVE"`" != "$JDK8_MD5SUM" ]]; then
        log_info "Downloading $JDK8_ARCHIVE"
        wget "http://www.java.net/download/JavaFXarm/$JDK8_ARCHIVE" || fail "Failed to get JDK 8"
        [[ "`getMD5Sum "$JDK8_ARCHIVE"`" == "$JDK8_MD5SUM" ]] || fail "Archive doesn't have the expected MD5 checksum"
    fi
    log_info "Expanding $JDK8_ARCHIVE"
    tar -zxvf "$JDK8_ARCHIVE" || fail "Failed to get JDK 8"
    #rm "$JDK8_ARCHIVE"
    
    PROFILE_FILE="$HOME/.profile"
    ( cat "$PROFILE_FILE" | grep "$JAVA_HOME" > /dev/null ) || (
        log_info "Updating $PROFILE_FILE"
        echo "export JAVA_HOME=$JDK8_DIR" >> "$PROFILE_FILE"
        echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> "$PROFILE_FILE"
    )
fi

if [[ ! -d ~/src ]]; then
    mkdir ~/src
fi

if [[ -d ~/src/nativelibs4java ]]; then
    log_info "Updating NativeLibs4Java"
    cd ~/src/nativelibs4java
    git pull || fail "Failed to pull NativeLibs4Java"
else
    log_info "Cloning NativeLibs4Java."
    git clone git@github.com:ochafik/nativelibs4java.git ~/src/nativelibs4java || fail "Failed to clone NativeLibs4Java"
fi
log_info "Building BridJ"
cd ~/src/nativelibs4java/libraries/BridJ
mvn velocity:generate || fail "Failed to generate BridJ templates"
./BuildNative || fail "Failed to build BridJ native library"
mvn install -DskipTests || fail "Failed to build BridJ"


#if [[ ! -d ~/src/hwloc ]]; then
#    svn checkout http://svn.open-mpi.org/svn/hwloc/trunk ~/src/hwloc || fail "Failed to checkout hwloc"
#    cd ~/src/hwloc
#    ./autogen.sh && ./configure || fail "Configure of hwloc failed"
#    log_info "Can now build hwloc in '$PWD' with make && sudo make install"
#fi

if [[ ! -d ~/src/pocl ]]; then
    log_info "Checking pocl out."
    cd ~/src
    bzr co lp:pocl || fail "Failed to get pocl sources"
    cd pocl
    ./autogen.sh && ./configure || fail "Configure of pocl failed"
    log_info "Can now build pocl in '$PWD' with make && sudo make install"
fi

