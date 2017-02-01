#include <assert.h>
#include <arpa/inet.h>


#include <stdlib.h>
#include <unistd.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
#include <sys/mman.h>

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <libvmi/libvmi.h>

//#include "pipe.h"

struct vmi_requirements
{
    uint64_t *st_addr;
    uint64_t *en_addr;
};

#define COUNT 2
int main (char** argv, int argc)
{
    struct vmi_requirements vmi_req;
    char* name = "opensuse64";
    vmi_instance_t vmi;
    int ret_count;
    int a = 1;
    int b = 0;
    int *t = malloc(sizeof(int));
    int *f = malloc(sizeof(int));
    t = &a;
    f = &b;
    uint64_t canary;

    uint64_t counter = 0;
/*---------------------Linux Pipe---------------------------*/
    int vmi_read_fd;             //Linux Pipe 1
    int vmi_write_fd;            //Linux Pipe 2
    char * vmi_read_ff = "/home/harpreet10oct/test_dir_sample_code/xen_to_vmi";        //Linux Pipe
    char * vmi_write_ff = "/home/harpreet10oct/test_dir_sample_code/vmi_to_xen";
    uint64_t *buf = malloc(sizeof(uint64_t));
//    uint64_t st_addr, en_addr;

    mkfifo(vmi_read_ff, 0666);        //Create Pipe 1

    vmi_read_fd = open(vmi_read_ff, O_RDONLY);      //Open Pipe 1 for Read
    vmi_write_fd = open(vmi_write_ff, O_WRONLY);      //open Pipe 2 for Write



    if (vmi_init(&vmi, VMI_AUTO | VMI_INIT_COMPLETE, name) == VMI_FAILURE) {
        printf("Failed to init LibVMI library.\n");
            return 1;
    }

    printf("success to init LibVMI\n");
/*
    read(vmi_read_fd, buf, sizeof(void *));
    fprintf(stderr,"Received: %" PRIu64 "\n", *buf);
    vmi_req.st_addr = buf;
    printf("Value: %" PRIu64 "\n", *(vmi_req.st_addr));
*/
#if 0
    read(vmi_read_fd, &buf, MAX_BUF);
    fprintf(stderr,"Received: %" PRIu64 "\n", buf);
    vmi_req.en_addr = buf;
    printf("Value: %" PRIu64 "\n", vmi_req.en_addr);
#endif   
    while(1)
    {
        /*
         * Translate a kernel VA of the VM into its corresponding physical address
         */
        read(vmi_read_fd, buf, sizeof(void *));
        fprintf(stderr,"Received: %" PRIu64 "\n", *buf);
        vmi_req.st_addr = buf;
        printf("Value: %" PRIu64 "\n", *(vmi_req.st_addr));

    	addr_t paddr1 = vmi_translate_kv2p ( vmi, *(vmi_req.st_addr) );
    	//addr_t paddr2 = vmi_translate_kv2p ( vmi, vmi_req.en_addr );
    	//ret_count = vmi_read_pa (vmi, paddr, &canary, COUNT);
    	printf("The buffer at pa %" PRIu64 " has count: %d \n", paddr1, ret_count);
    	printf("The value inside buf %" PRIu64 "\n", canary);

        /*
         * Read Canary from address paddr1
         */
        ret_count = vmi_read_pa (vmi, paddr1, &canary, COUNT);
    	printf("The buffer at pa %" PRIu64 " has count: %d \n", paddr1, ret_count);
	if (canary != 100)
        {
	    printf("Wrong canary detected\n");
            write(vmi_write_fd, f, sizeof(int));             //Write to Pipe 2
	    fprintf(stderr, "Overflow encountered!!\n");
            fsync(vmi_write_fd);
	    //goto del_xen_to_vmi;
	    break;
	}
	else
	{
            write(vmi_write_fd, t, sizeof(int));             //Write to Pipe 2
            fprintf(stderr, "Written Successfully!!\n");
            fsync(vmi_write_fd);
	}
        usleep(20000);
   }
        vmi_destroy(vmi);
 
    	close(vmi_read_fd);
    	close(vmi_write_fd);

    	unlink(vmi_read_ff);    


    return 1;
}
