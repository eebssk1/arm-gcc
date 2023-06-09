#!/bin/sh

checkreturn(){
  if [ x$1 != x0 ]; then
    exit $1
  fi
}

export CC=gcc-12
export CXX=g++-12
if [ "x$(which ccache)" != "x" ]; then
export CC="ccache gcc-12"
export CXX="ccache g++-12"
fi

export SDIR=$PWD

export PATH=$SDIR/aarch64-linux-musl/bin:$SDIR/arm-linux-musleabihf/bin:$PATH

export CFLAGS="$(cat $SDIR/ff.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

doit(){


cd m_binutils/build

../configure --target=$2 --prefix=$SDIR/$2 --enable-64-bit-bfd --enable-gold --enable-initfini-array --enable-nls --disable-rpath --enable-install-libiberty --enable-plugins --enable-deterministic-archives --disable-werror --enable-lto --disable-gdb --disable-gprof; checkreturn $?

make -j2 all; checkreturn $?
make install

rm -rf * .*

cd $SDIR

cp -a musl/$1/. $2/$2/

if [ $1 = 32 ]; then
ARCH=armhf
elif [ $1 = 64 ]; then
ARCH=aarch64
fi
curl -L "https://mirrors.edge.kernel.org/alpine/latest-stable/main/$ARCH/linux-headers-5.19.5-r0.apk" | tar -zxf -
mkdir $2/$2/sys-include
cp -a usr/include/. $2/$2/sys-include
rm -rf usr .PKGINFO .SIGN*

cd m_gcc/build

export CFLAGS_FOR_TARGET="-fgraphite -fgraphite-identity -fipa-pta -flimit-function-alignment -fsched-spec-load -fsched-stalled-insns=4 -fsched-stalled-insns-dep=12 -fira-loop-pressure"
export CXXFLAGS_FOR_TARGET="-fdeclone-ctor-dtor $CFLAGS_FOR_TARGET"

if [ $1 = 32 ]; then
ADDI="--with-arch=armv7-a --with-fpu=neon --with-float=hard"
fi
../configure --prefix=$SDIR/$2 --with-local-prefix=$SDIR/$2/local --target=$2 --enable-checking=release --with-tune=cortex-a76 --enable-graphite --enable-lto --disable-rpath --enable-nls --disable-werror --disable-symvers --disable-libstdcxx-debug --disable-libsanitizer --disable-libssp --enable-languages=c,c++,lto $ADDI; checkreturn $?
make -j2 all; checkreturn $?
make install

rm -rf * .*

cd $SDIR
}

doit 64 aarch64-linux-musl
doit 32 arm-linux-musleabihf

