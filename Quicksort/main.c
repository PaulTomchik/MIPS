# include <stdio.h>
# include <string.h>
# include "qcksrt.h"

struct empRecord {
	char *name;
	int id;
};

void testIntArray(void);
void testStructArray(void);

void printIntArr(int arr[], int len);
void printEmpRecs(struct empRecord arr[], int len);

int intcmp(const void*, const void*);
int empRecNameComp(const void*, const void*);
int empRecIdComp(const void*, const void*);

int main(void) {
	testIntArray();
	testStructArray();
	return 0;
}

void testIntArray(void) {
	int arr[] = { 2, -1, 4, 0, 3 };

	printf("\nTesting integer array.\n");

	printf("Before sort: ");
	printIntArr(arr, 5);

	qcksrt(arr, 5, sizeof(int), intcmp);
	printf("After sort : ");
	printIntArr(arr, 5);
}

void testStructArray(void) {
	char nom0[] = "Dennis"; 
	char nom1[] = "Steve"; 
	char nom2[] = "Ken"; 
	
	struct empRecord empRecs[3];


	printf("\nTesting struct array.\n");

	empRecs[0].name = nom0;
	empRecs[0].id = 1;
	empRecs[1].name = nom1;
	empRecs[1].id = 2;
	empRecs[2].name = nom2;
	empRecs[2].id = 0;

	printf("Before sort: \n");
	printEmpRecs(empRecs, 3);

	qcksrt(empRecs, 3, sizeof(struct empRecord), empRecNameComp);

	printf("After name sort: \n");
	printEmpRecs(empRecs, 3);

	qcksrt(empRecs, 3, sizeof(struct empRecord), empRecIdComp);
	printf("After id sort: \n");
	printEmpRecs(empRecs, 3);

}

void printIntArr(int arr[], int len) {
	int i;

	printf("{");
	for(i=0; i<len; ++i) {
		printf(" %d", arr[i]);
	}
	printf(" }\n");
}

void printEmpRecs(struct empRecord empRec[], int len) {
	int i;

	printf("{");
	for(i=0; i<len; ++i) {
		printf("%s{", i ? ",\n  " : "\n  ");
		printf("\n    id: %d,", empRec[i].id); 
		printf("\n    name: %s", empRec[i].name); 
		printf("\n  }");
	}
	printf("\n}\n");
}

int intcmp(const void *aPtr, const void *bPtr) {
	return *((int*)aPtr) - *((int*)bPtr);
}

int empRecNameComp(const void *aPtr, const void *bPtr) {
	struct empRecord *e1Ptr, *e2Ptr;
	e1Ptr = (struct empRecord*) aPtr;
	e2Ptr = (struct empRecord*) bPtr;

	return strcmp(e1Ptr->name, e2Ptr->name);
}

int empRecIdComp(const void *aPtr, const void *bPtr) {
	struct empRecord *e1Ptr, *e2Ptr;
	e1Ptr = (struct empRecord*) aPtr;
	e2Ptr = (struct empRecord*) bPtr;

	return e1Ptr->id - e2Ptr->id;
}
