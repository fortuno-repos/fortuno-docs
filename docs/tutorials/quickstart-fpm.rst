**********************
Quickstart (using fpm)
**********************

.. admonition:: You will learn to
   :class: note

   - create a minimal project with the Fortran package manager (fpm),
   - add unit tests to the project,
   - build the project and run the tests.


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

.. seealso::
   * Section :ref:`sec-understanding_key-concepts` contains a detailed analyzis of this minimal test
     application and also more information on some key concepts.
