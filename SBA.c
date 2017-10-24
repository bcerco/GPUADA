#include<stdio.h>
#include<stdlib.h>
#include<malloc.h>
#include<string.h>

/*
 * Brandon Cercone
 * Serial Banker's Algorithm
 */
void store_vector(int *array, char *line);
void print_vector(int *array, int size);
void print_matrix(int **array, int row, int col);
int resource_check(int **alloc, int *req, int *avail, int *seq, int *seen, int size, int pid);
int bankers_alg(int **alloc, int **need, int *avail, int *seq, int *seen, int row, int col);
int main (int argc, char *argv[]) {
        int p,r,process_id,num_processes,num_resources;
        FILE *file;
        char * line = NULL;
        size_t len = 0;
        ssize_t read;
        char *tokens;
        int debug = 0;
        printf("Args: %d\n",argc);
        if (argc != 5){
                printf("ERROR: args=%d",argc);
                exit(EXIT_FAILURE);
        }
        if (argc == 6 && strcmp(argv[6],"-d") == 0) debug = 1;
        /* Arg 1: Requesting process number */
        process_id = atoi(argv[1]);
        printf("PID: %d\n",process_id);
        /* Arg 2: Number of processes */
        num_processes = atoi(argv[2]);
        printf("P: %d\n",num_processes);
        /* Arg 3: Number of resources */
        num_resources = atoi(argv[3]);
        printf("R: %d\n",num_resources);
        /* Arg 4: Filename for matrix and resource vector */
        printf("File: %s\n",argv[4]);
        file=fopen(argv[4], "r");
        if (file == NULL)
                exit(EXIT_FAILURE);
        /* Allocate memory for resource vectors and matrix */
        int r_avail[num_resources];
        int r_request[num_resources];
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
        /* First line in the file is the request vector */
        read = getline(&line, &len, file);
        store_vector(r_request,line);
        printf("r_request: ");
        print_vector(r_request, num_resources);
        /* Second line in file is the resources available vector */
        read = getline(&line, &len, file);
        store_vector(r_avail,line);
        printf("r_avail: ");
        print_vector(r_avail, num_resources);
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
                        r_need[p][r] = r_max[p][r] - r_alloc[p][r++];
                        tokens = strtok(NULL,",");
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
        if (!resource_check(r_alloc,r_request,r_avail,p_sequence,p_seen,num_resources,process_id))
                printf("DENIED\n");
        else{
                if (bankers_alg(r_alloc,r_need,r_avail,p_sequence,p_seen,num_processes,num_resources))
                        printf("GRANTED\n");
                else
                        printf("DENIED\n");
        }

        printf("p_sequence: ");
        print_vector(p_sequence, num_processes);
        printf("p_seen: ");
        print_vector(p_seen, num_processes);
        printf("r_avail: ");
        print_vector(r_avail, num_resources);
        /* Free memory */
        for (p = 0; p < num_processes; p++){
                free(r_alloc[p]);
                free(r_max[p]);
                free(r_need[p]);
        }
        exit(EXIT_SUCCESS);
}
int bankers_alg(int **alloc, int **need, int *avail, int *seq, int *seen, int row, int col){
        int p,r,flag,counter;
        counter = 1;
        while (counter < row) {
                flag = 0;
                for (p = 0; p < row; p++){
                        if (seen[p]) continue;
                        for (r = 0; r < col; r++){
                                if (avail[r] < need[p][r]){
                                        flag = 0;
                                        break;
                                }
                                else
                                        flag = 1;
                        }
                        if (flag) break;
                }
                if (!flag)
                        return 0;
                else {
                        for (r = 0; r < col; r++)
                                avail[r] += alloc[p][r];
                        seen[p] = 1;
                        seq[counter++] = p;
                }
        }
        return 1;
}
/* Split string input from file and store as vector */
void store_vector(int *array, char *line){
        char *tokens = strtok(line,",");
        int i = 0;
        while (tokens != NULL){
                array[i++] = atoi(tokens);
                tokens = strtok(NULL,",");
        }
}
/* Print space separated vector */
void print_vector(int *array, int size){
        int i = 0;
        for (i = 0; i < size; i++)
                printf("%d ",array[i]);
        printf("\n");
}
/* Print space separated matrix */
void print_matrix(int **array, int row, int col){
        int p,r;
        for (p = 0; p < row; p++){
                for (r = 0; r < col; r++)
                        printf("%2d ", array[p][r]);
                printf("\n");
        }
}
int resource_check(int **alloc, int *req, int *avail, int *seq, int *seen, int size, int pid){
        int i;
        for (i = 0; i < size; i++){
                if (req[i] > avail[i])
                        return 0;
                else
                        avail[i] += alloc[pid][i];
        }
        seen[pid] = 1;
        seq[0] = pid;
        return 1;
}
