#include "SBA.h"

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
