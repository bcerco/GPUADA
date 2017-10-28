#include "SBA.h"

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
