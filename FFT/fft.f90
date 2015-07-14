module cufft
  INTERFACE
    subroutine launchcufft(data, n, stream) BIND (C, NAME='launchCUFFT')
      USE ISO_C_BINDING
      implicit none
      type (C_PTR), value :: data
      integer (C_INT), value :: n
      type (C_PTR), value :: stream
    end subroutine
  END INTERFACE
end module cufft

program fft
    USE ISO_C_BINDING
    USE cufft
    USE openacc
    IMPLICIT NONE

    INTEGER, PARAMETER :: n = 256
    COMPLEX (C_FLOAT_COMPLEX) :: data(n)
    INTEGER (C_INT):: i
    INTEGER :: max_id,istat
    type (C_PTR) :: stream

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
        call launchcufft(C_LOC(data), n, stream)
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
