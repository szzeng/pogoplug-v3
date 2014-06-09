#!/bin/sh
make -j8
make uImage -j8
make modules_install INSTALL_MOD_PATH=../../pogoplug/
cd ../../pogoplug/lib/modules
rm xxx
tar jcvf xxx ./2.6.31.6_SMP_820
