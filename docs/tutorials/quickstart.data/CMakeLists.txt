cmake_minimum_required(VERSION 3.22...3.28)

project(FortunoDocTest_tutorials_quickstart LANGUAGES Fortran)

add_library(mylib mylib.f90)

enable_testing()

add_executable(main main.f90)
set_target_properties(main PROPERTIES OUTPUT_NAME "main")
target_link_libraries(main PRIVATE mylib)
add_test(NAME docs/tutorials/quickstart:main COMMAND main)

add_executable(testapp testapp.f90)
set_target_properties(testapp PROPERTIES OUTPUT_NAME "testapp")
target_link_libraries(testapp PRIVATE mylib Fortuno::fortuno_serial)
add_test(NAME docs/tutorials/quickstart:testapp COMMAND testapp)
set_tests_properties(docs/tutorials/quickstart:testapp PROPERTIES WILL_FAIL TRUE)
