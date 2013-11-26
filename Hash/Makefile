ifdef HMPP_BIN_PATH 
all: clean checkEnv setFlags interop_c
else
all: clean checkEnv setFlags interop_c interop_f
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
        CFLAGS = -acc -Minline
        FFLAGS = -acc -Minline
    endif
    ifdef CRAY_PRGENVCRAY
        CFLAGS = -hpragma=acc
        FFLAGS = -hacc
    endif
endif
LIBS = -lcurand

interop_c: sort.c sortGPU.cu
	mkdir -p bin
	nvcc -c sortGPU.cu
	cc $(CFLAGS) $(LIBS) -o bin/sort_c sort.c sortGPU.o
interop_f: sort.f90 sortGPU.cu
	mkdir -p bin
	nvcc -c sortGPU.cu
	ftn $(FFLAGS) $(LIBS) sort.f90 sortGPU.o -o bin/interop_f

clean:
	rm -f *.o
	rm -f *.mod
	rm -rf bin
