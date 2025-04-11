!> Module containing unit tests
module test_mylib
  use random_file, only : random_file_name
  use fortuno_serial, only : serial_case_base, check => serial_check,&
      & check_failed => serial_check_failed, scope_pointers => serial_scope_pointers,&
      & serial_suite_base, test_item, test_list, test_ptr_item
  implicit none

  
  !> Environment representing the test fixture.
  type :: test_env
    character(:), allocatable :: filename
    integer :: unit = -1
  contains
    final :: final_test_env
  end type test_env

  
  !> Extended test suite containing customized data, initializer and finalizer.
  type, extends(serial_suite_base) :: tempfile_test_suite
    type(test_env), allocatable :: env
  contains
    procedure :: set_up => tempfile_test_suite_set_up
    procedure :: tear_down => tempfile_test_suite_tear_down
  end type tempfile_test_suite

  
  !> Extended test case running a test procedure with one argument
  type, extends(serial_case_base) :: tempfile_test_case
    procedure(test_tempfile_1), pointer, nopass :: proc
  contains
    procedure :: run => tempfile_test_case_run
  end type tempfile_test_case

contains

  !!
  !! Tests
  !! 

  !> Returns the list of tests exported from this module.
  function tests()
    type(test_list) :: tests

    tests = test_list([&
        tempfile_suite("tempfile_demo", test_list([&
            tempfile_test("tempfile_1", test_tempfile_1),&
            tempfile_test("tempfile_2", test_tempfile_2)&
        ]))&
    ])

  end function tests

  
  !> Test 1
  subroutine test_tempfile_1(env)
    type(test_env), intent(in) :: env
    write(env%unit, "(a)") "Hello from test_tempfile_1"
  end subroutine test_tempfile_1

  
  !> Test 2
  subroutine test_tempfile_2(env)
    type(test_env), intent(in) :: env
    write(env%unit, "(a)") "Hello from test_tempfile_2"
  end subroutine test_tempfile_2

  
  !!
  !! Fixture infrastructure
  !!

  !> Intializes the test environment (opens temporary file).
  subroutine init_test_env(this)
    type(test_env), intent(out) :: this

    integer :: iostat

    this%filename = random_file_name("tmp-", ".txt", 10)
    open(newunit=this%unit, file=this%filename, action="readwrite", iostat=iostat)

  end subroutine init_test_env


  !> Finalizes the test environment (closes temporary file).
  subroutine final_test_env(this)
    type(test_env), intent(inout) :: this
    
    if (this%unit /= -1) then
      close(this%unit)
    end if

  end subroutine final_test_env


  !> Wraps a tempfile_test_suite instance as test_item to be used in an array constructors.
  function tempfile_suite(name, tests) result(testitem)
    character(*), intent(in) :: name
    type(test_list), intent(in) :: tests
    type(test_item) :: testitem

    testitem = test_item(tempfile_test_suite(name=name, tests=tests))

  end function tempfile_suite

  
  !> Initializes the test suite.
  subroutine tempfile_test_suite_set_up(this)
    class(tempfile_test_suite), intent(inout) :: this

    allocate(this%env)
    call init_test_env(this%env)
    call check(this%env%unit /= -1, msg="Failed to open tempfile")
    if (check_failed()) deallocate(this%env)

  end subroutine tempfile_test_suite_set_up


  !> Finalizes the test suite.
  subroutine tempfile_test_suite_tear_down(this)
    class(tempfile_test_suite), intent(inout) :: this

    ! Explicit deallocation to trigger the finalizer of the test environment.
    if (allocated(this%env)) deallocate(this%env)

  end subroutine tempfile_test_suite_tear_down

  
  !> Wraps a tempfile_test_case instance as test_item to be used in an array constructors.
  function tempfile_test(name, proc) result(testitem)
    character(*), intent(in) :: name
    procedure(test_tempfile_1) :: proc
    type(test_item) :: testitem

    testitem = test_item(tempfile_test_case(name=name, proc=proc))

  end function tempfile_test


  !> Runs test procedure with data from test suite.
  subroutine tempfile_test_case_run(this)
    class(tempfile_test_case), intent(in) :: this

    type(test_ptr_item), allocatable :: scopeptrs(:)
    type(test_env), pointer :: test_env_ptr

    ! Get pointers to hosting scopes
    ! scopeptrs(1): current scope - tempfile_test_case instance
    ! scopeptrs(2): first enclosing scope - tempfile_test_suite instance
    scopeptrs = scope_pointers()
    call check(size(scopeptrs) >= 2)
    if (check_failed()) return

    ! Create pointer to data stored in the test suite.
    test_env_ptr => null()
    select type (suite => scopeptrs(2)%item)
    type is (tempfile_test_suite)
      test_env_ptr => suite%env
    end select
    call check(associated(test_env_ptr))
    if (check_failed()) return

    ! Call test routine with data from test suite.
    call this%proc(test_env_ptr)

  end subroutine tempfile_test_case_run

end module test_mylib


!> Test app driving Fortuno unit tests.
program testapp
  use test_mylib, only : tests
  use fortuno_serial, only : execute_serial_cmd_app
  implicit none

  call execute_serial_cmd_app(tests())

end program testapp

