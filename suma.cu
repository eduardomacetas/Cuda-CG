#include <stdio.h>
#include <stdlib.h>
#define N 10

#define g 10/2
void random_ints(int* a, int M)
{
   int i;
   for (i = 0; i < M; ++i)
        a[i] = rand()/10000000;
}

__global__ void add(int *a, int *b, int *c) {
	c[threadIdx.x]=	a[threadIdx.x]+ b[threadIdx.x];
	
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

	add<<<1,N>>>(d_a, d_b, d_c);
	
	
	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
	imprimir(a);
	imprimir(b);
	imprimir(c);

	free(a); free(b); free(c);
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
	return 0;
}

// nvcc suma.cu -o v
// ./v

