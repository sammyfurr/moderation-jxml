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

/* Add a frame onto the garbarge collection stack for a string
   allocated at some point (always with strdup in the case of our
   program). */
void add_n_collect(n_collect_t** top, char* n);

/* Free an individual name frame *including* the name.  */
void free_n_collect(n_collect_t * nc);

/* Free the whole garbarge collection stack *including* the names.  */
void free_n_collect_list(n_collect_t* top);

/* All do the same as their non const counterparts, except work with
   constant strings. */
void add_n_const_collect(n_const_collect_t** top, char const* n);
void free_n_const_collect(n_const_collect_t * nc);
void free_n_const_collect_list(n_const_collect_t* top);

/* Free an individual name frame *not including* the name.  We want to
   do this when we are freeing the garbage collection structure on a
   successfull return from our lexer. We don't want to free the names,
   as they will be used and freed later in our parseer. */
void free_const_collect_list(n_const_collect_t* top);

/* Free the whole garbarge collection stack *not including* the names.
 */
void free_const_collect(n_const_collect_t * nc);

#endif
