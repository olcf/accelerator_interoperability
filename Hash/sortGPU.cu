#include <stdio.h>
#include <curand.h>
#include <thrust/device_ptr.h>
#include <thrust/sort.h>
#include <thrust/binary_search.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/system_error.h>
 
// Fill d_buffer with num random numbers
extern "C" void fill_rand(float *d_buffer, int num)
{
  curandGenerator_t gen;
  int status;
 
  // Create generator
  status = curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
 
  // Set seed
  status |= curandSetPseudoRandomGeneratorSeed(gen, 1234ULL);
 
  // Generate num random numbers
  status |= curandGenerateUniform(gen, d_buffer, num);
 
  // Cleanup generator
  status |= curandDestroyGenerator(gen);
 
  if (status != CURAND_STATUS_SUCCESS) {
      printf ("curand failure!\n");
      exit (EXIT_FAILURE);
  }
}
 
// Sort key value pairs
extern "C" void sort(int *d_keys, int *d_values, int num)
{
    try {
        // Create THRUST usable device pointers
        thrust::device_ptr<int> keys(d_keys);
        thrust::device_ptr<int> values(d_values);
 
        // Sort keys AND values array by key
        thrust::sort_by_key(keys, keys + num, values);
    }
    catch(thrust::system_error &e) {
        std::cerr << "Error sorting with Thrust: " << e.what() << std::endl;
        exit (EXIT_FAILURE);
    }
}