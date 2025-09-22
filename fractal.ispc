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

inline void complex_sub(Complex &a, Complex b)
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

inline int to_byte(float x)
{
    float res = x * 255.0f + 0.5f;
    if(res > 255) return 255;
    if(res < 0) return 0;

    return (int) res;
}

inline void hsl_to_rgb(float h, float s, float l, int &r, int &g, int &b)
{
    s = (s < 0.0f) ? 0.0f : (s > 1.0f) ? 1.0f : s;
    l = (l < 0.0f) ? 0.0f : (l > 1.0f) ? 1.0f : l;

    if (s == 0.0f) {
        int v = to_byte(l);
        r = g = b = v;
        return;
    }

    float c = (1.0f - abs(2.0f*l - 1.0f)) * s;
    float hh = h * 6.0f;
    int i = (int)floor(hh);
    float f = hh - i;
    float x = c * (1.0f - abs(f * 2.0f - 1.0f));
    float m = l - 0.5f * c;

    float rf=0.0f, gf=0.0f, bf=0.0f;
    switch(i)
    {
        case 0: rf=c; gf=x; bf=0; break;
        case 1: rf=x; gf=c; bf=0; break;
        case 2: rf=0; gf=c; bf=x; break;
        case 3: rf=0; gf=x; bf=c; break;
        case 4: rf=x; gf=0; bf=c; break;
        default: rf=c; gf=0; bf=x; break;
    }

    r = to_byte(rf + m);
    g = to_byte(gf + m);
    b = to_byte(bf + m);
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

        int closest_i_to_root = 0;
        float smallest_dist = 1e30;
        for(int i = 0; i < n; i++)
        {
            Complex temp_z = z;
            complex_sub(temp_z, roots[i]);

            float dist = temp_z.real * temp_z.real + temp_z.imaginary * temp_z.imaginary;
            if(dist < smallest_dist) {
                smallest_dist = dist;
                closest_i_to_root = i;
            }
        }


        float hue = (float)closest_i_to_root / (float)n;
        float brightness = (float)iterations / (float)max_iterations;
        brightness = pow(brightness, 0.27f);
        if (brightness < 0.0f) brightness = 0.0f;
        if (brightness > 1.0f) brightness = 1.0f;

        float saturation = 1.0f;

        int r = 0, g = 0, b = 0;
        hsl_to_rgb(hue, saturation, brightness, r, g, b);
        output[index * 3] = r;
        output[index * 3 + 1] = g;
        output[index * 3 + 2] = b;
    }
}
