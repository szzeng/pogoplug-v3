#!/bin/sh

if [ "$1" == "" ]
then
    echo "Please specify keyword!"
	echo " nand or usb"
    exit 1
fi

KEY_WORD=$1
echo "#############################"
echo "##"
echo "## Switching boot from $KEY_WORD"
echo "##"
echo "#############################"

echo "# Switching to /tmp..."
cd /tmp
echo "# Ensuring we're ready to proceed..."
killall hbwd
umount /dev/sda1
echo "# Preparing our way..."
mkdir /tmp/usb
mount /dev/sda1 /tmp/usb

## get the things we need from blparam
echo "# Getting uboot parameters..."
/usr/local/cloudengines/bin/blparam > blparam.txt

MAC=`grep -e '^ethaddr=' blparam.txt | sed 's/^ethaddr=//'`
LNAND=`grep -e '^load_nand=' blparam.txt | sed 's/^load_nand=//'`
BOOTARGS=`grep -e '^bootargs=' blparam.txt | sed 's/^bootargs=//'`
BOARDVER=`grep -e '^ceboardver=' blparam.txt | sed 's/^ceboardver=//'`
echo "# = MAC : $MAC"
echo "# = load_nand : $LNAND"
echo "# = bootargs : $BOOTARGS"
echo "# = board : $BOARDVER"
echo "# "

echo "# Checking board revision..."

if [ "$BOARDVER" != "PPRO1" -a "$BOARDVER" != "PPROHD1" -a "$BOARDVER" != "PPV3" ]
then
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "ABORTING!!! UNSUPPORTED MODEL"
        echo "================================="
        echo "See the wiki on models supported"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        exit
fi
PCI=0
if [ "$BOARDVER" = "PPRO1" ]
then
	PCI=1
fi
if [ "$BOARDVER" = "PPROHD1" ]
then
        PCI=1 
fi
echo "# board has PCI: $PCI"
echo "#"

echo "# Deriving boot partition format..."
mount > mount.txt
FMT=`grep /tmp/usb mount.txt | sed 's/\/dev\/sda1 on \/tmp\/usb type //' | sed 's/ (.*$//'`
PART='/dev/sda1'
echo "# = PARTITION: $PART"
echo "# = FMT : $FMT"
echo "# "

if [ "$FMT" != "ext2" -a "$FMT" != "ext3" ]
then
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "ABORTING!!! Cannot boot from $FMT"
	echo "================================="                    	
	echo "See the wiki on how to format your"
	echo "drive to ext2/ext3"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit
fi

	echo "#############################"	
	echo "## UBOOT VARS"

if [ "$KEY_WORD" = "usb" ]
then
## we want to boot from usb
	cd /tmp
	echo $BOOTARGS > bootarg.txt
	NEWARGS=`cat bootarg.txt | sed 's/ubi0:rootfs/\/dev\/sda1/' | sed "s/ubifs/$FMT/"`
	NEWARGS="$NEWARGS rootwait"
	NLNAND="nboot 60500000 0 500000"

	echo "# NEW uBoot Parameters"
	echo "# = bootargs_usb : $NEWARGS"
	echo "# = load_custom_nand : $NLNAND"
	echo "# = rootfs : /dev/sda1"
	echo "# = root fs type : $FMT"

	echo "# "
	echo "# Setting up uboot parameters"
	/usr/local/cloudengines/bin/blparam bootargs_stock="$BOOTARGS" > /dev/null
	/usr/local/cloudengines/bin/blparam load_custom_nand="$NLNAND" > /dev/null
	/usr/local/cloudengines/bin/blparam load_custom_nand2="nboot 60500000 0 B00000" > /dev/null
	/usr/local/cloudengines/bin/blparam boot_custom="run load_custom_nand boot || run load_custom_nand2 boot" > /dev/null
	/usr/local/cloudengines/bin/blparam bootargs="$NEWARGS" > /dev/null
	/usr/local/cloudengines/bin/blparam bootcmd="run boot_custom"  > /dev/null
	echo "#"
	echo "# Checking uboot parameters..."
	/usr/local/cloudengines/bin/blparam > blparam_new.txt
	CNEWARGS=`grep -e '^bootargs=' blparam_new.txt | sed 's/^bootargs=//'`
	CNLNAND=`grep -e '^load_custom_nand=' blparam_new.txt | sed 's/^load_custom_nand=//'`
	CBOOTCUST=`grep -e '^boot_custom=' blparam_new.txt | sed 's/^boot_custom=//'`
	CBASTOCK=`grep -e '^bootargs_stock=' blparam_new.txt | sed 's/^bootargs_stock=//'`
	echo "# = bootargs_stock : $CBASTOCK"
	echo "# = bootargs : $CNEWARGS"		
	echo "# = load_custom_nand : $CNLNAND"
	echo "# = boot_custom : $CBOOTCUST"
	
	if [ "$CNEWARGS" != "$NEWARGS" -o "$CNLNAND" != "$NLNAND" -o "$CBOOTCUST" != "run load_custom_nand boot || run load_custom_nand2 boot" -o "$CBASTOCK" != "$BOOTARGS" ]
	then
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "One or more uboot parameters failed to set correctly"
		echo "copy the content of blparam_new.txt to pastebin.com"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "ABSOLUTELY DO NOT POWER DOWN OR REBOOT UNITL CONFIRMED"
		exit
	else
		echo "#############################"
		echo "## Looks good!"
		echo "# Sync ..."
		sync
		echo "# Unmount "
		cd /tmp
		umount /dev/sda1
		echo "# Reboot to enter into Arch Linux ARM"
		/sbin/reboot
	fi
else
## we want to boot from nand
	cd /tmp
	echo $BOOTARGS > bootarg.txt
	NEWARGS=`cat bootarg.txt | sed 's/\/dev\/sda1/ubi0:rootfs/' | sed "s/$FMT/ubifs/"`
	NLNAND="nboot 60500000 0 200000"

	echo "# NEW uBoot Parameters"
	echo "# = bootargs_nand : $NEWARGS"
	echo "# = load_nand : $NLNAND"
	echo "# = rootfs : ubi0:rootfs"
	echo "# = root fs type : ubifs"

	echo "# "
	echo "# Setting up uboot parameters"
	/usr/local/cloudengines/bin/blparam bootargs_stock="$BOOTARGS" > /dev/null
	/usr/local/cloudengines/bin/blparam load_nand="$NLNAND" > /dev/null
	/usr/local/cloudengines/bin/blparam load_nand2="nboot 60500000 0 800000" > /dev/null
	/usr/local/cloudengines/bin/blparam boot_nand="run load_nand boot || run load_nand2 boot" > /dev/null
	/usr/local/cloudengines/bin/blparam bootargs="$NEWARGS" > /dev/null
	/usr/local/cloudengines/bin/blparam bootcmd="run boot_nand"  > /dev/null
	echo "#"
	echo "# Checking uboot parameters..."
	/usr/local/cloudengines/bin/blparam > blparam_new.txt
	CNEWARGS=`grep -e '^bootargs=' blparam_new.txt | sed 's/^bootargs=//'`
	CNLNAND=`grep -e '^load_nand=' blparam_new.txt | sed 's/^load_nand=//'`
	CBOOTNAND=`grep -e '^boot_nand=' blparam_new.txt | sed 's/^boot_nand=//'`
	CBASTOCK=`grep -e '^bootargs_stock=' blparam_new.txt | sed 's/^bootargs_stock=//'`
	echo "# = bootargs_stock : $CBASTOCK"
	echo "# = bootargs : $CNEWARGS"		
	echo "# = load_nand : $CNLNAND"
	echo "# = boot_nand : $CBOOTCUST"
	
	if [ "$CNEWARGS" != "$NEWARGS" -o "$CNLNAND" != "$NLNAND" -o "$CBOOTNAND" != "run load_nand boot || run load_nand2 boot" -o "$CBASTOCK" != "$BOOTARGS" ]
	then
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "One or more uboot parameters failed to set correctly"
		echo "copy the content of blparam_new.txt to pastebin.com"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "ABSOLUTELY DO NOT POWER DOWN OR REBOOT UNITL CONFIRMED"
		exit
	else
		echo "#############################"
		echo "## Looks good!"
		echo "# Sync ..."
		sync
		echo "# Unmount "
		cd /tmp
		umount /dev/sda1
		echo "# Reboot to enter into POGOPLUG linux"
		/sbin/reboot
	fi
fi	