#ifndef __JSON_XML_H__
#define __JSON_XML_H__

typedef struct n_collect{
    char* n;
    struct n_collect* previous;
} n_collect_t;

typedef struct n_const_collect{
    char const* n;
    struct n_const_collect* previous;
} n_const_collect_t;

void add_n_collect(n_collect_t** top, char* n);
void free_n_collect(n_collect_t * nc);
void free_n_collect_list(n_collect_t* top);

void add_n_const_collect(n_const_collect_t** top, char const* n);
void free_n_const_collect(n_const_collect_t * nc);
void free_n_const_collect_list(n_const_collect_t* top);
void free_const_collect_list(n_const_collect_t* top);
void free_const_collect(n_const_collect_t * nc);
#endif
