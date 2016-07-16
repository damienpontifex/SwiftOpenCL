__kernel
void vec_add(__global int4 *A, __global int4 *B, __global int4 *C) {
   int idx = get_global_id(0);

   C[idx] = A[idx] + B[idx];
}