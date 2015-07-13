#include <cufft.h>

// Note the trailing underscore and that scalar arguments are passed by reference for Fortran compatibility
extern "C" void launchcufft_(float *d_data, int *length, void *stream)
{
    int n = *length;
    cufftHandle plan;
    cufftPlan1d(&plan, n, CUFFT_C2C, 1);
    cufftSetStream(plan, stream);
    cufftExecC2C(plan, (cufftComplex*)d_data, (cufftComplex*)d_data,CUFFT_FORWARD);
    cufftDestroy(plan);
}
