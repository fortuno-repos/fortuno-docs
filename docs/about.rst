*************
About Fortuno
*************

Fortuno is a flexible and extensible unit testing framework tailored for modern Fortran programming.
Its name is an acronym for "Fortran Unit-Testing Objects", but also hints at the Esperanto word
"fortuno" (fortune), symbolizing its goal of bringing success to Fortran developers and to their (hopefully) well tested projects.

Fortuno offers a simple, user-friendly interface requiring only minimal amount of boiler-plate code
when writing unit tests. It puts strong emphasis on modularity and extensibility, providing a robust
foundation for creating customized unit testing environments. Fortuno is written in Fortran 2018.

The framework supports a variety of testing styles and scenarios, including:

* straightforward unit tests for basic validation,

* fixtured tests initializing and finalizing test environments,

* parameterized tests that allow for varied input testing within the same test structure,

* nestable test containers with configurable initializers and finalizers to structure large test
  sets,

* serial unit testing for serial and OpenMP-threaded applications,

* parallel unit testing tailored for MPI- and coarray-parallelized projects, and

* smooth integration with various build systems (`fpm <https://fpm.fortran-lang.org/>`_, `CMake
  <https://cmake.org/>`_ and `Meson <https://mesonbuild.com/>`_).

Fortuno is an open source, community developed project. You can follow and join the development on
the `Fortuno project <https://github.com/fortuno-repos/fortuno>`_ page on GitHub.
