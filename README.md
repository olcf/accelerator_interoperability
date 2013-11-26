Accelerator Interoperability
============================

FFT:
The FFT C and Fortran samples show how to combine OpenACC data regions with GPU libraries such as CUFFT. Since files containing CUFFT function calls must be compiled with the nvcc compiler and OpenACC containing files must be compiled with cc/CC/ftn it is necessary to create wrapper functions as shown below. The acc host_data use_device directive will be used which causes the device allocated memory address of specified variables to be used in host code within the directives scope.

Hash:
The hash C and Fortran samples show how to leverage OpenACC, cuRand, and Thrust in a single application. This example will use cuRand to generate random data, OpenACC to hash the data, and finally Thrust to sort the data into canonical order. Although this example is provided to illustrate OpenACC interoperability only it was written with a simple nearest neighbor hash implementation given interleaved 3D positions(x1,y1,z1,x2,y2,z2…) in mind. 
