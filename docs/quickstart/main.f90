program main
  use mylib, only: factorial
  implicit none

  print "('factorial(', i0, ') = ', i0)",&
      & 0, factorial(0),&
      & 1, factorial(1),&
      & 2, factorial(2)

end program main
