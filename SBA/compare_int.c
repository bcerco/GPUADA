#include "SBA.h"

int compare_int( const void *a, const void *b){
	if ( SORT_COL && 
            ((addr_pair *)a)->n_addr[SORT_COL-1] != ((addr_pair *)b)->n_addr[SORT_COL-1] ) return 0;
	if ( ((addr_pair *)a)->n_addr[SORT_COL] == ((addr_pair *)b)->n_addr[SORT_COL] ) { DUP_FLAG=1; return 0;}
	return ((addr_pair *)a)->n_addr[SORT_COL] < ((addr_pair *)b)->n_addr[SORT_COL] ? -1 : 1;
}
//int compare_int( const void *a, const void *b){
//	if ( SORT_COL && (*((int **)a))[SORT_COL-1] != (*((int **)b))[SORT_COL-1] ) return 0;
//	if ( (*((int **)a))[SORT_COL] == (*((int **)b))[SORT_COL] ) { DUP_FLAG=1; return 0;}
//	return (*((int **)a))[SORT_COL] < (*((int **)b))[SORT_COL] ? -1 : 1;
//}
