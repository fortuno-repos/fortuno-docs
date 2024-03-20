cmake_minimum_required(VERSION 3.22...3.28)

project(FortunoDocTest LANGUAGES Fortran)

find_package(Fortuno)
find_package(FortunoMpi)
find_package(FortunoCoarray)

enable_testing()

add_subdirectory(docs/tutorials/quickstart.data/)
