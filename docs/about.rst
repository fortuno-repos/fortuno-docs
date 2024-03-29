****************
What is Fortuno?
****************

Fortuno is a versatile and extensible unit testing framework designed specifically for the modern
Fortran programming language. The framework's name is a blend of "Fortran Unit-Testing Objects," but
also nods to the Esperanto word for "fortune," reflecting its aim to bring good fortune to Fortran
developers and their projects.

Fortuno offers a simple, user-friendly interface requiring only minimal amount of boiler-plate code
when writing unit tests. It puts strong emphasis on modularity and extensibility, providing a robust
foundation for creating customized unit testing environments. Fortuno is written in Fortran 2018.

The framework supports a variety of testing styles and scenarios, including:

* straightforward unit tests for basic validation,

* fixtured tests initializing and finalizing test environments,

* parameterized tests that allow for varied input testing within the same test structure,

* nestable test containers to structure large test sets,

* serial unit testing for serial and OpenMP-threaded applications,

* parallel unit testing tailored for MPI- and coarray-parallelized projects, and

* smooth integration with various build systems (`fpm <https://fpm.fortran-lang.org/>`_, `CMake
  <https://cmake.org/>`_ and `Meson <https://mesonbuild.com/>`_).

Fortuno aims to enhance the quality and reliability of Fortran codebases, offering a practical tool
for Fortran developers seeking to incoprorate unit testing practices in their software development
lifecycle.

Fortuno is an open source, community developed project. You can follow and join the development on
the `Fortuno project <https://github.com/fortuno-repos/fortuno>`_ page on GitHub.
