#!/bin/sh
make -j8
make uImage -j8
make modules_install INSTALL_MOD_PATH=../../pogoplug/
cd ../../pogoplug/lib/modules
rm lib.tar.bz2
tar jcvf lib.tar.bz2 ./2.6.31.6_SMP_820
