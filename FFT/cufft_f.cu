#include <cufft.h>
 
// Note the trailing underscore and that scalar arguments are passed by reference for Fortran compatibility
extern "C" void launchcufft_(float *d_data, int *length)
{
    int n = *length;
    cufftHandle plan;
    cufftPlan1d(&plan, n, CUFFT_C2C, 1);
    cufftExecC2C(plan, (cufftComplex*)d_data, (cufftComplex*)d_data,CUFFT_FORWARD);
    cufftDestroy(plan);
}
