#include <stdio.h>

//#define N 50
//#define THREADS_PER_BLOCK 10
//#define RADIUS 3
//#define BLOCK_SIZE 20

#define N 1500
//#define THREADS_PER_BLOCK 10
#define RADIUS 3
#define BLOCK_SIZE 3

__global__ void stencil_ld(int *in, int *out) {
    __shared__ int temp[BLOCK_SIZE + 2 * RADIUS];
    int gindex = threadIdx.x + blockIdx.x * blockDim.x;
    int lindex = threadIdx.x + RADIUS;

    // Leer elementos de entrada en la memoria compartida
    temp[lindex] = in[gindex];
    if (threadIdx.x < RADIUS) {
        temp[lindex - RADIUS] = in[gindex - RADIUS];
        temp[lindex + BLOCK_SIZE] = in[gindex + BLOCK_SIZE];
    }

    __syncthreads();

    // Aplicamos el stencil:
    int result = 0;
    for (int offset = -RADIUS; offset <= RADIUS; offset++)
        result += temp[lindex + offset];

    // Almacena el resultado:
    out[gindex] = result;
}

void random_ints(int *V, int n){
    int i;
    for (i = 0; i < n; i++)
        V[i] = rand() % 5;
}

void print_vect(int *V, int n){
    int i;
    for (i = 0; i < n; i++)
		printf("%d\t", V[i]);
    printf("\n");
}

int main(void){
    int *a, *b;
    int *d_a, *d_b;
    int size = N * sizeof(int);

    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);

    a = (int *)malloc(size);
    b = (int *)malloc(size);
    random_ints(a, N);

    // Crear los eventos:
    cudaEvent_t start, stop;
    cudaEventCreate(&start); 
    cudaEventCreate(&stop);

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);

    // Registrar eventos alrededor del lanzamiento del kernel
    cudaEventRecord(start); // Donde 0 es la secuencia predeterminada
    stencil_ld<<<(N + BLOCK_SIZE-1)/BLOCK_SIZE, BLOCK_SIZE>>>(d_a, d_b);
    
    cudaEventRecord(stop);

    cudaMemcpy(b, d_b, size, cudaMemcpyDeviceToHost);

    cudaEventSynchronize(stop);
    
    // Para calcular el tiempo:
    float time = 0;
    cudaEventElapsedTime(&time, start, stop);

    print_vect(a, N);
    printf("\n");
    print_vect(b, N);
    printf("\n %fn milisegundos \n", time); // Imprimir el tiempo

    free(a);
    free(b);

    cudaFree(d_a);
    cudaFree(d_b);
    return 0;
}

// nvcc vect_stencil.cu -o v
// ./v