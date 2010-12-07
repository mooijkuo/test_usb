#!/bin/bash

echo ""
echo "==============================Test usb driver.=============================="

SOURCE_FILE=tousb.mp4
SOURCE_FILE1=test.mp4
SOURCE_DIR1=/mnt/usb/
TARGET_DIR1=/tmp/

USB_PATH1=/dev/usb_1st_port1
USB_PATH2=/dev/usb_2nd_port1
USB_PATH3=/dev/usb_3rd_port1
USB_PATH4=/dev/usb_4th_port1

test -e $SOURCE_DIR1 || mkdir $SOURCE_DIR1

USB_LIST="$USB_PATH1 $USB_PATH2 $USB_PATH3 $USB_PATH4"
haveusb=0
for path in $USB_LIST
do
	if [ $haveusb == 0 ]; then
		test -e $path && mount $path $SOURCE_DIR1 && haveusb=1 && echo "found device : $path" || echo "no device $path"
	fi
done

#test -e  $USB_PATH   &&  mount $USB_PATH  $SOURCE_DIR1 || echo "no device : $USB_PATH"

test -e $SOURCE_DIR1$SOURCE_FILE && echo "src file=$SOURCE_DIR1$SOURCE_FILE" && run=1 || run=0

ok_count=0
err_count=0
src_sum=0
tar_sum=0

if [ $run == 1 ]; then
	echo "copy file to tmp"
	cp $SOURCE_DIR1$SOURCE_FILE $TARGET_DIR1$SOURCE_FILE1
	src_sum=123
	tar_sum=456
	test -e $SOURCE_DIR1$SOURCE_FILE && src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE)
	test -e $TARGET_DIR1$SOURCE_FILE1 && tar_sum=$(busybox sum $TARGET_DIR1$SOURCE_FILE1)  

	if [ "$src_sum" = "$tar_sum" ]; then
		echo "copy ok!"
	else
		echo "copy wrong!" && run=0
	fi

echo "test start"
busybox date
fi

while [ $run == 1 ]
do
	echo "write data : tmp -> usb"
	cp $TARGET_DIR1$SOURCE_FILE1 $SOURCE_DIR1

	src_sum=123
        tar_sum=456   
        test -e $SOURCE_DIR1$SOURCE_FILE1 && src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE1)
        test -e $TARGET_DIR1$SOURCE_FILE1 && tar_sum=$(busybox sum $TARGET_DIR1$SOURCE_FILE1)  
        
        if [ "$src_sum" = "$tar_sum" ]; then
        	ok_count=$(($ok_count+1))
        else
        	err_count=$(($err_count+1))
        fi

	echo "delete : $TARGET_DIR1$SOURCE_FILE1"
	rm $TARGET_DIR1$SOURCE_FILE1
	sync

	ls $SOURCE_DIR1$SOURCE_FILE1
	echo "s_sum = $src_sum,t_sum = $tar_sum,ok = $ok_count,err = $err_count"
	busybox date


	echo "read data : usb -> tmp"
        cp $SOURCE_DIR1$SOURCE_FILE1 $TARGET_DIR1

        src_sum=123
        tar_sum=456
        test -e $SOURCE_DIR1$SOURCE_FILE1 && src_sum=$(busybox sum $SOURCE_DIR1$SOURCE_FILE1)
        test -e $TARGET_DIR1$SOURCE_FILE1 && tar_sum=$(busybox sum $TARGET_DIR1$SOURCE_FILE1)  
        
        if [ "$src_sum" = "$tar_sum" ]; then
        	ok_count=$(($ok_count+1))
        else
        	err_count=$(($err_count+1))
        fi

	echo "delete : $SOURCE_DIR1$SOURCE_FILE1"
        rm $SOURCE_DIR1$SOURCE_FILE1
        sync

        ls $TARGET_DIR1$SOURCE_FILE1
        echo "s_sum = $src_sum,t_sum = $tar_sum,ok = $ok_count,err = $err_count"
	busybox date

done

echo "==============================Test end.=============================="
echo ""
