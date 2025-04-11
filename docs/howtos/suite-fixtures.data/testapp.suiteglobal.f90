!> Module containing unit tests
module test_mylib
  use random_file, only : random_file_name
  use fortuno_serial, only : check => serial_check, check_failed => serial_check_failed,&
      & serial_suite_base, test => serial_case_item, test_item, test_list
  implicit none

  type :: test_env
    character(:), allocatable :: filename
    integer :: unit = -1
  contains
    final :: final_test_env
  end type test_env


  ! Fixtured test suite
  type, extends(serial_suite_base) :: tempfile_test_suite
  contains
    procedure :: set_up => tempfile_test_suite_set_up
    procedure :: tear_down => tempfile_test_suite_tear_down
  end type tempfile_test_suite


  ! The global test environment instance.
  type(test_env), allocatable :: global_env

contains

  !> Returns the list of tests in this module
  function tests()
    type(test_list) :: tests

    tests = test_list([&
        tempfile_suite("tempfile_demo", test_list([&
            test("tempfile_1", test_tempfile_1),&
            test("tempfile_2", test_tempfile_2)&
        ]))&
    ])

  end function tests


  !> Intializes the test environment (opens temporary file)
  !!
  !! Note: A very simple-minded implementation, for demonstration purposes only.
  !!
  subroutine init_test_env(this)

    !> Test environment containing file name and file unit.
    !!
    !! Note: if the opening of the temporary file fails for any reasons the unit remains at its
    !! default value (-1) and the file name string will be unallocated.
    type(test_env), intent(out) :: this

    integer :: iostat

    this%filename = random_file_name("tmp-", ".txt", 10)
    !open(newunit=this%unit, file=this%filename, action="readwrite", iostat=iostat)

  end subroutine init_test_env


  !> Finalizes the test environment (closes temporary file)
  subroutine final_test_env(this)
    type(test_env), intent(inout) :: this
    
    if (this%unit /= -1) then
      ! You might want to add status="delete" to remove the temporary file
      close(this%unit)
    end if

  end subroutine final_test_env


  !> Returns a tempfile_suite instance wrapped as test_item to be used in an array constructors.
  function tempfile_suite(name, tests) result(testitem)
    character(*), intent(in) :: name
    type(test_list), intent(in) :: tests
    type(test_item) :: testitem

    testitem = test_item(tempfile_test_suite(name=name, tests=tests))

  end function tempfile_suite

  
  !> Initializes the test suite.
  subroutine tempfile_test_suite_set_up(this)
    class(tempfile_test_suite), intent(inout) :: this

    allocate(global_env)
    call init_test_env(global_env)
    call check(global_env%unit /= -1, msg="Failed to open tempfile")
    if (check_failed()) deallocate(global_env)

  end subroutine tempfile_test_suite_set_up


  !> Finalizes the test suite.
  subroutine tempfile_test_suite_tear_down(this)
    class(tempfile_test_suite), intent(inout) :: this

    if (allocated(global_env)) deallocate(global_env)

  end subroutine tempfile_test_suite_tear_down
  

  subroutine test_tempfile_1()
    write(global_env%unit, "(a)") "Hello from test_tempfile_1"
  end subroutine test_tempfile_1

  
  subroutine test_tempfile_2()
    write(global_env%unit, "(a)") "Hello from test_tempfile_2"
  end subroutine test_tempfile_2

end module test_mylib


!> Test app driving Fortuno unit tests.
program testapp
  use test_mylib, only : tests
  use fortuno_serial, only : execute_serial_cmd_app
  implicit none

  call execute_serial_cmd_app(tests())

end program testapp

