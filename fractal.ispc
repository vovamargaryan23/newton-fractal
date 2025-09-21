export void add_vectors(
    uniform int N,
    uniform float a[],
    uniform float b[],
    uniform float result[]
) {
    foreach(i = 0 ... N) {
        result[i] = a[i] + b[i];
    }
}