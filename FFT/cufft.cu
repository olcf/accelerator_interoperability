#include <cufft.h>

// Declared extern "C" to disable C++ name mangling
extern "C" void launchCUFFT(float *d_data, int n, void *stream)
{
    cufftHandle plan;
    cufftPlan1d(&plan, n, CUFFT_C2C, 1);
    cufftSetStream(plan, (cudaStream_t)stream);
    cufftExecC2C(plan, (cufftComplex*)d_data, (cufftComplex*)d_data,CUFFT_FORWARD);
    cufftDestroy(plan);
}
