#!/bin/bash -e
#
#
#
basedir=$(dirname "$0")

with_i386=1

apt-get update -y
apt-get install -y build-essential git perl

if [ $with_i386 -ge 1 ]
then
        dpkg --add-architecture i386
        apt-get update -y # pull i386
        apt-get install -y gcc-multilib g++-multilib
        #apt-get install -y libz-dev:i386
fi


git clone https://github.com/cambridgehackers/open-src-cvc
cd open-src-cvc

apt-get install libz-dev
[ $with_i386 -eq 0 ] || apt-get install -y libz-dev:i386
rm -f src/libz.a
rm -f bin/checkcvc64 bin/checkcvc32 bin/checkcvc
rm -f chkcvc.src.dir/checkcvc64 chkcvc.src.dir/checkcvc32 chkcvc.src.dir/checkcvc

if [ -f ../src_makefile_cvc.patch ] && ! grep -sq ASM_CC src/makefile.cvc
then
        patch -p1  < "${basedir}/src_makefile_cvc.patch"
        echo "PATCH APPLIED: src_makefile_cvc.patch"
else
        echo "#### WARNING: src_makefile_cvc.patch PATCH NOT APPLIED"
fi

######################################################################################################################################
cd chkcvc.src.dir
make -f makefile.lnx64
cp -av checkcvc64 ../bin/

if [ $with_i386 -ge 1 ]
then
        make -f makefile.lnx
        cp -av checkcvc ../bin/checkcvc32
fi

cd ..

######################################################################################################################################
cd src

make -f makefile.cvc64
cp -av cvc64 ../bin/

make -f makefile.cvc64 clean
rm -f libz.a

if [ $with_i386 -ge 1 ]
then
        make -f makefile.cvc
        cp -av cvc ../bin/cvc32

        make -f makefile.cvc clean
        rm -f libz.a
fi

cd ..

######################################################################################################################################
cd bin

ln -s cvc64 cvc
ln -s checkcvc64 checkcvc

cd ..

######################################################################################################################################

export PATH="$PATH:$(pwd)/bin"

ulimit -c unlimited


######################################################################################################################################

cd tests_and_examples/examples.acc/
./clean.sh || true

sed -e 'sX/bin/shX/bin/bashX' -i inst_pli.sh    # >& use
./inst_pli.sh cvc64

rm -f acc_probe.so clean cvcsim verilog.log

cd ../..

######################################################################################################################################

cd tests_and_examples/examples.dpi/

###
### cvc64 -q -sv_lib export.so export.v >/dev/null
###
sed -e 'sX/bin/shX/bin/bashX' -i dpi_tests.sh   # >& use
./dpi_tests.sh cvc64

cd ../..

######################################################################################################################################

cd tests_and_examples/examples.tf/
./clean.sh || true

sed -e 'sX/bin/shX/bin/bashX' -i inst_pli.sh    # >& use
./inst_pli.sh cvc64

rm -f acc_probe.so clean cvcsim verilog.log

cd ../..

######################################################################################################################################

cd tests_and_examples/examples.vpi
./clean.sh || true

sed -e 'sX/bin/shX/bin/bashX' -i inst_pli.sh    # >& use
./inst_pli.sh cvc64

rm -f acc_probe.so clean cvcsim verilog.log

cd ../..

######################################################################################################################################

cd tests_and_examples/examples.xprop

sed -e 'sX/bin/shX/bin/bashX' -i xprop_test.sh   # >& use
./xprop_test.sh cvc64

rm -f acc_probe.so clean cvcsim verilog.log

cd ../..

######################################################################################################################################

cd tests_and_examples/install.test

./inst_test.sh cvc64
./inst_test_interp.sh cvc64

rm -f acc_probe.so clean cvcsim verilog.log

cd ../..

######################################################################################################################################


######################################################################################################################################

