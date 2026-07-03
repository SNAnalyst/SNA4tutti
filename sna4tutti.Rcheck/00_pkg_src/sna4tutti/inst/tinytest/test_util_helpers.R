# These tests focus on the internal utility helpers that are deterministic and
# low-risk to exercise. They give us confidence that maintenance helpers fail
# loudly and predictably instead of surprising us during package upkeep.

if (!"tinytest_expectations" %in% base::search()) {
  base::attach(base::asNamespace("tinytest"), name = "tinytest_expectations")
}

pkg_namespace <- base::getNamespace("sna4tutti")

dots_fun <- base::get("dots", envir = pkg_namespace, inherits = FALSE)
get_objs_from_dots <- base::get("get_objs_from_dots", envir = pkg_namespace, inherits = FALSE)
version_spec <- base::get("version_spec", envir = pkg_namespace, inherits = FALSE)
check_files_absent <- base::get("check_files_absent", envir = pkg_namespace, inherits = FALSE)
is_package <- base::get("is_package", envir = pkg_namespace, inherits = FALSE)

expect_identical(
  base::as.list(dots_fun(alpha, beta, gamma)),
  list(base::quote(alpha), base::quote(beta), base::quote(gamma))
)

expect_identical(
  get_objs_from_dots(dots_fun(alpha, beta)),
  c("alpha", "beta")
)

# Duplicate names are harmless, but the helper should collapse them so the same
# object is not saved twice into sysdata.rda.
expect_identical(
  suppressWarnings(get_objs_from_dots(dots_fun(alpha, beta, alpha))),
  c("alpha", "beta")
)

expect_error(
  get_objs_from_dots(list()),
  pattern = "Nothing to save"
)

expect_error(
  get_objs_from_dots(list("alpha")),
  pattern = "named objects"
)

expect_identical(
  version_spec(">= 1.2.3"),
  base::numeric_version("1.2.3")
)
expect_identical(
  version_spec("== 4.5.0"),
  base::numeric_version("4.5.0")
)

missing_file <- tempfile(fileext = ".txt")
expect_identical(check_files_absent(missing_file, overwrite = FALSE), NULL)

existing_file <- tempfile(fileext = ".txt")
file.create(existing_file)

expect_error(
  check_files_absent(existing_file, overwrite = FALSE),
  pattern = "overwrite = TRUE"
)
expect_identical(check_files_absent(existing_file, overwrite = TRUE), NULL)

expect_true(is_package("D:/Dropbox/R/eigen_packages/=git/SNA4tutti"))
expect_false(is_package(tempdir()))
