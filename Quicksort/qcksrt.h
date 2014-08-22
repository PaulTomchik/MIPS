# ifndef QCKSRT_H
# define QCKSRT_H 1


void qcksrt (void* base, size_t num, size_t size,
				  	int (*compar)(const void*,const void*));

# endif
