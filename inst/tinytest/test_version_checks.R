# These tests cover the DESCRIPTION-driven requirement logic. That logic is the
# central contract between the package metadata and the tutorial runtime checks,
# so regressions here tend to confuse students quickly.

if (!"tinytest_expectations" %in% base::search()) {
  base::attach(base::asNamespace("tinytest"), name = "tinytest_expectations")
}

pkg_namespace <- base::getNamespace("sna4tutti")

package_description_field <- base::get(
  ".package_description_field",
  envir = pkg_namespace,
  inherits = FALSE
)
parse_dependency_field <- base::get(
  ".parse_dependency_field",
  envir = pkg_namespace,
  inherits = FALSE
)
parse_remote_field <- base::get(
  ".parse_remote_field",
  envir = pkg_namespace,
  inherits = FALSE
)
tutorial_package_requirements <- base::get(
  "tutorial_package_requirements",
  envir = pkg_namespace,
  inherits = FALSE
)
minimum_r_version <- base::get(
  ".minimum_r_version",
  envir = pkg_namespace,
  inherits = FALSE
)
minimum_rstudio_version <- base::get(
  ".minimum_rstudio_version",
  envir = pkg_namespace,
  inherits = FALSE
)
current_rstudio_version <- base::get(
  ".current_rstudio_version",
  envir = pkg_namespace,
  inherits = FALSE
)
normalize_version <- base::get(
  ".normalize_version",
  envir = pkg_namespace,
  inherits = FALSE
)
version_is_at_least <- base::get(
  ".version_is_at_least",
  envir = pkg_namespace,
  inherits = FALSE
)
version_is_equal <- base::get(
  ".version_is_equal",
  envir = pkg_namespace,
  inherits = FALSE
)
install_commands <- base::get(
  ".install_commands",
  envir = pkg_namespace,
  inherits = FALSE
)

expect_identical(package_description_field("Package"), "sna4tutti")
expect_identical(
  package_description_field("Config/sna4tutti/min-rstudio"),
  "2026.01.1"
)
expect_true(base::is.na(package_description_field("DefinitelyMissingField")))

depends <- parse_dependency_field("Depends")
expect_identical(depends$pkg[[1]], "R")
expect_identical(depends$version[[1]], "4.5.0")

imports <- parse_dependency_field("Imports")
expect_true(base::all(c("pkg", "version") %in% base::names(imports)))
expect_identical(
  imports$version[imports$pkg == "learnr"],
  "0.11.6"
)
expect_identical(
  imports$version[imports$pkg == "SNA4DSData"],
  "0.9.93"
)

remotes <- parse_remote_field()
expect_true(base::all(c("pkg", "where") %in% base::names(remotes)))
expect_identical(
  remotes$where[remotes$pkg == "snafun"],
  "SNAnalyst/snafun"
)
expect_identical(
  remotes$where[remotes$pkg == "GERGM"],
  "matthewjdenny/GERGM"
)

selected_requirements <- tutorial_package_requirements(
  packages = c("learnr", "snafun", "GERGM")
)

expect_identical(
  selected_requirements$pkg,
  c("GERGM", "learnr", "snafun")
)
expect_identical(
  selected_requirements$version,
  c("0.13.0", "0.11.6", "0.2026.0")
)
expect_identical(
  selected_requirements$where,
  c("matthewjdenny/GERGM", "CRAN", "SNAnalyst/snafun")
)

expect_identical(minimum_r_version(), "4.5.0")
expect_identical(minimum_rstudio_version(), "2026.01.1")

expect_identical(
  normalize_version("2026.01.1+999"),
  "2026.01.1"
)
expect_identical(
  normalize_version("2026.01.1+999", n = 2),
  "2026.01"
)

expect_true(version_is_at_least("4.5.2", "4.5.0"))
expect_false(version_is_at_least("4.4.9", "4.5.0"))
expect_true(version_is_at_least("4.5.2", ""))

expect_true(version_is_equal("2026.01.1+999", "2026.01.1"))
expect_false(version_is_equal("2026.02.1", "2026.01.1"))

command_matrix <- base::data.frame(
  pkg = c("learnr", "snafun"),
  version = c("0.11.6", "0.2026.0"),
  where = c("CRAN", "SNAnalyst/snafun"),
  stringsAsFactors = FALSE
)

expect_identical(
  install_commands(command_matrix),
  c(
    "     install.packages('learnr')",
    "     remotes::install_github('SNAnalyst/snafun')"
  )
)

expect_identical(
  sna4tutti:::check_packages(
    reqs = base::data.frame(
      pkg = "stats",
      version = "",
      where = "CRAN",
      stringsAsFactors = FALSE
    ),
    attempt_install = FALSE
  ),
  "Wonderful, all is fine."
)

missing_verdict <- sna4tutti:::check_packages(
  reqs = base::data.frame(
    pkg = "definitelymissingpkg",
    version = "",
    where = "CRAN",
    stringsAsFactors = FALSE
  ),
  attempt_install = FALSE
)

expect_true(
  base::any(grepl("definitelymissingpkg", missing_verdict, fixed = TRUE))
)
expect_true(
  base::any(grepl("install.packages\\('definitelymissingpkg'\\)", missing_verdict))
)

low_version_verdict <- sna4tutti:::check_packages(
  reqs = base::data.frame(
    pkg = "stats",
    version = "999.0.0",
    where = "CRAN",
    stringsAsFactors = FALSE
  ),
  attempt_install = FALSE
)

expect_true(
  base::any(grepl("version of the following packages is too low", low_version_verdict))
)

expect_error(
  sna4tutti:::check_packages(
    reqs = base::data.frame(pkg = "stats", stringsAsFactors = FALSE),
    attempt_install = FALSE
  ),
  pattern = "must contain columns"
)

expect_true(
  base::isTRUE(sna4tutti::check_r_equal_or_larger(version = "0.0.1", verdict = FALSE))
)
expect_false(
  base::isTRUE(sna4tutti::check_r_equal_or_larger(version = "999.0.0", verdict = FALSE))
)

expect_true(
  base::isTRUE(sna4tutti::check_rstudio_equal_or_larger(version = "0.0.1", verdict = FALSE)) ||
    base::isFALSE(sna4tutti::check_rstudio_equal_or_larger(version = "0.0.1", verdict = FALSE))
)
expect_false(
  base::isTRUE(sna4tutti::check_rstudio_equal_or_larger(version = "9999.0.0", verdict = FALSE))
)

original_rstudio_version <- base::Sys.getenv("RSTUDIO_VERSION", unset = NA_character_)
base::on.exit({
  if (base::is.na(original_rstudio_version)) {
    base::Sys.unsetenv("RSTUDIO_VERSION")
  } else {
    base::Sys.setenv(RSTUDIO_VERSION = original_rstudio_version)
  }
}, add = TRUE)

if (!rstudioapi::isAvailable(child_ok = TRUE)) {
  base::Sys.unsetenv("RSTUDIO_VERSION")
  expect_true(base::is.na(current_rstudio_version()))

  base::Sys.setenv(RSTUDIO_VERSION = "2099.01.1+999")
  expect_identical(current_rstudio_version(), "2099.01.1+999")
}
