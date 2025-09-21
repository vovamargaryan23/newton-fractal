export struct Complex {
    float real;
    float imaginary;
};

inline void complex_mul(Complex &a, Complex &b)
{
    float tmp_a_real = a.real;
    float tmp_a_imaginary = a.imaginary;
    
    a.real = tmp_a_real * b.real - tmp_a_imaginary * b.imaginary;
    a.imaginary = tmp_a_real * b.imaginary + b.real * tmp_a_imaginary;
}

inline void complex_sub(Complex &a, Complex &b)
{
    a.real = a.real - b.real;
    a.imaginary = a.imaginary - b.imaginary;
}

inline void complex_div(Complex &a, Complex &b)
{
    float tmp_a_real = a.real;
    float tmp_a_imaginary = a.imaginary;

    float denom = (b.real * b.real + b.imaginary * b.imaginary);

    a.real = (tmp_a_real * b.real + tmp_a_imaginary * b.imaginary) / denom;
    a.imaginary = (tmp_a_imaginary * b.real - tmp_a_real * b.imaginary) / denom;
}

export void render_fractal(uniform int width,
                           uniform int height,
                           uniform int n,
                           uniform float x_min, uniform float x_max,
                           uniform float y_min, uniform float y_max,
                           uniform float tolerance,
                           uniform int max_iterations,
                           uniform Complex roots[],
                           uniform int output[])
{
    uniform float dx = (x_max - x_min)/width;
    uniform float dy = (y_max - y_min)/height;
    uniform float width_ratio = (1.0f / width);


    foreach(index = 0 ... width * height)
    {
        // x and y are calculated this way for the sake of efficiency
        float fy = (float)index * width_ratio;
        int y = (int)fy;
        int x = index - y*width;

        Complex z;

        z.real = x_min + x * dx;
        z.imaginary = y_min + y * dy;

        int iterations = 0;

        for(int i = 0; i < max_iterations; i++)
        {
            Complex z_power = z;
            for(int j = 1; j < (n - 1); j++)
            {
                complex_mul(z_power, z);
            }

            Complex f = z_power;

            complex_mul(f, z);
            f.real -= 1.0f;

            if(f.real * f.real + f.imaginary * f.imaginary < tolerance * tolerance)
            {
                iterations = i;
                break;
            }

            Complex df = {n * z_power.real, n * z_power.imaginary};

            complex_div(f, df);
            complex_sub(z, f);
        }
    }
}
