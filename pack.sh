mkdir arm-gcc

cp -a ./aarch64-linux-musl ./arm-linux-musleabi ./arm-gcc/

cat rev > arm-gcc/infs.txt
cat tag >> arm-gcc/infs.txt

cd m_binutils
git log -7 > ../arm-gcc/breplog.txt
cd ..

cd m_gcc
git log -7 > ../arm-gcc/greplog.txt
cd ..

git log -7 > arm-gcc/mreplog.txt

find arm-gcc -type f \( -name cc1* -or -name collect2 -or -name f951 -or -name lto1 -or -name lto-wrapper -or -name gengtype -or -name fixincl \) -exec strip {} \;
for f in arm-gcc/*/bin/* arm-gcc/*/*/bin/*
do
if [ "x$(basename $f | grep .dll)" != "x" ]
then
continue
fi
strip $f
done

tar --gzip -cf arm-gcc.tgz arm-gcc
