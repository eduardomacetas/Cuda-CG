#include <iostream>
#include <stdio.h>
#include <stdlib.h> 
#include <time.h> 
#include <cstdio>
#include <ctime>


#define N 1500
#define radio 3

using namespace std;

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

void stencil(int *V_entrada){
    int V_salida[N];    
    for(int i=0;i<N;i++){
    int suma=0;
        for(int j=-radio;j<=radio;j++){
            suma += V_entrada[i+j];
        }
    
    V_salida[i] = suma;
    cout<<V_salida[i]<<" ";
    }
}

int main()
{
    int V[N];
    random_ints(V,N);
    print_vect(V,N);
    // tiempo
    clock_t star;
    double long tiempo;
    star = clock();

    stencil(V);

    tiempo = (clock() - star) / (double long) (CLOCKS_PER_SEC/1000);
    
    cout<<endl;
    cout<<"TIEMPO:  "<<tiempo<<endl; 
    // tiempo

    //stencil(V);
}

//g++ serial.cpp -o a
//./a