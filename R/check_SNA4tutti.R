#' Check whether the installed `sna4tutti` package is current on GitHub
#'
#' Checks whether the locally installed version of `sna4tutti` matches the
#' version declared in the `DESCRIPTION` file on the GitHub repository.
#'
#' The function is designed as a user-facing convenience helper. It prints a
#' short status message and, in interactive sessions, can offer to install or
#' update the package from GitHub.
#'
#' The latest version is read from the repository's `main` branch. If GitHub
#' cannot be reached, the function returns `NA` invisibly after printing an
#' informative message.
#'
#' @return An invisible logical value. `TRUE` means that the installed package
#'   is up-to-date, `FALSE` means that GitHub reports a newer version, and `NA`
#'   means that the check could not be completed or the package is not
#'   installed.
#' @export
#'
#' @examples
#' \dontrun{
#' check_sna4tutti()
#' }
check_sna4tutti <- function() {
  check_and_update_github(pkg = "SNAnalyst/sna4tutti")
}





#' Check a GitHub-hosted package and optionally offer an update
#'
#' Retrieves version information for a package hosted on GitHub and compares it
#' with the version currently installed locally.
#'
#' This helper keeps the user-facing logic in one place and is written to be
#' easy to test. For that reason, both the installed version and the remote
#' `DESCRIPTION` contents can be injected directly, so tests do not need network
#' access.
#'
#' @param pkg Character scalar in `"owner/repo"` format.
#' @param ref Character scalar indicating the Git ref to inspect. Defaults to
#'   `"main"`.
#' @param description_lines Optional character vector containing the remote
#'   `DESCRIPTION` file. When supplied, no network request is made.
#' @param installed_version Optional installed version string. When supplied, the
#'   local package library is not queried.
#' @param ask Logical scalar indicating whether the user may be prompted to
#'   install or update the package.
#'
#' @return An invisible logical value. `TRUE` means the installed package is at
#'   least as recent as the GitHub version, `FALSE` means GitHub reports a newer
#'   version, and `NA` means that the package is not installed or the remote
#'   version could not be determined.
#' @keywords internal
check_and_update_github <- function(pkg,
                                    ref = "main",
                                    description_lines = NULL,
                                    installed_version = NULL,
                                    ask = interactive()) {
  check <- check_github(pkg = pkg,
                        ref = ref,
                        description_lines = description_lines,
                        installed_version = installed_version)
  package_name <- .github_package_name(pkg)

  if (is.na(check$latest_version)) {
    message("Could not determine the latest version of ", package_name,
            " from GitHub. Please check your GitHub access and try again.")
    return(invisible(NA))
  }

  if (is.na(check$installed_version)) {
    message("The ", package_name, " package is not installed.")
    if (isTRUE(ask)) {
      .offer_github_install(
        repo = pkg,
        dependencies = TRUE,
        question = paste("Do you want me to install", pkg, "?")
      )
    }
    return(invisible(NA))
  }

  if (isTRUE(check$up_to_date)) {
    message("The installed ", package_name, " package is up-to-date.")
    return(invisible(TRUE))
  }

  message("You do not have the latest version of the ", package_name,
          " package.")
  if (isTRUE(ask)) {
    .offer_github_install(
      repo = pkg,
      dependencies = TRUE,
      question = "Do you want me to update sna4tutti?"
    )
  }

  invisible(FALSE)
}





#' Install a GitHub package when `remotes` is available
#'
#' Installs a package from GitHub using [remotes::install_github()]. The helper
#' exists so that the rest of the update logic can degrade gracefully when the
#' optional `remotes` dependency is unavailable.
#'
#' @param repo Character scalar in `"owner/repo"` format.
#' @param dependencies Logical scalar indicating whether dependencies should be
#'   installed as well.
#'
#' @return An invisible logical value. `TRUE` means that the installation call
#'   was started, `FALSE` means that the required `remotes` package was not
#'   available.
#' @keywords internal
install_github_if_available <- function(repo, dependencies = TRUE) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    message("Package 'remotes' is required to install from GitHub.")
    return(invisible(FALSE))
  }

  remotes::install_github(repo = repo, dependencies = dependencies)
  invisible(TRUE)
}





#' Compare a locally installed package version with the GitHub version
#'
#' Reads the remote `DESCRIPTION` file for a GitHub repository and compares its
#' `Version` field with the version installed locally.
#'
#' Version comparison is done with [utils::compareVersion()], not with ordinary
#' string comparison. This avoids incorrect outcomes for versions such as
#' `"0.5.10"` versus `"0.5.9"`.
#'
#' @param pkg Character scalar in `"owner/repo"` format.
#' @param ref Character scalar indicating the Git ref to inspect. Defaults to
#'   `"main"`.
#' @param description_lines Optional character vector containing the remote
#'   `DESCRIPTION` file. When supplied, no network request is made.
#' @param installed_version Optional installed version string. When supplied, the
#'   local package library is not queried.
#'
#' @return A list with elements `package`, `ref`, `installed_version`,
#'   `latest_version`, and `up_to_date`.
#' @keywords internal
check_github <- function(pkg,
                         ref = "main",
                         description_lines = NULL,
                         installed_version = NULL) {
  if (is.null(installed_version)) {
    installed_version <- tryCatch(
      as.character(utils::packageVersion(.github_package_name(pkg))),
      error = function(e) NA_character_
    )
  } else {
    installed_version <- as.character(installed_version)[1L]
  }

  if (is.null(description_lines)) {
    description_lines <- tryCatch(
      readLines(.github_description_url(pkg = pkg, ref = ref), warn = FALSE),
      error = function(e) NULL
    )
  }

  latest_version <- NA_character_
  if (!is.null(description_lines)) {
    latest_version <- .description_field_from_lines(
      lines = description_lines,
      field = "Version"
    )
  }

  result <- list(
    package = pkg,
    ref = ref,
    installed_version = installed_version,
    latest_version = latest_version,
    up_to_date = NA
  )

  if (!is.na(installed_version) && !is.na(latest_version)) {
    # Treat a locally newer development version as current as well.
    result$up_to_date <- utils::compareVersion(installed_version,
                                               latest_version) >= 0
  }

  result
}





#' Prompt the user to install or update a GitHub package
#'
#' Presents a small interactive menu and starts an installation when the user
#' chooses the affirmative option.
#'
#' @param repo Character scalar in `"owner/repo"` format.
#' @param dependencies Logical scalar indicating whether dependencies should be
#'   installed as well.
#' @param question Character scalar shown as the menu title.
#'
#' @return An invisible logical value. `TRUE` means the installation was
#'   started, `FALSE` means it was declined or could not be started.
#' @keywords internal
.offer_github_install <- function(repo, dependencies = TRUE, question) {
  choice <- utils::menu(c("Yes", "No"), title = question)
  if (!identical(choice, 1L)) {
    return(invisible(FALSE))
  }

  install_github_if_available(repo = repo, dependencies = dependencies)
}





#' Construct the raw GitHub URL for a repository `DESCRIPTION` file
#'
#' Builds the URL used by [check_github()] to inspect the package metadata on
#' GitHub without cloning the repository.
#'
#' @param pkg Character scalar in `"owner/repo"` format.
#' @param ref Character scalar indicating the Git ref to inspect.
#'
#' @return A character scalar containing the raw GitHub URL.
#' @keywords internal
.github_description_url <- function(pkg, ref) {
  paste0("https://raw.githubusercontent.com/", pkg, "/", ref, "/DESCRIPTION")
}





#' Extract a field value from `DESCRIPTION` lines
#'
#' Parses a `DESCRIPTION` file that has already been read into memory and returns
#' the requested field as a single character string.
#'
#' Continuation lines are supported, so the helper also works for fields that
#' span multiple lines.
#'
#' @param lines Character vector containing the `DESCRIPTION` contents.
#' @param field Character scalar naming the field to extract.
#'
#' @return A character scalar, or `NA_character_` when the field is absent.
#' @keywords internal
.description_field_from_lines <- function(lines, field) {
  pattern <- paste0("^", field, ":\\s*")
  index <- grep(pattern, lines)
  if (length(index) == 0) {
    return(NA_character_)
  }

  index <- index[1L]
  value <- sub(pattern, "", lines[index])
  if (index == length(lines)) {
    return(trimws(value))
  }

  continuation_index <- integer(0)
  for (candidate in seq.int(index + 1L, length(lines))) {
    if (!grepl("^[[:space:]]", lines[candidate])) {
      break
    }
    continuation_index <- c(continuation_index, candidate)
  }

  continuation <- lines[continuation_index]
  if (length(continuation) == 0) {
    return(trimws(value))
  }

  trimws(paste(c(value, trimws(continuation)), collapse = " "))
}





#' Extract the package name from an `"owner/repo"` specification
#'
#' Converts a GitHub repository specification such as `"SNAnalyst/sna4tutti"`
#' into the package name `"sna4tutti"`.
#'
#' @param pkg Character scalar in `"owner/repo"` format.
#'
#' @return A character scalar containing the repository name.
#' @keywords internal
.github_package_name <- function(pkg) {
  sub(".*/", "", pkg)
}
