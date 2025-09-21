#include <iostream>
#include <fstream>
#include <vector>
#include <string.h>
#include <cmath>
#include "fractal.h"

constexpr int IMAGE_WIDTH = 1200;
constexpr int IMAGE_HEIGHT = 900;
constexpr int MAX_ITERATIONS = 256;
constexpr int DEFAULT_N = 3;
constexpr float TOLERANCE = 1e-5;
constexpr float TWO_PI = 6.28318530717958647692f;

constexpr int X_MIN = -2, X_MAX = 2, Y_MIN = -2, Y_MAX = 2;


static void save_to_PPM(int *buf, int width, int height, const char *fn) {
    std::ofstream ofs(fn, std::ios::binary);
    ofs << "P6\n" << width << " " << height << "\n255\n";
    for(int i = 0; i < width*height; i++) {
        unsigned char r = buf[i*3 + 0];
        unsigned char g = buf[i*3 + 1];
        unsigned char b = buf[i*3 + 2];
        ofs << r << g << b;
    }
    ofs.close();
}

void precompute_roots(int n, ispc::Complex roots[])
{
    for(int i = 0; i < n; i++)
    {
        ispc::Complex complex_num;

        float theta_k = TWO_PI * (float) i / (float) n;
        complex_num.real = (float) cos(theta_k);
        complex_num.imaginary = (float) sin(theta_k);
        roots[i] = complex_num;
    }
}

int main(int argc, char** argv)
{
    int n = DEFAULT_N;

    if(argc > 1) {
        n = atoi(argv[1]);
    }

    ispc::Complex roots[n];

    precompute_roots(n, roots);

    std::vector<int> image(IMAGE_WIDTH * IMAGE_HEIGHT * 3, 0);

    ispc::render_fractal(IMAGE_WIDTH, IMAGE_HEIGHT, n, X_MIN, X_MAX, Y_MIN, Y_MAX, TOLERANCE, MAX_ITERATIONS, roots, image.data());

    save_to_PPM(image.data(), IMAGE_WIDTH, IMAGE_HEIGHT, "fractal.ppm");

    return 0;
} 