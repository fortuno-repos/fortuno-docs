project('mylib', 'fortran')

fortuno_serial_dep = dependency('fortuno-serial', fallback: ['fortuno', 'fortuno_serial_dep'])

mylib_lib = library('mylib', sources: files('src/mylib.f90'))
mylib_dep = declare_dependency(link_with: mylib_lib)

mylib_app_exe = executable(
  'mylib_app',
  sources: files('app/main.f90'),
  dependencies: [mylib_dep]
)

testapp_exe = executable(
  'testapp',
  sources: files('test/testapp.f90'),
  dependencies: [mylib_dep, fortuno_serial_dep]
)
test('testapp', testapp_exe)
