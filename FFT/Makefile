ifdef HMPP_BIN_PATH 
all: clean checkEnv setFlags interop_c interop_f
else
all: clean checkEnv setFlags interop_c interop_f interop_iso_f
endif

.PHONY: checkEnv setFlags clean

checkEnv:
ifdef CRAY_PRGENVCRAY
    ifndef HMPP_BIN_PATH
        ifndef CRAY_ACCEL_TARGET
            $(error craype-accel-nvidia35 not loaded)
        endif
    else
        ifdef CRAY_ACCEL_TARGET
            $(error craype-accel-nvidia35 not compatible with CapsMC. Use cudatoolkit module)
        endif
    endif
endif
ifndef CRAY_CUDATOOLKIT_VERSION
    $(error cudatoolkit module not loaded)
endif

setFlags:
ifdef HMPP_BIN_PATH
    ifdef CRAY_PRGENVGNU
        CFLAGS = -std=c99
    endif
    ifdef CRAY_PRGENVINTEL
        CFLAGS = -restrict
    endif
else
    ifdef CRAY_PRGENVPGI
        CFLAGS = -acc
        FFLAGS = -acc
    endif
    ifdef CRAY_PRGENVCRAY
        CFLAGS = -hpragma=acc
        FFLAGS = -hacc
    endif
endif
LIBS = -lcufft

interop_c: fft.c cufft.cu
	mkdir -p bin
	nvcc -c cufft.cu
	cc $(CFLAGS) $(LIBS) -o bin/interop_c fft.c cufft.o
interop_f: fft.f90 cufft_f.cu
	mkdir -p bin
	nvcc -c cufft_f.cu
	ftn -c $(FFLAGS) fft.f90
	ftn $(FFLAGS) -o bin/interop_f fft.o cufft_f.o $(LIBS)
interop_iso_f: fft_iso.f90 cufft.cu
	mkdir -p bin
	nvcc -c cufft.cu
	ftn -c $(FFLAGS) fft_iso.f90
	ftn $(FFLAGS) -o bin/interop_iso_f fft.o cufft_f.o $(LIBS)

clean:
	rm -f *.o
	rm -f *.mod
	rm -rf bin
