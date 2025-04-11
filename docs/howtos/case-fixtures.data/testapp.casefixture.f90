!> Module containing unit tests
module test_mylib
  use random_file, only : random_file_name
  use fortuno_serial, only : serial_case_base, check => serial_check,&
      & check_failed => serial_check_failed, suite => serial_suite_item, test_item, test_list
  implicit none

  type :: test_env
    character(:), allocatable :: filename
    integer :: unit = -1
  contains
    final :: final_test_env
  end type test_env


  !> Fixtured test case
  type, extends(serial_case_base) :: tempfile_case
    procedure(test_tempfile_1), pointer, nopass :: proc
  contains
    procedure :: run => tempfile_case_run
  end type tempfile_case

contains

  !> Returns the list of tests in this module
  function tests()
    type(test_list) :: tests

    tests = test_list([&
        suite("tempfile_demo", test_list([&
            tempfile_test("tempfile_1", test_tempfile_1),&
            tempfile_test("tempfile_2", test_tempfile_2)&
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


  !> Wraps a tempfile_case instance as test_item suitable for array constructors.
  function tempfile_test(name, proc) result(testitem)
    character(*), intent(in) :: name
    procedure(test_tempfile_1) :: proc
    type(test_item) :: testitem

    testitem = test_item(tempfile_case(name=name, proc=proc))

  end function tempfile_test


  !> Run procedure of the tempfile_case type.
  subroutine tempfile_case_run(this)
    class(tempfile_case), intent(in) :: this

    type(test_env) :: env
    
    call init_test_env(env)
    call check(env%unit /= -1, msg="Failed to open tempfile")
    if (check_failed()) return
    call this%proc(env)

  end subroutine tempfile_case_run
  

  subroutine test_tempfile_1(env)
    type(test_env), intent(in) :: env
    write(env%unit, "(a)") "Hello from test_tempfile_1"
  end subroutine test_tempfile_1

  
  subroutine test_tempfile_2(env)
    type(test_env), intent(in) :: env
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
