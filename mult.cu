#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <iostream>
using namespace std;


#define N (3*3)
#define THREADS_PER_BLOCK 3

void random_ints(int* a, int M)
{
   int i;
   for (i = 0; i < M; ++i)
        a[i] = rand()%5;
}

__global__ void multi(int *a, int *b, int *c,int n) {
    int suma = 0;
    int row = blockIdx.y * blockDim.y + threadIdx.y ; 
    int col = blockIdx.x * blockDim.x + threadIdx.x ;

    if (row <n && col<n){
        for(int i=0;i<N;++i){
        suma+= a[row*n+i] * b[i*n+col];
        }
    }
    c[row*n+col] = suma;
}

void imprimir(int *a){
	for(int i=0;i<N;i++)
		printf ("%d ",a[i]);
		printf("\n");
	printf("\n");
}

int main(void){
	int *a, *b, *c; // host copies of a, b, c
	int *d_a, *d_b, *d_c; //device copies of a,b,c
	int size = N*sizeof(int);

	cudaMalloc((void **)&d_a, size);
	cudaMalloc((void **)&d_b, size);
	cudaMalloc((void **)&d_c, size);

	a = (int *)malloc(size); random_ints(a, N);
	b = (int *)malloc(size); random_ints(b, N);
	c = (int *)malloc(size);

	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    // add<<<1,N>>>(d_a, d_b, d_c);
	// cladd<<<N/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(d_a, d_b, d_c);
	multi<<<(N + THREADS_PER_BLOCK -1)/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(d_a, d_b, d_c,N);
	
	
	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
	imprimir(a);
	imprimir(b);
	imprimir(c);

	free(a); free(b); free(c);
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
	return 0;
}
