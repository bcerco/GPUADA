#include "SBA.h"

/*
 * Brandon Cercone
 * Serial Banker's Algorithm
 */
int main (int argc, char *argv[]) {
	int p,r,num_processes,num_resources;
    uint64_t start, stop;
	FILE *file;
	char * line = NULL;
	size_t len = 0;
	ssize_t read;
	char *tokens;
	int debug = 0;
	int sort = 0;
	//printf("Args: %d\n",argc);
	if (argc < 2){
		printf("ERROR: args=%d",argc);
		exit(EXIT_FAILURE);
	}
	if (argc >= 3){
        if (strcmp(argv[2],"-s") == 0) sort = 1;
        if (strcmp(argv[2],"-d") == 0) debug = 1;
    }
	if (argc == 4 && strcmp(argv[3],"-d") == 0) debug = 1;
	/* Arg 1: Filename for matrix and resource vector */
	if (debug) printf("File: %s\n",argv[1]);
	file=fopen(argv[1], "r");
	if (file == NULL)
		exit(EXIT_FAILURE);
	/* First line in the file is the number of processes */
	read = getline(&line, &len, file);
	num_processes = atoi(line);
	/* Second line in the file is the number of resources */
	read = getline(&line, &len, file);
	num_resources = atoi(line);
	/* Allocate memory for resource vectors and matrix */
	int r_avail[num_resources];
	//int r_request[num_resources];
	int p_sequence[num_processes];
	int p_seen[num_processes];
	int *r_alloc[num_processes];
	int *r_max[num_processes];
	int *r_need[num_processes];
	for (p = 0; p < num_processes; p++){
		r_alloc[p] = (int *)malloc(num_resources * sizeof(int));
		r_max[p] = (int *)malloc(num_resources * sizeof(int));
		r_need[p] = (int *)malloc(num_resources * sizeof(int));
		p_seen[p] = 0;
		p_sequence[p] = -1;
	}
	/* Third line in the file is the request vector */
	//read = getline(&line, &len, file);
	//store_vector(r_request,line);
    //if (debug){
    //    printf("r_request: ");
    //    print_vector(r_request, num_resources);
    //}
	/* Fourth line in file is the resources available vector */
	read = getline(&line, &len, file);
	store_vector(r_avail,line);
    if (debug){
        printf("r_avail: ");
        print_vector(r_avail, num_resources);
    }
	/* Read in the maximum reource needed matrix from file */
	for (p = 0; p < num_processes; p++){
		read = getline(&line, &len, file);
		r = 0;
		tokens = strtok(line,",");
		while (tokens != NULL){
			r_max[p][r++] = atoi(tokens);
			tokens = strtok(NULL,",");
		}
	}
	/* Read in the reource allocation matrix from file */
	/* Calculate values for the need matrix */
	for (p = 0; p < num_processes; p++){
		read = getline(&line, &len, file);
		r = 0;
		tokens = strtok(line,",");
		while (tokens != NULL){
			r_alloc[p][r] = atoi(tokens);
			r_need[p][r] = r_max[p][r] - r_alloc[p][r];
			tokens = strtok(NULL,",");
			r++;
		}
	}
	fclose(file);
	if (line)
		free(line);
	/* Print for testing */
	if (debug) {
		printf("---MAX Matrix---\n");
		print_matrix(r_max,num_processes,num_resources);
		printf("---ALLOC Matrix---\n");
		print_matrix(r_alloc,num_processes,num_resources);
		printf("---NEED Matrix---\n");
		print_matrix(r_need,num_processes,num_resources);
	}
    if (sort){
        start = rdtsc();
        sort_matrix(r_need,r_alloc,num_processes,num_resources);
        stop = rdtsc();
        printf("Sort cycles: %" PRIu64 "\n", (stop - start));
        if (debug) {
            printf("---Sorted NEED---\n");
            print_matrix(r_need,num_processes,num_resources);
            printf("---Sorted Alloc---\n");
            print_matrix(r_alloc,num_processes,num_resources);
        }
    }
	//if (!resource_check(r_alloc,r_request,r_avail,p_sequence,p_seen,num_resources,process_id))
	//	printf("DENIED\n");
	//else{
    start = rdtsc();
    if (bankers_alg(r_alloc,r_need,r_avail,p_sequence,p_seen,num_processes,num_resources)){
        printf("GRANTED\n");
        stop = rdtsc();
    }
    else{
        printf("DENIED\n");
        stop = rdtsc();
    }
    printf("BA cycles: %" PRIu64 "\n", (stop - start));

    if (debug){
        printf("p_sequence: ");
        print_vector(p_sequence, num_processes);
        printf("p_seen: ");
        print_vector(p_seen, num_processes);
        printf("r_avail: ");
        print_vector(r_avail, num_resources);
    }
	for (p = 0; p < num_processes; p++){
		free(r_alloc[p]);
		free(r_max[p]);
		free(r_need[p]);
	}
	exit(EXIT_SUCCESS);
}
