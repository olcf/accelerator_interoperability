#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "openacc.h"

#ifndef M_PI
#define M_PI           3.14159265358979323846
#endif

// Forward declaration of wrapper function that will call CUFFT
extern void launchCUFFT(float *d_data, int n, void *stream);

int main(int argc, char *argv[])
{
    int n = 256;
    float *data = malloc(2*n*sizeof(float));
    int i;

    // Initialize interleaved input data on host
    float w = 7.0;
    float x;
    for(i=0; i<2*n; i+=2)  {
        x = (float)i/2.0/(n-1);
        data[i] = cos(2*M_PI*w*x);
        data[i+1] = 0.0;
    }

    // Copy data to device at start of region and back to host and end of region
    #pragma acc data copy(data[0:2*n])
    {
        // Inside this region the device data pointer will be used
        #pragma acc host_data use_device(data)
        {
           void *stream = acc_get_cuda_stream(acc_async_sync);
           launchCUFFT(data, n, stream);
        }
    }

    // Find the frequency
    int max_id = 0;
    for(i=0; i<n; i+=2) {
        if( data[i] > data[max_id] )
            max_id = i;
    }
    printf("frequency = %d\n", max_id/2);

    return 0;
}
