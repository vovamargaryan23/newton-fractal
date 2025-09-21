#include <iostream>
#include "fractal.h"

int main()
{
    int N = 3;
    float vec_a[N] = {1.2, 4.3, 5.52};
    float vec_b[N] = {6.8, 3.7, 5.52};

    float result[N];

    ispc::add_vectors(N, vec_a, vec_b, result);

    for (int i = 0; i < N; i++) {
        std::cout << result[i] << " ";
    }

    return 0;
} 