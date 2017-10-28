#include "SBA.h"

void print_matrix(int **array, int row, int col){
	int p,r;
	for (p = 0; p < row; p++){
		for (r = 0; r < col; r++)
			printf("%2d ", array[p][r]);
		printf("\n");
	}
}
