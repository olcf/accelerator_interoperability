all: clean checkEnv setFlags interop_c interop_f

.PHONY: checkEnv setFlags clean

checkEnv:
ifdef CRAY_PRGENVCRAY
    ifndef CRAY_ACCEL_TARGET
        $(error craype-accel-nvidia35 not loaded)
    endif
endif
ifndef CRAY_CUDATOOLKIT_VERSION
    $(error cudatoolkit module not loaded)
endif

setFlags:
ifdef CRAY_PRGENVPGI
    CFLAGS = -acc
    FFLAGS = -acc
endif
ifdef CRAY_PRGENVCRAY
    CFLAGS = -hpragma=acc
    FFLAGS = -hacc
endif
LIBS = -lcufft

interop_c: fft.c cufft.cu
	mkdir -p bin
	nvcc -c cufft.cu
	cc $(CFLAGS) $(LIBS) -o bin/interop_c fft.c cufft.o
interop_f: fft.f90 cufft.cu
	mkdir -p bin
	nvcc -c cufft.cu
	ftn -c $(FFLAGS) fft.f90
	ftn $(FFLAGS) -o bin/interop_f fft.o cufft.o $(LIBS)

clean:
	rm -f *.o
	rm -f *.mod
	rm -rf bin
