ifdef HMPP_BIN_PATH
all: clean checkEnv setFlags interop_c
else
all: clean checkEnv setFlags interop_c interop_f
endif

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
ifndef THRUST_INCLUDE
    $(error thrust module not loaded)
endif

setFlags:
ifdef CRAY_PRGENVPGI
    CFLAGS = -acc -Minline -ta=tesla:cc35
    FFLAGS = -acc -Minline -ta=tesla:cc35
endif
ifdef CRAY_PRGENVCRAY
    CFLAGS = -hpragma=acc
    FFLAGS = -hacc
endif

LIBS = -lcurand
INC = -I$(THRUST_INCLUDE)

interop_c: sort.c sortGPU.cu
	mkdir -p bin
	nvcc -c $(INC) sortGPU.cu
	cc $(CFLAGS) $(LIBS) $(INC) sort.c sortGPU.o -o bin/interop_c
interop_f: sort.f90 sortGPU.cu
	mkdir -p bin
	nvcc -c $(INC) sortGPU.cu
	ftn $(FFLAGS) $(LIBS) sort.f90 sortGPU.o -o bin/interop_f

clean:
	rm -f *.o
	rm -f *.mod
	rm -rf bin
