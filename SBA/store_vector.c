#include "SBA.h"

void store_vector(int *array, char *line){
	char *tokens = strtok(line,",");
	int i = 0;
	while (tokens != NULL){
		array[i++] = atoi(tokens);
		tokens = strtok(NULL,",");
	}
}
