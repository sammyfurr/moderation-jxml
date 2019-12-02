#include <stdlib.h>
#include <stdio.h>
#include "json_xml.h"

void add_n_collect(n_collect_t** top, char *n){
    n_collect_t* nc;
    if((nc = malloc(sizeof(n_collect_t))) == NULL){
	perror("Error parsing list");
	free_n_collect_list(*top);
	exit(EXIT_FAILURE);
    }
    nc->n = n;
    nc->previous = *top;
    *top = nc;
}

void free_n_collect(n_collect_t * nc){
    free((void *)nc->n);
    free((void *)nc);
}

void free_n_collect_list(n_collect_t* top){
    n_collect_t* nc;
    while(top != NULL){
	nc = top->previous;
	free_n_collect(top);
	top = nc;
    }
}

void add_n_const_collect(n_const_collect_t** top, char const* n){
    n_const_collect_t* nc;
    if((nc = malloc(sizeof(n_collect_t))) == NULL){
	perror("Error parsing list");
	free_n_const_collect_list(*top);
	exit(EXIT_FAILURE);
    }
    nc->n = n;
    nc->previous = *top;
    *top = nc;
}

void free_n_const_collect(n_const_collect_t * nc){
    free((void *)nc->n);
    free((void *)nc);
}

void free_n_const_collect_list(n_const_collect_t* top){
    n_const_collect_t* nc;
    while(top != NULL){
	nc = top->previous;
	free_n_const_collect(top);
	top = nc;
    }
}

void free_const_collect(n_const_collect_t * nc){
    free((void *)nc);
}

void free_const_collect_list(n_const_collect_t* top){
    n_const_collect_t* nc;
    while(top != NULL){
	nc = top->previous;
	free_const_collect(top);
	top = nc;
    }
}
