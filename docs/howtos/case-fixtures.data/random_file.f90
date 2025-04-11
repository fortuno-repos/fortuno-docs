module random_file
  implicit none

  private
  public :: random_file_name

contains


  !> Returns a random temporary file name with fixed prefix and suffix
  function random_file_name(prefix, suffix, seqlen) result(tempfile)

    !> Prefix to use in the file name
    character(*), intent(in) :: prefix

    !> Suffix to use in the file name
    character(*), intent(in) :: suffix

    !> Lenght of the random sequence in the file name
    integer, intent(in) :: seqlen

    !> Generated file name on exit
    character(len=:), allocatable :: tempfile

    character(*), parameter :: charset =  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ&
        &abcdefghijklmnopqrstuvwxyz"

    real :: rand
    integer :: ind, ii
    
    call random_seed()
    allocate(character(len=seqlen + len(prefix) + len(suffix)) :: tempfile)
    tempfile(: len(prefix)) = prefix
    do ii = 1, seqlen
      call random_number(rand)
      ind = 1 + int(rand * real(len(charset)))
      tempfile(len(prefix) + ii : len(prefix) + ii) = charset(ind : ind)
    end do
    tempfile(len(prefix) + seqlen + 1 :) = suffix
  
  end function random_file_name

end module random_file
