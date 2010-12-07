#!/bin/bash

echo ""
echo "==============================Test usb driver.=============================="

SOURCE_FILE=tousb.mp4
SOURCE_FILE2=write_to_usb.mp4
SOURCE_DIR1=/mnt/usb/
TARGET_DIR1=/tmp/
USB_PATH=/dev/sda1

#umount $MOUNT_DIR
test -e $SOURCE_DIR1 || mkdir $SOURCE_DIR1
test  -e  $USB_PATH   &&  mount $USB_PATH  $SOURCE_DIR1 || echo "no device : $USB_PATH"

echo "src file=$SOURCE_DIR1$SOURCE_FILE"
test -e $SOURCE_DIR1$SOURCE_FILE && run=1 || run=0

ok_count=0
err_count=0
src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE)
tar_sum=0
echo "sum = $src_sum"

test -e $SOURCE_DIR1$SOURCE_FILE2 && rm $SOURCE_DIR1$SOURCE_FILE2

echo "copy data : usb -> tmp"
cp $SOURCE_DIR1$SOURCE_FILE $TARGET_DIR1

src_sum=123
tar_sum=456
test -e $SOURCE_DIR1$SOURCE_FILE && src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE)
test -e $TARGET_DIR1$SOURCE_FILE && tar_sum=$(busybox sum $TARGET_DIR1$SOURCE_FILE)  

if [ "$src_sum" = "$tar_sum" ]; then
	echo "copy ok!" && run=1
else
	echo "copy wrong!" && run=0
fi


echo "test start"
while [ $run == 1 ]
do
	busybox date
	echo "write data : tmp -> usb"
	cp $TARGET_DIR1$SOURCE_FILE $SOURCE_DIR1$SOURCE_FILE2
	sync
	busybox date
	ls $SOURCE_DIR1$SOURCE_FILE2

	src_sum=123
        tar_sum=456   
        test -e $SOURCE_DIR1$SOURCE_FILE2 && src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE2)
        test -e $TARGET_DIR1$SOURCE_FILE && tar_sum=$(busybox sum $TARGET_DIR1$SOURCE_FILE)  
        
        if [ "$src_sum" = "$tar_sum" ]; then
        	ok_count=$(($ok_count+1))
        else
        	err_count=$(($err_count+1))
        fi
	echo "s_sum = $src_sum,t_sum = $tar_sum,ok = $ok_count,err = $err_count"

	echo "delete : $SOURCE_DIR1$SOURCE_FILE2"
	rm $SOURCE_DIR1$SOURCE_FILE2
	sync

done
umount $MOUNT_DIR

echo "==============================Test end.=============================="
echo ""
