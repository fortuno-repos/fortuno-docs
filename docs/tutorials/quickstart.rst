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
<https://github.com/fortuno-repos/fortuno?tab=readme-ov-file#known-issues>`_.


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
   fortuno = { git = "https://github.com/fortuno-repos/fortuno" }


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

* **Test cases** (often referred as tests): Represent individual unit tests and contain the code
  to execute, when the test is run.

* **Test suites** (not shown in the example above): Containers for structuring your tests. They
  might contain test cases and further test suites (up to arbitrary nesting level). Their
  initialization (set-up) and finalization (tear-down) is customizable.

* **Test apps**: driver programs responsible for setting up and tearing down the test suites and
  running the tests.

Depending, whether the routines you test are serial (eventually with OpenMP-parallelization),
MPI-parallelized or coarray-parallelized, you need to use different versions of these objects.

In order to write our unit test app, we import the following objects:

.. literalinclude:: quickstart.data/testapp.f90
   :lines: 4-5
   :language: fortran

* ``execute_serial_cmd_app``: Convenience function setting up and executing the serial version of
  the command line test app.

* ``is_equal``: Function to check the equality of two objects returning detailed information about
  the check.

* ``serial_case_item``: Function returing a wrapped test case object for serial tests. The
  ``_item`` suffix indicates a wrapper allowing to use the test case object as an item (element) of
  an array. We have introduced the abbreviation ``test`` for this rather longish name.

* ``serial_check``: Subroutine for registering the result of actual checks in serial tests,
  abbreviated here as ``check``.

The actual program is pretty simple, we just execute the serial command line app with all the tests
we have written.

.. literalinclude:: quickstart.data/testapp.f90
   :lines: 8-14
   :language: fortran

We utilize the ``execute_serial_cmd_app()`` subroutine, feeding it with an array of test items
through the ``testitems`` parameter. You shouldn't add any code after this call, as it does not
return. Once ``execute_serial_cmd_app()`` completes its task, it halts the code and communicates the
result to the operating system via an exit code—0 if all tests pass, or a positive integer to
indicate failures.

For creating the individual test items, we employ the ``serial_test_case_item()`` function (using
its local abbreviated name ``test()``). In each invocation, we provide a distinctive name for the
test and specify the subroutine that should be executed when the test is run.

.. literalinclude:: quickstart.data/testapp.f90
   :lines: 18-34
   :language: fortran

Our (rather simple) test subroutines need no arguments, they interact with the testing framework by
calling specific subroutines, such as ``check()`` in our example. The ``check()`` subroutine accepts
either a logical expression—for instance, ``factorial(0) == 1``—or a unique type, as returned by the
``is_equal()`` function, which encapsulates the outcome of the comparison and additional details in
case of a failure. The ``check()`` call registers the verification outcome in the framework,
including any failure specifics. A test is deemed successful if no ``check()`` calls with failing
(e.g. logically false) argument had been triggered during the run.
