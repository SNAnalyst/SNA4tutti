# These tests focus on the update-check helpers because they are easy to break
# with small changes in version handling or GitHub URL construction.

pkg_namespace <- getNamespace("sna4tutti")
tinytest_namespace <- getNamespace("tinytest")
attach(tinytest_namespace, name = "tinytest_expectations")

check_and_update_github <- get("check_and_update_github",
                               envir = pkg_namespace,
                               inherits = FALSE)
check_github <- get("check_github",
                    envir = pkg_namespace,
                    inherits = FALSE)
description_field_from_lines <- get(".description_field_from_lines",
                                    envir = pkg_namespace,
                                    inherits = FALSE)
github_description_url <- get(".github_description_url",
                              envir = pkg_namespace,
                              inherits = FALSE)
github_package_name <- get(".github_package_name",
                           envir = pkg_namespace,
                           inherits = FALSE)

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
  is.na(description_field_from_lines(description_lines, "MissingField"))
)

current_check <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = description_lines,
  installed_version = "0.5.5"
)

expect_true(isTRUE(current_check$up_to_date))
expect_identical(current_check$latest_version, "0.5.5")

outdated_check <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = description_lines,
  installed_version = "0.5.4"
)

expect_true(isFALSE(outdated_check$up_to_date))

development_check <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = description_lines,
  installed_version = "0.5.6"
)

expect_true(isTRUE(development_check$up_to_date))

unknown_remote <- check_github(
  pkg = "SNAnalyst/sna4tutti",
  ref = "main",
  description_lines = c("Package: sna4tutti"),
  installed_version = "0.5.5"
)

expect_true(is.na(unknown_remote$latest_version))
expect_true(is.na(unknown_remote$up_to_date))

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

expect_true(is.na(missing_install))
