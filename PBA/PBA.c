#include<stdio.h>
#include<stdlib.h>
#include<malloc.h>
#include<string.h>

/*
 * Brandon Cercone
 * Parallel Banker's Algorithm
 */
#define P 10
#define R 10
void store_vector(int *array, char *line){
	char *tokens = strtok(line,",");
	int i = 0;
	while (tokens != NULL){
		array[i++] = atoi(tokens);
		tokens = strtok(NULL,",");
	}
}
int main (int argc, char *argv[]) {
	int p,r,num_processes,num_resources;
	FILE *file;
	char * line = NULL;
	size_t len = 0;
	ssize_t read;
	char *tokens;
    int size = P * R * sizeof(int);
    int index = 0;
	if (argc < 2){
		printf("ERROR: args=%d",argc);
		exit(EXIT_FAILURE);
    }
	/* Arg 1: Filename for matrix and resource vector */
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
	int *r_alloc, *r_max, *r_need, *r_out;
	int *gpu_r_alloc, *gpu_r_need, *gpu_r_out;
    r_alloc = (int *)malloc(size);
    r_max = (int *)malloc(size);
    r_need = (int *)malloc(size);
    r_out = (int *)malloc(size);
	for (p = 0; p < num_processes; p++){
		p_seen[p] = 0;
		p_sequence[p] = -1;
	}
	/* Fourth line in file is the resources available vector */
	read = getline(&line, &len, file);
	store_vector(r_avail,line);
	/* Read in the maximum reource needed matrix from file */
	for (p = 0; p < num_processes; p++){
		read = getline(&line, &len, file);
		tokens = strtok(line,",");
		while (tokens != NULL){
			r_max[index++] = atoi(tokens);
			tokens = strtok(NULL,",");
		}
	}
	/* Read in the reource allocation matrix from file */
	/* Calculate values for the need matrix */
    index = 0;
	for (p = 0; p < num_processes; p++){
		read = getline(&line, &len, file);
		tokens = strtok(line,",");
		while (tokens != NULL){
			r_alloc[index] = atoi(tokens);
			r_need[index] = r_max[index] - r_alloc[index];
			tokens = strtok(NULL,",");
			index++;
		}
	}
	fclose(file);
	if (line)
		free(line);
	for (p = 0; p < num_processes; p++){
	    for (r = 0; r < num_resources; r++){
            printf("%d ", r_need[num_processes * p + r]);
        }
        printf("\n");
	}


    free(r_alloc);
    free(r_max);
    free(r_need);
	exit(EXIT_SUCCESS);
}
