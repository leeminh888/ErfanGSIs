#!/bin/bash

#Variables

PARTITIONS=("system" "product")
payload_extractor="tools/update_payload_extractor/extract.py"
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
outdir="$LOCALDIR/cache"
tmpdir="$outdir/tmp"
#############################################################

usage() {
    echo "Usage: $0 <Firmware Type> [Path to Firmware]"
    echo -e "\tFirmware Type! = JoyUI"
    echo -e "\tPath to Firmware!"
}

if [ "$1" == "" ]; then
    echo "Enter all needed parameters"
    usage
    exit 1
fi

echo "Create Temp and out dir"
	mkdir -p "$tmpdir"
	mkdir -p "$outdir"

unzip $2 -d $tmpdir &> /dev/null
echo "Extracting Required Partitions . . . . "
		for partition in ${PARTITIONS[@]}; do
 	   	    python $payload_extractor --partitions $partition --output_dir $tmpdir $tmpdir/payload.bin 
		done
	mv $tmpdir/system $outdir/system-old.img
	mv $tmpdir/product $outdir/product.img
	mv $tmpdir/opproduct $outdir/opproduct.img
rm -rf $tmpdir

echo "Creating Dummy System Image . . . . "
dd if=/dev/zero of=$outdir/system.img bs=4k count=1048576
mkfs.ext4 $outdir/system.img
tune2fs -c0 -i0 $outdir/system.img

echo "Mounting System Images . . . . "
	mkdir system
	mkdir system-old
	mount -o loop $outdir/system.img system/
	mount -o ro $outdir/system-old.img system-old/
	echo "  "
echo "Copying Files . . . . "

	cp -v -r -p system-old/* system/ &> /dev/null
	sync
	umount system-old
	rm $outdir/system-old.img
	rm -rf system/product
	ln -s system/product system/product
    	rm -rf system/system/product
    	mkdir system/system/product/
      
echo "Merging product.img "
	sudo mkdir $outdir/product
	mount -o ro $outdir/product.img $outdir/product/
	cp -v -r -p $outdir/product/* system/system/product/ &> /dev/null
	sync
	umount $outdir/product
	rmdir $outdir/product/
	rm $outdir/product.img

echo "Finalising . . . . "
        mkdir working
        cp -r system working/ &> /dev/null
        umount system
        rm -rf $outdir/system.img
        rm -rf cache
	rm -rf system
echo "Done"ript"
