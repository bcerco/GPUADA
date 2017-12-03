#include<stdio.h>
#include<stdlib.h>
#include<malloc.h>
#include<string.h>

/*
 * Brandon Cercone
 * Parallel Banker's Algorithm
 */
#define THREADS_PER_BLOCK 1024
#define NUM_OF_BLOCKS 16
__global__ void r_check(int *avail, int *alloc, int *need, int *out, int p, int r){
    __shared__ int s_avail[THREADS_PER_BLOCK];
    int bound = r * p;
    /* Index into the allocation vector using the thread id */
    int t_index = threadIdx.x;
    /* Index into the need & alloc matrix */
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    s_avail[t_index] = avail[t_index];
    __syncthreads();
    do {
        out[index] = (s_avail[t_index] >= need[index]) ? 1 : 0;
        //out[index] = (avail[t_index] >= need[index]) ? 1 : 0;
        index += (NUM_OF_BLOCKS * r); 
    } while (index < bound);
}
void store_vector(int *array, char *line){
	char *tokens = strtok(line,",");
	int i = 0;
	while (tokens != NULL){
		array[i++] = atoi(tokens);
		tokens = strtok(NULL,",");
	}
}
int main (int argc, char *argv[]) {
    float eTime;
    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
	int p,r,num_processes,num_resources,size;
	FILE *file;
	char * line = NULL;
	size_t len = 0;
	ssize_t read;
	char *tokens;
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
    size = num_processes * num_resources * sizeof(int);
	int r_avail[num_resources];
	int p_sequence[num_processes];
	int p_seen[num_processes];
	int *r_alloc, *r_max, *r_need, *r_out;
	int *gpu_r_avail, *gpu_r_alloc, *gpu_r_need, *gpu_r_out;
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
    printf("INDEX %d\n", index);
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
    cudaEventRecord(start,0);
    /* Allocate memory on the GPU */
    cudaMalloc((void **)&gpu_r_avail, num_resources * sizeof(int));
    cudaMalloc((void **)&gpu_r_alloc, size);
    cudaMalloc((void **)&gpu_r_need, size);
    cudaMalloc((void **)&gpu_r_out, size);
    /* Copy alloc and need to GPU */
    cudaMemcpy(gpu_r_avail, r_avail, num_resources * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(gpu_r_alloc, r_alloc, size, cudaMemcpyHostToDevice);
    cudaMemcpy(gpu_r_need, r_need, size, cudaMemcpyHostToDevice);
    /* Launch kernel */
    r_check<<<NUM_OF_BLOCKS,THREADS_PER_BLOCK>>>(gpu_r_avail, gpu_r_alloc, gpu_r_need, gpu_r_out, num_processes, num_resources);
    printf("%s\n", cudaGetErrorString(cudaGetLastError()));
    /* Copy result to host */
    cudaMemcpy(r_out, gpu_r_out,size, cudaMemcpyDeviceToHost);
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&eTime, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    printf("%s\n", cudaGetErrorString(cudaGetLastError()));
    /* Free GPU memory */
    cudaFree(gpu_r_avail);
    cudaFree(gpu_r_alloc);
    cudaFree(gpu_r_need);
    cudaFree(gpu_r_out);

    /*for (r = 0; r < num_resources; r++){
        printf("%d ", r_avail[r]);
    }
    printf("\n\n");
	for (p = 0; p < num_processes; p++){
	    for (r = 0; r < num_resources; r++){
            printf("%d ", r_alloc[num_resources * p + r]);
        }
        printf("\n");
	}
    printf("\n\n");
	for (p = 0; p < num_processes; p++){
	    for (r = 0; r < num_resources; r++){
            printf("%d ", r_need[num_resources * p + r]);
        }
        printf("\n");
	}
    printf("\n");
	for (p = 0; p < num_processes; p++){
	    for (r = 0; r < num_resources; r++){
            printf("%d ", r_out[num_resources * p + r]);
        }
        printf("\n");
	}*/

    printf("GPU Time: %f seconds\n", eTime/1000.0);

    free(r_alloc);
    free(r_max);
    free(r_need);
	exit(EXIT_SUCCESS);
}
