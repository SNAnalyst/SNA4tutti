# This runner ensures that `R CMD check` executes the tinytest suite stored in
# `inst/tinytest`. Without it, the tests would exist but not protect releases.
if (requireNamespace("tinytest", quietly = TRUE)) {
  tinytest::test_package("sna4tutti")
}
