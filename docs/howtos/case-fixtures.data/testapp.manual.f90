!> Module containing unit tests
module test_mylib
  use random_file, only : random_file_name
  use fortuno_serial, only : is_equal, test => serial_case_item, check => serial_check,&
      & check_failed => serial_check_failed, suite => serial_suite_item, test_list
  implicit none

  type :: test_env
    character(:), allocatable :: filename
    integer :: unit = -1
  contains
    final :: final_test_env
  end type test_env

contains

  !> Returns the list of tests in this module
  function tests()
    type(test_list) :: tests

    tests = test_list([&
        suite("tempfile_demo", test_list([&
            test("tempfile_1", test_tempfile_1),&
            test("tempfile_2", test_tempfile_2)&
        ]))&
    ])

  end function tests


  !> Intializes the test environment (opens temporary file)
  subroutine init_test_env(this)

    !> Test environment containing file name and file unit.
    !!
    !! Note: if the opening of the temporary file fails for any reasons the unit remains at its
    !! default value (-1) and the file name string will be unallocated.
    type(test_env), intent(out) :: this

    integer :: iostat

    this%filename = random_file_name("tmp-", ".txt", 10)
    open(newunit=this%unit, file=this%filename, action="readwrite", iostat=iostat)
    if (iostat /= 0) this = test_env()

  end subroutine init_test_env


  !> Finalizes the test environment (closes temporary file)
  subroutine final_test_env(this)
    type(test_env), intent(inout) :: this
    
    if (this%unit /= -1) then
      close(this%unit, status="delete")
    end if

  end subroutine final_test_env
  

  subroutine test_tempfile_1()
    type(test_env) :: env
    call init_test_env(env)
    call check(env%unit /= -1, msg="Failed to open tempfile")
    if (check_failed()) return
    write(env%unit, "(a)") "Hello from test_tempfile_1"
  end subroutine test_tempfile_1

  
  subroutine test_tempfile_2()
    type(test_env) :: env
    call init_test_env(env)
    call check(env%unit /= -1, msg="Failed to open tempfile")
    if (check_failed()) return
    write(env%unit, "(a)") "Hello from test_tempfile_2"
  end subroutine test_tempfile_2

end module test_mylib


!> Test app driving Fortuno unit tests.
program testapp
  use test_mylib, only : tests
  use fortuno_serial, only : execute_serial_cmd_app
  implicit none

  call execute_serial_cmd_app(tests())

end program testapp

