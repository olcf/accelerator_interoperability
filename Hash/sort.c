#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "openacc.h"

// Forward declaration of nvcc compiled functions
void fill_rand(float *d_buffer, int num, void *stream);
inline int hash_val(float x, float y, float z);
void sort(int *d_key, int *d_values, int num, void *stream);

int main(int argc, char* argv[])
{
    int i,index;
    float x,y,z;
    int dim = 3;
    int num = 1000000;
    int length = dim*num;
    float *restrict positions = (float*)malloc(length*sizeof(float));
    int *restrict keys   = (int*)malloc(num*sizeof(int));
    int *restrict values = (int*)malloc(num*sizeof(int));

    void *stream = acc_get_cuda_stream(acc_async_sync);

    // OpenACC will create positions, keys, and values arrays on the device
    #pragma acc data create(positions[0:length], keys[0:num], values[0:num])
    {
        // NVIDIA cuRandom will create our initial random data
        #pragma acc host_data use_device(positions)
        {
             fill_rand(positions, length, stream);
        }

        // OpenACC will calculate the hash value for each particle
        #pragma acc parallel loop
        for(i=0; i<num; i++) {
            index = i*3;
            x = positions[index];
            y = positions[index+1];
            z = positions[index+2];

            // Key is hash value and value is 'particle id'
            keys[i] = hash_val(x,y,z);
            values[i] = i;
        }

        // Thrust will be used to sort our key value pairs
        #pragma acc host_data use_device(keys, values)
        {
            sort(keys, values, num, stream);
        }
    }

    return 0;
}

// Uniform grid hash
inline int hash_val(float x, float y, float z)
{
    double spacing = 0.01;

    // Calculate grid coordinates
    int grid_x,grid_y,grid_z;
    grid_x = abs(floor(x/spacing));
    grid_y = abs(floor(y/spacing));
    grid_z = abs(floor(z/spacing));

    int num_x = 1.0/spacing;
    int num_y = 1.0/spacing;
    int num_z = 1.0/spacing;

    int grid_position = (num_x * num_y * grid_z) + (grid_y * num_x + grid_x);
    return grid_position;
}
