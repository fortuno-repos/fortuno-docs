******************
Test case fixtures
******************

.. admonition:: You will learn how to
   :class: note

   - create and use test case fixtures in Fortuno.

.. note::

   This section assumes that you already have a working Fortuno project with unit tests in place.
   If you haven't set one up yet, we recommend using the `Fortran project cookiecutter template
   <https://github.com/fortuno-repos/cookiecutter-fortran-project>`_ or following the step-by-step
   guidance in the :ref:`sec-tutorials` section.

Fixtures in unit testing are essential for preparing and cleaning up the environment around each
test case. They help ensure that each test starts with a known, valid setup and that any resources
used during the test are properly released afterward. Common tasks handled by fixtures include
opening and closing files, managing database connections, or precomputing values required by tests.

Fortuno provides flexible mechanisms for implementing such fixtures. In this section, we will
explore two main approaches: a **manual fixture** and an **automatic fixture**. We’ll start with a
basic example and then move toward the more sophisticated setup.

Throughout the examples, we’ll simulate a temporary file environment. The setup phase will involve
creating and opening a temporary file, while the teardown will consist of closing and cleaning up
the file. Each test will receive both the file name and its corresponding unit number as input
parameters. To generate random file names, we use the following simple helper function:

.. literalinclude:: case-fixtures.data/random_file.f90
   :caption: random_file.f90
   :language: fortran

Make sure to include this module when compiling the examples that follow.


Manual Fixture
==============

The most straightforward strategy is to handle setup and teardown manually within each test
case. Although this method does not rely on Fortuno-specific features, it is often effective for
smaller or less complex test setups.

In this approach, we define a custom type that holds all necessary environment data (e.g., the
temporary file name and unit number). Each test explicitly creates an instance of this type and
manually invokes an initialization routine at the beginning. Cleanup is handled through a finalizer
associated with the type, which ensures proper teardown once the test completes.

.. literalinclude:: case-fixtures.data/testapp.manual.f90
   :caption: test/testapp.f90
   :language: fortran
   :emphasize-lines: 8-13, 31-46, 49-57, 61-64, 70-73

This method has the benefit of being highly transparent. Each test contains its own explicit setup
logic, which makes the test's behavior easy to follow and debug. There is no hidden initialization
logic happening “behind the scenes.” However, this approach leads to duplicated code across tests.
Forgetting to call the initialization routine, or calling it incorrectly, may lead to subtle and
hard-to-trace errors.

To address these issues, Fortuno allows you to externalize setup and teardown logic using automatic
fixtures, described next.


Automatic Fixture
=================

An automatic fixture improves maintainability by handling setup and teardown
outside the test itself. It also prevents accidental modification of test
parameters during execution by controlling how they are accessed.

To implement an automatic fixture, we modify the standard testing pattern in two key ways:

* Test routines are written with an ``intent(in)`` argument that provides read-only access to the
  prepared test environment.

* Initialization and finalization of this environment are performed outside the test routine,
  ensuring consistency and reducing boilerplate code.

Thanks to Fortuno's object-oriented architecture, integrating these changes is
straightforward. Let’s walk through the required steps:

* In Fortuno’s default setup, the ``serial_case`` type is used to represent test cases. This type
  extends a base type called ``serial_case_base`` and adds a pointer to a no-argument test
  procedure. Additionally, the ``run()`` method of the base type is overridden to invoke this
  argumentless procedure when the test is executed.

* For our custom fixture, we define a new type that also extends ``serial_case_base``. Instead of
  pointing to a procedure without arguments, it will store a pointer to a test routine with one
  dummy argument (our test environment). We override the ``run()`` method in this new type to set
  up the environment, to call the appropriate test routine and to tear down the environment again.

* Fortuno organizes test items—such as test cases, test suites, and their user-defined
  extensions—using arrays. Since Fortran arrays must be homogeneous (i.e., all elements must be of
  the same declared *type*), each test item is wrapped using the ``test_item`` type to ensure type
  uniformity. The ``test_item`` type holds a generic *class* pointer to the shared base type of all
  test cases and suites, allowing it to encapsulate any valid test item. To streamline the wrapping
  process, we will provide a helper function that constructs and wraps instances of our custom test
  case types automatically.

The following example demonstrates a minimal but complete implementation. Key changes are
highlighted for clarity:

.. literalinclude:: case-fixtures.data/testapp.casefixture.f90
   :caption: test/testapp.f90
   :language: fortran
   :linenos:
   :emphasize-lines: 16-21, 31-32, 68-76, 79-90

Here are a few additional remarks on the implementation:

* **Line 16–21**: When defining the custom test case type ``tempfile_case``, we reference the
  signature of an existing test procedure. This approach avoids the need for declaring a separate
  abstract interface, making the code more concise.
  
* **Line 31–32**: We call our custom wrapper function to create a properly wrapped ``test_item`` for
  each test within the array constructor.
  
* **Lines 68–76**: The trivial wrapper function constructs an instance of ``tempfile_case``, and
  then wraps it in a ``test_item``. The ``name`` field is inherited from the base type, while the
  ``proc`` field is defined in our derived type.  **Note:** For future compatibility, always use
  *keyword* arguments when calling structure constructors for extended types in Fortuno.
  
* **Lines 79–90**: The ``run()`` method first sets up the test environment, checks that the setup
  was successful, and then calls the test routine. Teardown happens automatically through the
  finalizer defined for the environment type, which is triggered when the routine exits.

This structure offers a clean and robust way to manage test setup and cleanup in Fortuno, reducing
repetition and minimizing the risk of accidental misuse. Automatic fixtures become especially
helpful as your test suite grows in size and complexity.
