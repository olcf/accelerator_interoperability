program fft
    USE ISO_C_BINDING ! Required by CapsMC to use host_data
    INTEGER, PARAMETER :: n = 256
    COMPLEX :: data(n)
    INTEGER :: i,max_id
 
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
        call launchcufft(data, n)
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
