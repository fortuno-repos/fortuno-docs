************************
Quickstart (using Meson)
************************

.. admonition:: You will learn to
   :class: note

   - create a minimal project with Meson,
   - add unit tests to the project,
   - build the project and run the tests.


Before jumping in
=================

To begin this quickstart tutorial on Fortuno, ensure to have a recent version of the `Meson build system <https://mesonbuild.com/>`_ (version 1.5 or newer) and a Fortran
compiler that implements the Fortran 2018 standard. Fortuno operates smoothly with recent versions
of several popular Fortran compilers, but older Fortran compilers are known to fail to build it.
Please check the minimal compiler versions in the `Fortuno readme
<https://github.com/fortuno-repos/fortuno?tab=readme-ov-file#compiler-compatibility>`_.


Getting comfortable
===================

We'll create a library named ``mylib`` containing a single function ``factorial()`` to calculate the
factorial of an integer. The testing of the library shall be automated using unit tests.

Create a directory (e.g. ``mylib``) for the project with the 4 subdirectories ``src``, ``app``, ``test`` and ``subprojects``.

.. code-block::

   mkdir mylib
   cd mylib
   mkdir src app test subprojects

We develop the first version of our library by creating ``src/mylib.f90``:

.. literalinclude:: quickstart.data/mylib.f90
   :caption: src/mylib.f90
   :language: fortran

The main executable of our project (``app/main.f90``) should just print out the factorial for three
specific values, so that we can check whether our ``factorial()`` function works as expected:

.. literalinclude:: quickstart.data/main.f90
   :caption: app/main.f90
   :language: fortran

Now, let's automatize the testing procedure. We will write three unit tests, which check the
factorial function for the specific input values 0, 1 and 2. The last test should intentionally fail
to demonstrate the error reporting. Create a file ``test/testapp.f90`` with following content:

.. literalinclude:: quickstart.data/testapp.f90
   :caption: test/testapp.f90
   :language: fortran

Finally, we create a ``meson.build`` in the main folder to describe the project for Meson:

.. note:: This is a highly minimalistic Meson configuration file created for demonstration purpose
   only.

.. literalinclude:: quickstart.data/meson.build
   :caption: meson.build
   :language: meson

Additionally, in order to be able to fetch and build Fortuno during the build, an appropriate wrap-file ``fortuno.wrap`` must be created in the ``subprojects`` folder.

.. literalinclude:: quickstart.data/fortuno.wrap
   :caption: subprojects/fortuno.wrap
   :language: ini

Now, we configure the project by running::

  FC=gfortran meson setup build

Then we build our library, the main app and the tests.

.. code-block:: shell

   ninja -C build

Finally we run the unit tests by invoking meson again:

.. code-block:: shell

   meson test -v -C build

The expected output will show a test failure for the test application. The verbose output reveals that the test app launched three unit tests in total, one of them failing.

.. literalinclude:: quickstart.data/testapp.meson.out
   :caption: Output of the "ctest" command
   :language: output

Congratulations! You've now implemented and completed your first set of Fortuno unit tests,
assessing your project's integrity.

.. seealso::
   * Section :ref:`sec-understanding_key-concepts` contains a detailed analyzis of this minimal test
     application and also more information on some key concepts.

   * For real projects, consider to use the `Fortran project cookiecutter template
     <https://github.com/fortuno-repos/cookiecutter-fortran-project>`_ to generate a fully featured
     Meson setup following best practices.
