#include "uthash.h"
#include <stdlib.h>   /* malloc */
#include <stdio.h>    /* printf */

typedef struct example_proc_t {
    //int id;
    char *procname;
    UT_hash_handle hh;
} example_proc_t;

int main(int argc,char *argv[])
{
    //int i;

    char const* const fileName = "/home/zhen/hash/data2.txt"; /* should check that argc > 1 */
    FILE* file = fopen(fileName, "r"); /* should check the result */
    char line[256];

    char *good = "ping";
    char *bad = "A26D.exe";

    example_proc_t *proc, *tmp,*s=NULL;

    /* create elements */

    while (fgets(line, sizeof(line), file)) {
    fgets(line, sizeof(line), file);
        proc = (example_proc_t*)malloc(sizeof(example_proc_t));
        if (proc == NULL) {
            exit(-1);
        }
//	proc->procname = (char *)malloc(strlen(line));
	
      line[strlen(line)-1] = '\0';
    proc->procname = line;
//    strcpy(proc->procname, line);

    printf("%s\n", line);

    HASH_ADD_STR(s, procname, proc);
//    for(proc=s; proc != NULL; proc=proc->hh.next) {
//        printf("procname %s\n", proc->procname);
//    }
    
    }

	
    printf("Add Successfully!\n");
	
    /*
    printf("hh items: %d, alth items: %d\n",
            users->hh.tbl->num_items, users->alth.tbl->num_items);
    printf("hh buckets: %d, alth buckets: %d\n",
            users->hh.tbl->num_buckets, users->alth.tbl->num_buckets);
    */
    //i = 1;
      HASH_FIND_STR(s, good, tmp);
//    HASH_FIND(hh,s,&good,sizeof(char),tmp);
    printf("process %s %s in proc\n", good, (tmp != NULL) ? "found" : "not found");

    //i = 2;
   // HASH_FIND(hh,s,&bad,strlen(bad),tmp);
    HASH_FIND_STR(s, bad, tmp);
    printf("process %s %s in proc\n", bad, (tmp != NULL) ? "found" : "not found");

    return 0;
}
