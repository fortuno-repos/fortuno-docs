===================
Test suite fixtures
===================

.. admonition:: You will learn to
   :class: note

   - create test suite fixtures with Fortuno.

.. note::

   This section assumes, that you already have a working project with Fortuno unit tests.
   You can set up one by using the `Fortran project cookiecutter template
   <https://github.com/fortuno-repos/cookiecutter-fortran-project>`_ or following the
   instructions in the :ref:`sec-tutorials` section.


Sometimes initialization and finalization must not be executed for each test separately, but only
once, before any tests from a group of tests are run or after all tests of the group had been
carried out. A typical scenario would be, if you have to load or generate large amount of data
before a certain group of tests accessing that data can be executed.

Those cases can be handled in Fortuno using suite fixtures. Test suites in Fortuno have basically
two functions:

* They serve as containers for building hierarchical test inftrastructure, each suite containing
  tests and further test suites.

* They can be extended to contain customized data and customized set-up and tear-down
  procedures. The set-up procedure of a suite is warranted to be executed before any tests in the
  suite are run, or before the set-up procedure of any of the contained suites is invoked. The
  tear-down procedure is warranted to be executed after all tests in the test suite had been carried
  out and the tear-down procedures of all contained suites had been invoked.

For demonstration purposes we will modify the example from the previous section: We will open a file
before a group of test is executed, and close it, once the tests had been carried out. The
information about the name of the file and the file unit should be passed to the tests. As
demonstrated below, there are two ways of passing data to individual tests of a suite: either by
using global module variables or using type components introduced by type extension. Former is
considerably simpler, but prone to accidental errors, especially when using with complex test
hierarchies. Latter needs somewhat more coding, but is is modular and robust.


Storing suite data in module variables
======================================

.. literalinclude:: suite-fixtures.data/testapp.suiteglobal.f90
   :caption: test/testapp.f90
   :language: fortran
   :linenos:
   :emphasize-lines: 16-21, 24-25, 34, 75-83, 86-95, 98-104
   

Storing data within test suites
===============================
 
.. literalinclude:: suite-fixtures.data/testapp.suite.f90
   :caption: test/testapp.f90
   :language: fortran
   :linenos:
   :emphasize-lines: 19-25, 28-33, 46-48, 57,64, 96-104, 107-116, 119-126, 129-137, 140-166
