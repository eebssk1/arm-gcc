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

cd m_gcc/build

export CFLAGS_FOR_TARGET="-fgraphite -fgraphite-identity -fipa-pta -flimit-function-alignment -fsched-spec-load -fsched-stalled-insns=6 -fsched-stalled-insns-dep=16 -fira-loop-pressure -mtune=cortex-a55"
export CXXFLAGS_FOR_TARGET="-fdeclone-ctor-dtor $CFLAGS_FOR_TARGET"

if [ $1 = 32 ]; then
ADDI="--with-arch=armv7-a --with-fpu=neon --with-float=hard"
fi
../configure --prefix=$SDIR/$2 --with-local-prefix=$SDIR/$2/local --target=$2 --enable-checking=release --with-tune=cortex-a55 --enable-graphite --enable-lto --disable-rpath --enable-nls --disable-werror --disable-symvers --disable-libstdcxx-debug --enable-languages=c,c++,lto $ADDI; checkreturn $?
make -j2 all; checkreturn $?
make install

rm -rf * .*

cd $SDIR
}

doit 64 aarch64-linux-musl
doit 32 arm-linux-musleabihf

