#include <cufft.h>
 
// Declared extern "C" to disable C++ name mangling
extern "C" void launchCUFFT(float *d_data, int n)
{
    cufftHandle plan;
    cufftPlan1d(&plan, n, CUFFT_C2C, 1);
    cufftExecC2C(plan, (cufftComplex*)d_data, (cufftComplex*)d_data,CUFFT_FORWARD);
    cufftDestroy(plan);
}
