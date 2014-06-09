#!/bin/sh
echo "#############################"
echo "##"
echo "## Pogoplug OXNAS based boards"
echo "## uImage updater"
echo "##"
echo "#############################"
echo "##"
echo "## For use with OXNAS 7820 only."
echo "##"
echo "#############################"

echo "## PREPARATION "
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

#######
## GET files
#######
echo "#############################"
echo "## RETRIEVING FILES "
echo "# Downloading uImage...(approx. < 3MB)"
rm uImage
wget http://192.168.2.100/uImage

if [ -f /tmp/uImage ]
then	
#	echo "# Recording MAC Address"
#	echo "$MAC" > usr/local/mac_addr
#	echo "# Coping key CE binaries..."
#	cp -ar /usr/local/cloudengines usr/local/
#	cp /usr/sbin/nandwrite usr/local/cloudengines/bin/
#			cp /usr/sbin/flash_erase usr/local/cloudengines/bin/
#	cp /usr/sbin/nanddump usr/local/cloudengines/bin/
#	echo "# Done copying."
	echo "#############################"	
	echo "## FLASHING NAND & UBOOT VARS"
#	echo "# backing up mtd1"
#	/usr/sbin/nanddump -o -f mtd1.dump /dev/mtd1
	echo "# Erasing mtd1 @ 0x500000 for 21 erase blocks (kernel location)"
	/usr/sbin/flash_erase /dev/mtd1 0x500000 21
#			echo "# Erasing mtd1 @ 0xB00000 for 17 erase blocks (2nd kernel location)"
#	/usr/sbin/flash_erase /dev/mtd1 0xB00000 17

	########
	## flash kernel
	########
	echo "# Flashing Kernel..."
		echo "# - @ 0x500000"
		/usr/sbin/nandwrite -p -s 0x500000 /dev/mtd1 /tmp/uImage
#		echo "# - @ 0xB00000"
#					/usr/sbin/nandwrite -p -s 0xB00000 /dev/mtd1 /tmp/usb/boot/uImage.pci

	echo "# Done Flashing Kernel"
	echo ""
	#######
	## flash boot arguments
	#######
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
		echo "Contact #archlinux-arm to confirm."
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
		#/sbin/reboot
	fi
else
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "DOWNLOAD FAILED"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
