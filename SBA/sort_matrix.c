#include "SBA.h"

void sort_matrix(int **need, int row, int col){
	int *col_vect[row];
	int i;
    SORT_COL=0;
	for (i = 0; i < row; i++)
		col_vect[i] = need[i];
	do {
		DUP_FLAG=0;
		qsort(col_vect, row, sizeof(int*), compare_int);
		SORT_COL++;
	} while (DUP_FLAG && SORT_COL < col);
	for (i = 0; i < row; i++)
		need[i] = col_vect[i];
}
