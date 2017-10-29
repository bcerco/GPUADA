#include<stdio.h>
#include<stdlib.h>
#include<malloc.h>
#include<string.h>
#include<stdint.h>
#include<inttypes.h>

#ifndef SBA_H_
#define SBA_H_

int SORT_COL;
int DUP_FLAG;

typedef struct {
    int *n_addr;
    int *a_addr;
} addr_pair;

void store_vector(int *array, char *line);
void print_vector(int *array, int size);
void print_matrix(int **array, int row, int col);
int resource_check(int **alloc, int *req, int *avail, int *seq, int *seen, int size, int pid);
int bankers_alg(int **alloc, int **need, int *avail, int *seq, int *seen, int row, int col);
//void sort_matrix(int **need, int row, int col);
void sort_matrix(int **need, int **alloc, int row, int col);
int compare_int( const void *a, const void *b);
uint64_t rdtsc();

#endif
