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

#define MAX_BUF 34
#define COUNT 2
int main (char** argv, int argc)
{
    char* start_addr = NULL;
    char* end_addr = NULL;

    char* name = "opensuse64";
    vmi_instance_t vmi;
    int ret_count;
    char* symbol = NULL;
    char* addr = NULL;

    uint64_t counter = 0;
/*---------------------Linux Pipe---------------------------*/
    int fdone;             //Linux Pipe 1
    int fdtwo;            //Linux Pipe 2
    char * ffone = "/home/harpreet10oct/test_dir_sample_code/ffone";        //Linux Pipe
    char * fftwo = "/home/harpreet10oct/test_dir_sample_code/fftwo";
    char buf[MAX_BUF];
    uint64_t st_addr, en_addr;

    mkfifo(ffone, 0666);        //Create Pipe 2

//    fdone = open(ffone, O_RDONLY);      //Open Pipe 1 for Read

//    fdtwo = open(fftwo, O_WRONLY);      //open Pipe 2 for Write


/*-----------------------End Linux Pipe--------------------------------*/
/*-----------------------Linux Pipe--------------------------------*/

    while(1)
    {
//        mkfifo(ffone, 0666);        //Create Pipe 1
    	fdone = open(ffone, O_RDONLY);      //Open Pipe 1 for Read


    	read(fdone, buf, MAX_BUF);
    	fprintf(stderr,"Received: %s\n", buf);
//    	fsync(fdone);


    	fdtwo = open(fftwo, O_WRONLY);      //open Pipe 2 for Write
//   	write(fdtwo, "reject", 7);             //Write to Pipe 2
//  	fprintf(stderr, "Written Successfully!!\n");
//    	fsync(fdtwo);

#if 0
    	write(fdtwo, "accept", 7);             //Write to Pipe 2
    	fprintf(stderr, "Written Successfully!!\n");
    	fsync(fdtwo);

    	close(fdone);
    	close(fdtwo);
    	unlink(ffone);
#endif
/*-----------------------End Linux Pipe--------------------------------*/

    	printf("Value: %s\n", buf);

    	start_addr = strtok(buf, " ");
    	printf("Starting Address: %s\n", start_addr);    
    
    	st_addr = (uint64_t) strtoul(start_addr, NULL, strlen(start_addr));
    	printf("Starting Address in unsigned long int: %" PRIu64 "\n", st_addr);    
	
    	end_addr = strtok(NULL, " ");
    	printf("End Address: %s\n", end_addr);   
    	en_addr = (uint64_t) strtoul(end_addr, NULL, strlen(end_addr));
    	printf("End Address in unsigned long int: %" PRIu64 "\n", en_addr);    


    	if (vmi_init(&vmi, VMI_AUTO | VMI_INIT_COMPLETE, name) == VMI_FAILURE) {
            printf("Failed to init LibVMI library.\n");
            return 1;
    	}

    	printf("success to init LibVMI\n");
    	symbol = malloc (2 * sizeof(char));
    	addr_t paddr = vmi_translate_kv2p ( vmi, start_addr );
    	//ret_count = vmi_read_pa (vmi, paddr, symbol, COUNT);
    	printf("The buffer at pa %" PRIu64 " has count: %d \n", paddr, ret_count);
    	printf("The value inside buf %d\n", *symbol);
//    write(fdtwo, "reject", 7);             //Write to Pipe 2
//    	fsync(fdtwo);

    	for ( counter = st_addr; counter <= en_addr; counter++ )
    	{
            ret_count = vmi_read_pa (vmi, counter, symbol, COUNT);
	    if ( strcmp(symbol, "&" ) )
	    {
	    	//printf("Wrong canary detected\n");
            	write(fdtwo, "reject", 7);             //Write to Pipe 2
	    
            	fprintf(stderr, "Overflow encountered!!\n");
            	fsync(fdtwo);
	    	break;
	    }
	    else
	    {
            	write(fdtwo, "accept", 7);             //Write to Pipe 2
            	fprintf(stderr, "Written Successfully!!\n");
            	fsync(fdtwo);
	    }
        }
    
    vmi_destroy(vmi);

    close(fdone);
    close(fdtwo);

//    unlink(ffone);    
    free(symbol);

    start_addr = NULL;
    end_addr = NULL;

    symbol = NULL;

    }
#if 0
    close(fdone);
    close(fdtwo);
    unlink(ffone);    
    vmi_destroy(vmi);

    free(symbol);

    start_addr = NULL;
    end_addr = NULL;

    symbol = NULL;
#endif
    return 1;

}

