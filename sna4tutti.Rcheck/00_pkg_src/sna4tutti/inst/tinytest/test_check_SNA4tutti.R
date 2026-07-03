# These tests focus on the GitHub update helpers because small changes in URL
# construction or version handling can silently break update guidance.

if (!"tinytest_expectations" %in% base::search()) {
  base::attach(base::asNamespace("tinytest"), name = "tinytest_expectations")
}

pkg_namespace <- base::getNamespace("sna4tutti")

check_and_update_github <- base::get(
  "check_and_update_github",
  envir = pkg_namespace,
  inherits = FALSE
)
check_github <- base::get(
  "check_github",
  envir = pkg_namespace,
  inherits = FALSE
)
description_field_from_lines <- base::get(
  ".description_field_from_lines",
  envir = pkg_namespace,
  inherits = FALSE
)
github_description_url <- base::get(
  ".github_description_url",
  envir = pkg_namespace,
  inherits = FALSE
)
github_package_name <- base::get(
  ".github_package_name",
  envir = pkg_namespace,
  inherits = FALSE
)

description_lines <- c(
  "Package: sna4tutti",
  "Version: 0.5.5",
  "Description: First line",
  "    second line"
)

expect_identical(
  github_package_name("SNAnalyst/sna4tutti"),
  "sna4tutti"
)

expect_identical(
  github_description_url("SNAnalyst/sna4tutti", ref = "main"),
  "https://raw.githubusercontent.com/SNAnalyst/sna4tutti/main/DESCRIPTION"
)

expect_identical(
  description_field_from_lines(description_lines, "Version"),
  "0.5.5"
)

expect_identical(
  description_field_from_lines(description_lines, "Description"),
  "First line second line"
)

expect_true(
  base::is.na(description_field_from_lines(description_lines, "MissingField"))
)

current_check <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = description_lines,
  installed_version = "0.5.5"
)

expect_true(base::isTRUE(current_check$up_to_date))
expect_identical(current_check$latest_version, "0.5.5")

outdated_check <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = description_lines,
  installed_version = "0.5.4"
)

expect_true(base::isFALSE(outdated_check$up_to_date))

development_check <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = description_lines,
  installed_version = "0.5.6"
)

expect_true(base::isTRUE(development_check$up_to_date))

unknown_remote <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = c("Package: sna4tutti"),
  installed_version = "0.5.5"
)

expect_true(base::is.na(unknown_remote$latest_version))
expect_true(base::is.na(unknown_remote$up_to_date))

expect_message(
  check_and_update_github(
    pkg = "SNAnalyst/sna4tutti",
    ref = "main",
    description_lines = c("Package: sna4tutti"),
    installed_version = "0.5.5",
    ask = FALSE
  ),
  pattern = "requires internet access to GitHub"
)

missing_install <- suppressMessages(
  check_and_update_github(
    pkg = "SNAnalyst/sna4tutti",
    ref = "main",
    description_lines = description_lines,
    installed_version = NA_character_,
    ask = FALSE
  )
)

expect_true(base::is.na(missing_install))
