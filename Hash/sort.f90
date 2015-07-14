! Module containing nvcc compiled function declarations and hash function
module sortgpu
  INTERFACE
    subroutine fill_rand(positions, length, stream) BIND(C,NAME='fill_rand')
      USE ISO_C_BINDING
      implicit none
      type (C_PTR), value :: positions
      integer (C_INT), value :: length
      type (C_PTR), value :: stream
    end subroutine fill_rand
 
    subroutine sort(keys, values, num, stream) BIND(C,NAME='sort')
      USE ISO_C_BINDING
      implicit none
      type (C_PTR), value :: keys
      type (C_PTR), value :: values
      integer (C_INT), value :: num
      type (C_PTR), value :: stream
    end subroutine sort
  END INTERFACE
 
  contains
    integer function hash_val(x,y,z)
      real :: x,y,z,spacing
      integer :: grid_x, grid_y, grid_z
      integer :: num_x, num_y, num_z
 
      spacing =  0.01;
 
      grid_x = abs(floor(x/spacing))
      grid_y = abs(floor(y/spacing))
      grid_z = abs(floor(z/spacing))
 
      num_x = 1.0/spacing
      num_y = 1.0/spacing
      num_z = 1.0/spacing
 
      hash_val =  (num_x * num_y * grid_z) + (grid_y * num_x + grid_x) + 1
      return
    end function hash_val
end module sortgpu
 
program interop
    use ISO_C_BINDING
    use sortgpu
    use openacc
    implicit none
 
    integer :: i,indx
    real :: x,y,z
    integer, parameter :: dims = 3
    integer(C_INT), parameter :: num = 1000000
    integer(C_INT), parameter :: length = dims*num
    real (C_FLOAT) :: positions(length)
    integer(C_INT) :: keys(num)
    integer(C_INT) :: values(num)
    type (C_PTR) :: stream

    ! OpenACC may not use the default CUDA stream so we must query it
    stream = acc_get_cuda_stream(acc_async_sync)

    ! OpenACC will create positions, keys, and values arrays on the device
    !$acc data create(positions, keys, values)
 
        ! NVIDIA cuRandom will create our initial random data
        !$acc host_data use_device(positions)
        call fill_rand(C_LOC(positions), length, stream)
        !$acc end host_data
 
        ! OpenACC will calculate the hash value for each particle
        !$acc parallel loop
        do i=0,num-1
            indx = i*3;
            x = positions(indx+1)
            y = positions(indx+2)
            z = positions(indx+3)
 
            ! Key is 'particle' id and value is hashed position
            keys(i+1) = hash_val(x,y,z);
            values(i+1) = i+1;
        enddo
        !$acc end parallel loop
 
        ! Thrust will be used to sort our key value pairs
        !$acc host_data use_device(keys, values)
        call sort(C_LOC(keys), C_LOC(values), num, stream);
        !$acc end host_data
 
    !$acc end data    
 
end program interop
