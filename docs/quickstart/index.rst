**********
Quickstart
**********

Before jumping in
=================

To begin this crash course tutorial on Fortuno, ensure you have the latest version of the `Fortran
package manager (fpm) <https://fpm.fortran-lang.org/>`_ and a Fortran compiler that implements the
Fortran 2018 standard. Fortuno operates smoothly with both the `Intel Fortran Compiler
<https://www.intel.com/content/www/us/en/developer/tools/oneapi/toolkits.html>`_—requiring the
oneAPI Base Toolkit and the HPC Toolkit—and the `NAG Fortran Compiler
<https://nag.com/fortran-compiler/>`_. However, it can not be built with the GNU Fortran Compiler as
of version 13.2 due to compiler bugs. For the latest compiler compatibility, refer to the `Fortuno
README <https://github.com/fortuno-repos/fortuno/blob/main/README.rst>`_.


Getting comfortable
===================

We'll create a library named mylib containing a single function ``factorial()`` to calculate the
factorial of an integer. This library will be tested using unit tests.

We first create a new project for `mylib` using fpm:

.. code-block:: shell

   fpm new mylib

Then, we add the following to the ``fpm.toml`` file (package manifest) to include Fortuno as a
development dependency:

.. code-block:: toml

   [dev-dependencies]
   fortuno = { git = "https://github.com/fortuno-repos/fortuno" }


We develop the first version of our library by adapting ``src/mylib.f90`` as follows:

.. literalinclude:: mylib.f90
   :caption: src/mylib.f90
   :language: fortran

Now, we will write three unit tests, which check the factorial function the specific input values 0,
1 and 2. The last should intentionally fail to demonstrate the error reporting. We adapt the content
of ``test/check.f90`` as follows:

.. literalinclude:: testapp.f90
   :caption: test/check.f90
   :language: fortran

Let's build our library and run the units tests by issuing

.. code-block:: shell

   fpm test

in the main project folder. The expected output will show two successful tests and one failure,
providing detailed information on the failed test.

.. literalinclude:: testapp.out
   :caption: Output of the "fpm test" command
   :language: output

Congratulations! You've now implemented and completed your first set of Fortuno unit tests,
assessing your project's integrity.


Diving deeper
=============

Fortuno is built around the following key concepts:

* **Test cases** (often referred as tests): Represent individual unit tests and can be run to
  execute the test code they contain.

* **Test suites** (not shown in the example above): Containers for structuring your tests. They
  might contain test cases and further test suites (with arbitrary nesting level). Their
  initialization (set-up) and finalization (tear-down) is customizable.

* **Test apps**: driver programs responsible for setting up and tearing down the test suites and
  running the tests.

Depending, whether the routines you test are serial (eventually with OpenMP-parallelization),
MPI-parallelized or coarray-parallelized, you need to use different versions of these objects.

.. literalinclude:: testapp.f90
   :lines: 4-5
   :language: fortran

In the example above, we first imported the necessary names from the ``fortuno`` module:

* ``execute_serial_cmd_app``: Convenience function executing the serial version of the command line
  test app.

* ``is_equal``: Function to check the equality of two objects returning detailed information about
  the check.

* ``serial_test_case_item``: Function returing a wrapped test case object for serial tests. The
  ``_item`` suffix indicates a wrapper allowing to use the test case object as an item (element) of
  an array. We have introduced the abbreviation ``test`` for this rather longish name.

* ``serial_check``: Subroutine for registering the result of an actual check in serial tests,
  abbreviated here as ``check``.

The actual program is pretty simple, we just execute the serial command line up with all the tests
we have written.

.. literalinclude:: testapp.f90
   :lines: 8-14
   :language: fortran

We utilize the ``execute_serial_cmd_app()`` subroutine, feeding it an array of test items through
the ``testitems`` parameter. You shouldn't add any code after this call, as it does not return. Once
``execute_serial_cmd_app()`` completes its task, it halts the code and communicates the result to
the operating system via an exit code—0 if all tests pass, or a positive integer to indicate
failures.

For creating individual test items, we employ the ``test()`` function (called
``serial_test_case_item()`` in the Fortuno module). With each invocation, you provide a distinctive
name for the test and specify the subroutine that should be executed during the test run.

.. literalinclude:: testapp.f90
   :lines: 18-34
   :language: fortran

The test subroutines must not have any arguments. They communicate with the test-framework via
special calls, in our case the ``check()`` call. The ``check()`` routine accepts either a logical
expression (e.g. ``factorial(0) == 1``) or a special type as returned for example by the
``is_equal()`` function, which contains the result of the comparison and further details in case of
a failure. The ``check()`` call registers the result of the check (and eventual failure details). A
test is considered to be successfull, when none of the ``check()`` calls in its subroutine
registered a failing check (logical false). In our case, we have only one ``check()`` call per
subroutine, so its status will determine the test status.

Test subroutines (in this simple cases) have no arguments, they interact with the testing framework
by calling specific subroutines, such as the  ``check()`` call in our example. The ``check()``
subroutine accepts either a logical statement—for instance, ``factorial(0) == 1``—or a unique type,
as from the ``is_equal()`` function, which encapsulates the outcome of the comparison and additional
details in case of a failure. The ``check()`` call registers the verification outcome in the
framework, including any failure specifics. A test is deemed successful if no ``check()`` calls with
failing (e.g. logically false) argument had been triggered during the run.