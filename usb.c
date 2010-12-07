#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

int main(void)
{
	int usb1fail = 0,usb2fail = 0;
	int fd_usb,writewords,readwords,mountusb;
	char usbstr[]="write_data_to_usb!",usbbuffer[sizeof(usbstr)];

	printf("\n========= usb test =========\n");
//usb_3rd_port
	if(access("/dev/usb_3rd_port",F_OK) != 0){
		printf("\nusb device : /dev/usb_3rd_port not found.\n");
		printf("\n======= usb test end =======\n");
		return -1;
	}
	else
		mountusb = system("mount /dev/usb_3rd_port1 /mnt");
	
	if(mountusb == 0){
		printf("\ncreate file.\n");
		fd_usb = open("/mnt/usb1.txt", O_CREAT | O_RDWR | O_SYNC, 0666);
		if(fd_usb < 0){
			printf("\nusb create file fail.\n");
			usb1fail = 1;
		}
		else{
			printf("write data %d words : %s\n",sizeof(usbstr),usbstr);
			writewords = write(fd_usb,usbstr,sizeof(usbstr));
			if(writewords < sizeof(usbstr)){
				printf("\nwrite fail : only write %d words!\n",writewords);
				usb1fail = 1;
			}
			close(fd_usb);
	
			printf("\nread file.\n");
			fd_usb = open("/mnt/usb1.txt", O_RDONLY);
			if(fd_usb < 0){
				printf("\nusb open file fail.\n");
				usb1fail = 1;
			}
			else{
				readwords = read(fd_usb,usbbuffer,writewords);
				if(readwords < writewords){
					printf("\nread fail : only read %d words : %s\n",readwords,usbbuffer);
					usb1fail = 1;
				}
				else
					printf("read data %d words : %s\n",readwords,usbbuffer);
				close(fd_usb);
			}
		
			if(unlink("/mnt/usb1.txt") < 0){
				printf("\ndelete data fail!\n");
				usb1fail = 1;
			}
	
			if(strncmp(usbstr,usbbuffer,sizeof(usbstr)) != 0){
				printf("\nwrite & read data not match\n");
				usb1fail = 1;
			}
		}
		system("umount /mnt");
	}
	else
		usb1fail = 1;
	
	if(usb1fail)
		printf("\nusb_3rd_port test fail!\n");
	else
		printf("\nusb_3rd_port test pass!\n");
	
	
//usb_4th_port
	if(access("/dev/usb_4th_port",F_OK) != 0){
		printf("\nusb device : /dev/usb_4th_port not found.\n");
		usb2fail = 1;
	}
	else{
		mountusb = system("mount /dev/usb_4th_port1 /mnt");
		if(mountusb == 0){
			printf("\ncreate file.\n");
			fd_usb = open("/mnt/usb2.txt", O_CREAT | O_RDWR | O_SYNC, 0666);
			if(fd_usb < 0){
				printf("\nusb create file fail.\n");
				usb2fail = 1;
			}
			else{
				printf("write data %d words : %s\n",sizeof(usbstr),usbstr);
				writewords = 0;
				writewords = write(fd_usb,usbstr,sizeof(usbstr));
				if(writewords < sizeof(usbstr)){
					printf("\nwrite fail : only write %d words!\n",writewords);
					usb2fail = 1;
				}
				close(fd_usb);
	
				printf("\nread file.\n");
				fd_usb = open("/mnt/usb2.txt", O_RDONLY);
				if(fd_usb < 0){
					printf("\nusb open file fail.\n");
					usb2fail = 1;
				}
				else{
					readwords = 0;
					memset(usbbuffer,0,sizeof(usbbuffer));
					readwords = read(fd_usb,usbbuffer,writewords);
					if(readwords < writewords){
						printf("\nread fail : only read %d words : %s\n",readwords,usbbuffer);
						usb2fail = 1;
					}
					else
						printf("read data %d words : %s\n",readwords,usbbuffer);
					close(fd_usb);
				}
	
				if(unlink("/mnt/usb2.txt") < 0){
					printf("\ndelete data fail!\n");
					usb2fail = 1;
				}
	
				if(strncmp(usbstr,usbbuffer,sizeof(usbstr)) != 0){
					printf("\nwrite & read data not match\n");
					usb2fail = 1;
				}
			}
			system("umount /mnt");
		}
		else
			usb2fail = 1;
	}
	
	if(usb2fail)
		printf("\nusb_4th_port test fail!\n");
	else
		printf("\nusb_4th_port test pass!\n");
	
	printf("\n======= usb test end =======\n");
	
}