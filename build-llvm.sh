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

# http://raulherbster.blogspot.co.uk/2012/11/llvm-arm-cross-compilation-using.html
# http://www.bootc.net/archives/2012/05/26/how-to-build-a-cross-compiler-for-your-raspberry-pi/

cd ~/src
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm || fail "Failed to checkout llvm"

cd ~/src/llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/trunk clang || fail "Failed to checkout clang"

cd ~/src/llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt || fail "Failed to checkout compiler-rt"

# cd llvm/projects 
# svn co http://llvm.org/svn/llvm-project/test-suite/trunk test-suite || fail "Failed to checkout test suite"

mkdir ~/src/llvm/build
cd ~/src/llvm/build
#../configure --target=arm-none-linux-gnueabi --host=arm-none-linux-gnueabi --enable-optimized
../configure $CONFIGURE_OPTS --enable-optimized || fail "Configure failed"
make || fail "Make failed"

