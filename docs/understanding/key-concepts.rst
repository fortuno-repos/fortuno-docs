.. _sec-understanding_key-concepts:

************
Key concepts
************

Fortuno is built around the following key concepts:

* **Test cases** (often referred as tests): Represent individual named unit tests and contain the
  code to execute, when the test is run.

* **Test suites**: Represent named test containers for structuring your tests. They might contain
  test cases and further test suites (up to arbitrary nesting level). Their initialization (set-up)
  and finalization (tear-down) is customizable and they might provide data for the test cases and
  test suites they contain.

* **Test apps**: Driver programs responsible for setting up and tearing down the test suites and
  running the tests.

Depending, whether the routines you test are serial (eventually with OpenMP-parallelization),
MPI-parallelized or coarray-parallelized, you need to use different versions of these objects.
Fortuno offers for all these three cases a special interface.

Additionally, Fortuno uses an unnamed container for tests and tests suites:

* **Test lists**: Collect various test cases and test suites.


Analyzing a minimal working example
===================================

Let's use the example from the :ref:`sec-tutorials` section to understand, how some of those key
concepts can be combined to build unit tests (and to learn some best practices with Fortuno):

.. literalinclude:: ../tutorials/quickstart.data/testapp.f90
   :language: fortran

So what happened here?

First of all, we defined a module for the tests and a program which drives the testing. It is
generally a good practice to separate the unit tests from the driver program as one driver program
might be reponsible for driving tests from multiple modules. The test module contains the function
``tests()``, which returns the list of the unit tests it wants to expose.

In the test module, we have imported following objects:

.. literalinclude:: ../tutorials/quickstart.data/testapp.f90
   :lines: 4
   :language: fortran

* ``is_equal``: Function to check the equality of two objects returning detailed information about
  the check.

* ``serial_case_item``: Function returing a wrapped test case object for serial tests. The ``_item``
  suffix indicates that this is a wrapper allowing to use the test case object as an item (an
  element) of an array. We have introduced the abbreviation ``test`` for this rather longish name.

* ``serial_check``: Subroutine for registering the result of an actual check in serial tests,
  abbreviated here as ``check``.

* ``test_list``: Type to use for collecting the tests.

The function ``tests()`` is pretty simple, we just return a ``test_list`` instance containing all
the tests we wish to export from this module.

.. literalinclude:: ../tutorials/quickstart.data/testapp.f90
   :lines: 9-18
   :language: fortran

For creating the individual test items, we employed the ``serial_test_case_item()`` function (using
its local abbreviated name ``test()``). In each invocation, we provided a distinctive name for the
test and specified the subroutine that should be executed when the test is run.

Then the unit tests were defined in form of subroutines:

.. literalinclude:: ../tutorials/quickstart.data/testapp.f90
   :lines: 20-37
   :language: fortran

Our (rather simple) test subroutines need no arguments, they interact with the testing framework by
calling specific subroutines, such as ``check()`` in our example. The ``check()`` subroutine accepts
either a logical expression—for instance, ``factorial(0) == 1``—or a unique type, as returned by the
``is_equal()`` function, which encapsulates the outcome of the comparison and additional details in
case of a failure. The ``check()`` call registers the verification outcome in the framework,
including any failure specifics. A test is deemed successful if no ``check()`` calls with failing
(e.g. logically false) argument had been triggered during the run.

The actual program driver program is trivial, we just executed the serial command line app with all
the tests we have written.

.. literalinclude:: ../tutorials/quickstart.data/testapp.f90
   :lines: 42-50
   :language: fortran

We utilized the ``execute_serial_cmd_app()`` subroutine, feeding it with the list of test items
returned by the ``tests()`` function of the test module. You shouldn't add any code after this call,
as it would not return. Once ``execute_serial_cmd_app()`` completes its task, it halts the code and
communicates the result to the operating system via an exit code—0 if all tests pass, or a positive
integer to indicate failures.
