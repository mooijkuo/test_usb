#!/bin/bash

echo ""
echo "==============================Test usb driver.=============================="

SOURCE_FILE=tousb.mp4
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

echo "test start"
busybox date
while [ $run == 1 ]
do
	echo "read data : usb -> tmp"
        cp $SOURCE_DIR1$SOURCE_FILE $TARGET_DIR1

        src_sum=123
        tar_sum=456
        test -e $SOURCE_DIR1$SOURCE_FILE && src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE)
        test -e $TARGET_DIR1$SOURCE_FILE && tar_sum=$(busybox sum $TARGET_DIR1$SOURCE_FILE)  
        
        if [ "$src_sum" = "$tar_sum" ]; then
        	ok_count=$(($ok_count+1))
        else
        	err_count=$(($err_count+1))
        fi

        ls $TARGET_DIR1$SOURCE_FILE
        echo "s_sum = $src_sum,t_sum = $tar_sum,ok = $ok_count,err = $err_count"
	busybox date

	echo "delete : $TARGET_DIR1$SOURCE_FILE"
        rm $TARGET_DIR1$SOURCE_FILE
        sync

done
umount $MOUNT_DIR

echo "==============================Test end.=============================="
echo ""
