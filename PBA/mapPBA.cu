#include<stdio.h>
#include<stdlib.h>
#include<malloc.h>
#include<string.h>
#include<time.h>

/*
 * Brandon Cercone
 * Parallel Banker's Algorithm
 */
#define THREADS_PER_BLOCK 1024
#define NUM_OF_BLOCKS 16
__global__ void m_r_check(int *avail, int *need, int *flag, int *map){
    int t_index = threadIdx.x;
    int b_index = map[blockIdx.x];
    //int index = threadIdx.x + blockIdx.x * blockDim.x;
    //atomicOr(&flag[blockIdx.x], avail[t_index] - need[index]);
    int index = threadIdx.x + b_index * blockDim.x;
    atomicOr(&flag[b_index], avail[t_index] - need[index]);
}
__global__ void add_r(int *avail, int *alloc, int p){
    int t_index = threadIdx.x;
    int index = threadIdx.x + blockIdx.x * blockDim.x + (p * blockDim.x);
    avail[t_index] += alloc[index];
}
__global__ void set_zero(int *out){
    out[threadIdx.x + blockIdx.x * blockDim.x] = 0;
}
__global__ void init_map(int *map){
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    map[index] = index;
}
__global__ void update_map(int *map, int p){
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (map[index] >= p){
        map[index]++;
    }
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
    clock_t t;
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
    //int r_out[num_processes] = {0};
    int *r_out;
	int p_sequence[num_processes];
	int p_seen[num_processes];
	int *r_alloc, *r_max, *r_need;
	int *gpu_r_avail, *gpu_r_alloc, *gpu_r_need, *gpu_r_out, *gpu_b_map;
    r_alloc = (int *)malloc(size);
    r_max = (int *)malloc(size);
    r_need = (int *)malloc(size);
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
    cudaEventRecord(start,0);
    t = clock();
    /* Allocate memory on the GPU */
    cudaMalloc((void **)&gpu_r_avail, num_resources * sizeof(int));
    cudaMalloc((void **)&gpu_r_alloc, size);
    cudaMalloc((void **)&gpu_r_need, size);
    cudaMalloc((void **)&gpu_r_out, num_processes * sizeof(int));
    cudaMalloc((void **)&gpu_b_map, num_processes * sizeof(int));
    /* Copy alloc and need to GPU */
    cudaMemcpy(gpu_r_avail, r_avail, num_resources * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(gpu_r_alloc, r_alloc, size, cudaMemcpyHostToDevice);
    cudaMemcpy(gpu_r_need, r_need, size, cudaMemcpyHostToDevice);
    /* Launch kernel */
    int flag,counter;
    cudaMallocHost((void **)&r_out, num_processes * sizeof(int));
    counter = 0;
    int blocks = num_processes / 100;
    int NUM_BLOCKS = num_processes;
    init_map<<<blocks,100>>>(gpu_b_map);
    while(counter < num_processes){
        //t = clock();
        set_zero<<<blocks,100>>>(gpu_r_out);
        //t = clock() - t;
        //printf("zero time: %f\n", ((double)t)/CLOCKS_PER_SEC);

        //t = clock();
        m_r_check<<<NUM_BLOCKS,THREADS_PER_BLOCK>>>(gpu_r_avail,gpu_r_need,gpu_r_out,gpu_b_map);
        //t = clock() - t;
        //printf("m_r check time: %f\n", ((double)t)/CLOCKS_PER_SEC);

        //t = clock();
        cudaMemcpy(r_out, gpu_r_out, num_processes * sizeof(int), cudaMemcpyDeviceToHost);
        //t = clock() - t;
        //printf("xfer time: %f\n", ((double)t)/CLOCKS_PER_SEC);

        flag = 0;
        for (p = 0; p < num_processes; p++){
            //printf("%d\n", r_out[p]);
            if (r_out[p] >= 0 && !p_seen[p]){
                //printf("%d ", p);
                add_r<<<1,THREADS_PER_BLOCK>>>(gpu_r_avail,gpu_r_alloc,p);
                update_map<<<blocks,100>>>(gpu_b_map,p);
                NUM_BLOCKS--;
                p_seen[p] = 1;
                p_sequence[counter++] = p;
                flag = 1;
                //break;
            }
        }
                //printf("\n");
        if (!flag){
                printf("DENIED");
                break;
        }
    }
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&eTime, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    //printf("%s\n", cudaGetErrorString(cudaGetLastError()));
    /* Free GPU memory */
    cudaFree(gpu_r_avail);
    cudaFree(gpu_r_alloc);
    cudaFree(gpu_r_need);
    cudaFree(gpu_r_out);
    cudaFreeHost(r_out);
    t = clock() - t;

    if (argc == 3 && strcmp(argv[2],"-d") == 0){
        for (r = 0; r < num_processes; r++){
            printf("%d ", p_sequence[r]);
        }
        printf("\n\n");
    }

    printf("%d %f\n", num_processes, eTime/1000.0);
    //printf("%d %f\n", num_processes, ((double)t)/CLOCKS_PER_SEC);

    free(r_alloc);
    free(r_max);
    free(r_need);
	exit(EXIT_SUCCESS);
}
