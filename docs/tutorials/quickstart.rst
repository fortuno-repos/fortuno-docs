********************
Fortuno in 5 minutes
********************

.. admonition:: You will learn to ...
   :class: note

   - create a minimal project with the Fortran package manager,
   - add unit tests to the project,
   - understand some key concepts of the testing framework.


Before jumping in
=================

To begin this quickstart tutorial on Fortuno, ensure to have a recent version of the `Fortran
package manager (fpm) <https://fpm.fortran-lang.org/>`_ (version 0.10 or newer) and a Fortran
compiler that implements the Fortran 2018 standard. Fortuno operates smoothly with recent versions
of several popular Fortran compilers, but older Fortran compilers are known to fail to build it.
Please check the minimal compiler versions in the `Fortuno readme
<https://github.com/fortuno-repos/fortuno?tab=readme-ov-file#compiler-compatibility>`_.


Getting comfortable
===================

We'll create a library named ``mylib`` containing a single function ``factorial()`` to calculate the
factorial of an integer. The testing of the library shall be automated using unit tests.

We first create a new project for ``mylib`` using fpm:

.. code-block:: shell

   fpm new mylib

Then, we add the following to the ``fpm.toml`` file (package manifest) to include Fortuno as a
development dependency:

.. code-block:: toml

   [dev-dependencies]
   fortuno = { git = "https://github.com/fortuno-repos/fortuno-fpm-serial.git" }


We develop the first version of our library by adapting ``src/mylib.f90`` as follows:

.. literalinclude:: quickstart.data/mylib.f90
   :caption: src/mylib.f90
   :language: fortran

The main executable of our project should just print out the factorial for three specific values, so
that we can check whether our ``factorial()`` function works as expected:

.. literalinclude:: quickstart.data/main.f90
   :caption: app/main.f90
   :language: fortran

Now, let's automatize the testing procedure. We will write three unit tests, which check the
factorial function for the specific input values 0, 1 and 2. The last test should intentionally fail
to demonstrate the error reporting. Rename the file ``test/check.f90`` into ``test/testapp.f90`` and
modify the content as follows:

.. literalinclude:: quickstart.data/testapp.f90
   :caption: test/testapp.f90
   :language: fortran

Let's build our library and run the units tests by issuing

.. code-block:: shell

   fpm test

in the main project folder. The expected output will show two successful tests and one failure,
providing detailed information on the failed test.

.. literalinclude:: quickstart.data/testapp.out
   :caption: Output of the "fpm test" command
   :language: output

Congratulations! You've now implemented and completed your first set of Fortuno unit tests,
assessing your project's integrity.


Diving deeper
=============

Fortuno is built around the following key concepts:

* **Test cases** (often referred as tests): Represent individual named unit tests and contain the
  code to execute, when the test is run.

* **Test suites** (not shown in the example above): Represent named test containers for structuring
  your tests. They might contain test cases and further test suites (up to arbitrary nesting level).
  Their initialization (set-up) and finalization (tear-down) is customizable and they might provide
  data for the test cases and test suites they contain.

* **Test apps**: driver programs responsible for setting up and tearing down the test suites and
  running the tests.

Depending, whether the routines you test are serial (eventually with OpenMP-parallelization),
MPI-parallelized or coarray-parallelized, you need to use different versions of these objects.
Fortuno offers for all these three cases a special interface. In our case, we used the serial
interface.

Additionally, Fortuno uses an unnamed container for tests and tests suites:

* **Test lists**: Collect various test cases and test suites.

It is good practice to separate the unit tests from the driver program. We have therefore defined
the module containing the unit tests and the function ``tests()`` returning the list of the unit
tests the module wants to expose.

In the test module, we have imported following objects:

.. literalinclude:: quickstart.data/testapp.f90
   :lines: 4
   :language: fortran

* ``is_equal``: Function to check the equality of two objects returning detailed information about
  the check.

* ``serial_case_item``: Function returing a wrapped test case object for serial tests. The ``_item``
  suffix indicates a wrapper allowing to use the test case object as an item (an element) of an
  array. We have introduced the abbreviation ``test`` for this rather longish name.

* ``serial_check``: Subroutine for registering the result of an actual check in serial tests,
  abbreviated here as ``check``.

* ``test_list``: Type to use for collecting the tests.

The function ``tests()`` is pretty simple, we just return a ``test_list`` instance containing all
the tests we wish to export from this module.

.. literalinclude:: quickstart.data/testapp.f90
   :lines: 9-18
   :language: fortran

For creating the individual test items, we employed the ``serial_test_case_item()`` function (using
its local abbreviated name ``test()``). In each invocation, we provided a distinctive name for the
test and specified the subroutine that should be executed when the test is run.

Then the unit tests were defined in form of subroutines:

.. literalinclude:: quickstart.data/testapp.f90
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

.. literalinclude:: quickstart.data/testapp.f90
   :lines: 42-50
   :language: fortran

We utilized the ``execute_serial_cmd_app()`` subroutine, feeding it with the list of test items
returned by the ``tests()`` function of the test module. You shouldn't add any code after this call,
as it would not return. Once ``execute_serial_cmd_app()`` completes its task, it halts the code and
communicates the result to the operating system via an exit code—0 if all tests pass, or a positive
integer to indicate failures.
