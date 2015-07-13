program fft
    USE ISO_C_BINDING
    USE openacc
    IMPLICIT NONE

    INTEGER, PARAMETER :: n = 256
    COMPLEX :: data(n)
    INTEGER :: i,max_id
    INTEGER(kind=8) :: stream

    ! Initialize interleaved input data on host
    REAL :: w = 7.0
    REAL :: x
    REAL, PARAMETER :: PI = 3.1415927
    do i=1,n
        x = (i-1.0)/(n-1.0);
        data(i) = CMPLX(COS(2.0*PI*w*x),0.0)
    enddo

    ! Copy data to device at start of region and back to host and end of region
    !$acc data copy(data)

        ! Inside this region the device data pointer will be used
        !$acc host_data use_device(data)
        stream = acc_get_cuda_stream(acc_async_sync)
        call launchcufft(data, n, stream)
        !$acc end host_data

    !$acc end data

    ! Find the frequency
    max_id = 1
    do i=1,n/2
        if (REAL(data(i)) .gt. REAL(data(max_id))) then
            max_id = i-1
        endif
    enddo
    print *, "frequency:", max_id

end program fft
