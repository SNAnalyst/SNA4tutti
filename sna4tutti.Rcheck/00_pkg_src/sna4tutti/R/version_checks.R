
#' Check for presence of packages
#'
#' Checks whether a set of packages is present and of the correct version.
#'
#' Useful inside a learnr tutorial.
#'
#' By default, the requirements are read from the installed package
#' \code{DESCRIPTION} file, so package version requirements only need to be
#' maintained in one place.
#'
#' If supplied, \code{reqs} must be a data.frame with column names
#' \code{"pkg"}, \code{"version"}, and \code{"where"}. All items are
#' \code{character}!
#'
#' \describe{
#'   \item{pkg}{name of the package}
#'   \item{version}{minimum required version, or an empty string if no minimum
#'     is enforced}
#'   \item{where}{download source, either \code{"CRAN"} or a GitHub
#'     \code{"owner/repo"} reference}
#' }
#'
#' If \code{attempt_install = TRUE}, the function tries to install or update
#' missing packages before reporting any remaining issues. The default is
#' \code{FALSE}, which is safer for locked-down teaching environments.
#'
#' If a package is still not installed, a message is returned that tells the user
#' how to install it manually. If a package still does not at least have the
#' required version, a message is returned that tells the user how to upgrade it
#' manually.
#'
#' @param reqs optional data.frame (see details)
#' @param attempt_install logical, should missing or outdated packages be
#'   installed automatically before reporting the result?
#'
#' @return character string, summarizing the results
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' check_packages()
#' }
check_packages <- function(reqs = tutorial_package_requirements(),
                           attempt_install = FALSE) {
  reqs <- as.data.frame(reqs, stringsAsFactors = FALSE)
  needed <- c("pkg", "version", "where")

  if (!all(needed %in% names(reqs))) {
    stop("`reqs` must contain columns named 'pkg', 'version', and 'where'.")
  }

  reqs <- reqs[, needed]
  reqs$version[is.na(reqs$version)] <- ""
  reqs$where[is.na(reqs$where)] <- "CRAN"

  if (attempt_install) {
    cat("...checking and attempting to install required packages now...\n")
    for (pak in seq_len(nrow(reqs))) {
      if (.package_requirement_problem(reqs[pak, , drop = FALSE])) {
        .install_required_package(reqs[pak, , drop = FALSE])
      }
    }
  } else {
    cat("...checking required packages now...\n")
  }

  pkg_missing <- NULL
  pkg_low <- NULL
  all_installed <- utils::installed.packages()

  for (pak in seq_len(nrow(reqs))) {
    installed <- unname(which(all_installed[, "Package"] == reqs[pak, "pkg"]))
    if (length(installed) == 0) {
      pkg_missing <- c(pkg_missing, pak)
      next
    }

    if (!.version_is_at_least(all_installed[installed, "Version"],
                              reqs[pak, "version"])) {
      pkg_low <- c(pkg_low, pak)
    }
  }

  if (is.null(pkg_missing) && is.null(pkg_low)) {
    verdict <- "Wonderful, all is fine."
    if (attempt_install) {
      verdict <- "Deficiencies have been fixed, all is fine now."
    }
    return(verdict)
  }

  verdict <- character(0)

  if (!is.null(pkg_missing)) {
    names_missing <- paste0("'", reqs[pkg_missing, "pkg"], "'", collapse = ", ")
    verdict <- c(verdict,
                 paste0("The following packages are missing: ", names_missing),
                 "Install these using:")
    verdict <- c(verdict, .install_commands(reqs[pkg_missing, , drop = FALSE]))
  }

  if (!is.null(pkg_low)) {
    names_low <- paste0("'", reqs[pkg_low, "pkg"], "'", collapse = ", ")
    verdict <- c(verdict,
                 "",
                 paste0("The version of the following packages is too low: ", names_low),
                 "Reinstall or upgrade these using:")
    verdict <- c(verdict, .install_commands(reqs[pkg_low, , drop = FALSE]))
  }

  noquote(verdict)
}

.package_description_field <- function(field, package = "sna4tutti") {
  value <- utils::packageDescription(package, fields = field)
  if (length(value) == 0) {
    return(NA_character_)
  }

  value <- unname(value[[1]])
  if (is.null(value) || is.na(value) || !nzchar(value)) {
    return(NA_character_)
  }

  value
}

.parse_dependency_field <- function(field, package = "sna4tutti") {
  value <- .package_description_field(field = field, package = package)
  if (is.na(value)) {
    return(data.frame(pkg = character(0),
                      version = character(0),
                      stringsAsFactors = FALSE))
  }

  entries <- trimws(unlist(strsplit(value, ",")))
  entries <- entries[nzchar(entries)]

  rows <- lapply(entries, function(entry) {
    match <- regexec("^([A-Za-z][A-Za-z0-9.]*)\\s*(?:\\(>=\\s*([^\\)]+)\\))?$",
                     entry)
    parsed <- regmatches(entry, match)[[1]]
    if (length(parsed) == 0) {
      stop("Could not parse dependency entry: ", entry)
    }

    version <- ""
    if (length(parsed) >= 3 && !is.na(parsed[3])) {
      version <- parsed[3]
    }

    data.frame(pkg = parsed[2],
               version = version,
               stringsAsFactors = FALSE)
  })

  do.call(rbind, rows)
}

.parse_remote_field <- function(package = "sna4tutti") {
  value <- .package_description_field(field = "Remotes", package = package)
  if (is.na(value)) {
    return(data.frame(pkg = character(0),
                      where = character(0),
                      stringsAsFactors = FALSE))
  }

  entries <- trimws(unlist(strsplit(value, ",")))
  entries <- entries[nzchar(entries)]

  rows <- lapply(entries, function(entry) {
    remote <- sub("^[^:]+::", "", entry)
    repo <- basename(remote)
    repo <- sub("@.*$", "", repo)
    data.frame(pkg = repo, where = remote, stringsAsFactors = FALSE)
  })

  do.call(rbind, rows)
}

tutorial_package_requirements <- function(package = "sna4tutti",
                                          fields = "Imports",
                                          packages = NULL) {
  reqs <- do.call(
    rbind,
    lapply(fields, function(field) {
      .parse_dependency_field(field = field, package = package)
    })
  )

  if (is.null(reqs) || nrow(reqs) == 0) {
    return(data.frame(pkg = character(0),
                      version = character(0),
                      where = character(0),
                      stringsAsFactors = FALSE))
  }

  reqs <- unique(reqs)
  reqs$where <- "CRAN"

  remotes <- .parse_remote_field(package = package)
  if (nrow(remotes) > 0) {
    for (idx in seq_len(nrow(remotes))) {
      hit <- reqs$pkg == remotes$pkg[idx]
      reqs$where[hit] <- remotes$where[idx]
    }
  }

  if (!is.null(packages)) {
    reqs <- reqs[reqs$pkg %in% packages, , drop = FALSE]
  }

  reqs[order(reqs$pkg), c("pkg", "version", "where")]
}

.minimum_r_version <- function(package = "sna4tutti") {
  depends <- .parse_dependency_field(field = "Depends", package = package)
  depends <- depends[depends$pkg == "R", , drop = FALSE]

  if (nrow(depends) == 0 || !nzchar(depends$version[1])) {
    stop("No minimum R version found in DESCRIPTION Depends field.")
  }

  depends$version[1]
}

.minimum_rstudio_version <- function(package = "sna4tutti") {
  version <- .package_description_field(field = "Config/sna4tutti/min-rstudio",
                                        package = package)
  if (is.na(version)) {
    stop("No minimum RStudio version found in DESCRIPTION.")
  }

  version
}

.current_rstudio_version <- function() {
  if (rstudioapi::isAvailable(child_ok = TRUE)) {
    version <- tryCatch(rstudioapi::versionInfo()$version,
                        error = function(e) NULL)
    if (!is.null(version) && nzchar(as.character(version))) {
      return(as.character(version))
    }
  }

  version <- Sys.getenv("RSTUDIO_VERSION", unset = "")
  if (nzchar(version)) {
    return(version)
  }

  NA_character_
}

.normalize_version <- function(version, n = NULL) {
  version <- sub("\\+.*$", "", as.character(version))
  parts <- strsplit(version, ".", fixed = TRUE)[[1]]

  if (!is.null(n)) {
    parts <- parts[seq_len(min(length(parts), n))]
  }

  paste(parts, collapse = ".")
}

.version_is_at_least <- function(installed, required) {
  if (is.na(required) || !nzchar(required)) {
    return(TRUE)
  }

  utils::compareVersion(.normalize_version(installed),
                        .normalize_version(required)) >= 0
}

.version_is_equal <- function(installed, required) {
  parts <- length(strsplit(required, ".", fixed = TRUE)[[1]])
  utils::compareVersion(.normalize_version(installed, n = parts),
                        .normalize_version(required, n = parts)) == 0
}

.package_requirement_problem <- function(req) {
  all_installed <- utils::installed.packages()
  installed <- unname(which(all_installed[, "Package"] == req[1, "pkg"]))
  if (length(installed) == 0) {
    return(TRUE)
  }

  !.version_is_at_least(all_installed[installed, "Version"], req[1, "version"])
}

.install_required_package <- function(req) {
  if (req[1, "where"] == "CRAN") {
    try(utils::install.packages(req[1, "pkg"], dependencies = TRUE), silent = TRUE)
  } else {
    cat("...attempting to download a package from github...\n")
    if (!requireNamespace("remotes", quietly = TRUE)) {
      return(invisible(FALSE))
    }
    try(remotes::install_github(req[1, "where"], dependencies = TRUE), silent = TRUE)
  }
}

.install_commands <- function(reqs) {
  unlist(lapply(seq_len(nrow(reqs)), function(idx) {
    if (reqs[idx, "where"] == "CRAN") {
      glue::glue("     install.packages('{reqs[idx, 'pkg']}')")
    } else {
      glue::glue("     remotes::install_github('{reqs[idx, 'where']}')")
    }
  }), use.names = FALSE)
}







#' Check for correct version of R or RStudio
#'
#' Check for correct version of R or RStudio
#'
#' Checks whether the user is using the correct version of RStudio or R
#'
#' The result is a logical (\code{TRUE} or \code{FALSE}), which is returned
#' invisibly.
#'
#' If required, a verdict can be printed to the console as well (when \code{verdict = TRUE})
#'
#' The functions \code{check_rstudio_equal} and \code{check_r_equal} check
#' whether RStudio or R have the exact version asked for.
#'
#' The functions \code{check_rstudio_equal_or_larger} and \code{check_r_equal_or_larger} check
#' whether RStudio or R have at least the version asked for (having a higher version is fine).
#'
#' When \code{version = NULL}, the requirement is read from the installed
#' package \code{DESCRIPTION} file.
#'
#' @param version required version number to test against
#' @param verdict logical, whether a text with the verdict needs to be printed
#'   to the console
#'
#' @return logical (invisibly) and, if asked for, a printed verdict
#' @keywords internal
#' @name version_check
NULL


#' @describeIn  version_check
#' @export
check_rstudio_equal <- function(version = NULL, verdict = TRUE) {
  if (is.null(version)) {
    version <- .minimum_rstudio_version()
  }

  ver <- .current_rstudio_version()
  if (is.na(ver)) {
    if (verdict) cat("RStudio is not available in this session")
    return(invisible(FALSE))
  }

  if (.version_is_equal(ver, version)) {
    if (verdict) cat("Your version of RStudio is perfectly fine")
    invisible(TRUE)
  } else {
    if (verdict) cat(paste0("You need to upgrade your RStudio version to ", version))
    invisible(FALSE)
  }
}


#' @describeIn  version_check
#' @export
check_r_equal <- function(version = NULL, verdict = TRUE) {
  if (is.null(version)) {
    version <- .minimum_r_version()
  }

  major_r <- R.Version()$major
  minor_r <- R.Version()$minor
  ver <- paste0(major_r, ".", minor_r)
  if (.version_is_equal(ver, version)) {
    if (verdict) cat("Your version of R is exactly right")
    invisible(TRUE)
  } else {
    if (verdict) cat(paste0("You need to upgrade your R version to at least ", version))
    invisible(FALSE)
  }
}





#' @describeIn  version_check
#' @export
check_rstudio_equal_or_larger <- function(version = NULL, verdict = TRUE) {
  if (is.null(version)) {
    version <- .minimum_rstudio_version()
  }

  ver <- .current_rstudio_version()
  if (is.na(ver)) {
    if (verdict) cat("RStudio is not available in this session")
    return(invisible(FALSE))
  }

  if (.version_is_at_least(ver, version)) {
    if (verdict) cat("Your version of RStudio is fine")
    invisible(TRUE)
  } else {
    if (verdict) cat(paste0("You need to upgrade your RStudio version to at least ", version))
    invisible(FALSE)
  }
}


#' @describeIn  version_check
#' @export
check_r_equal_or_larger <- function(version = NULL, verdict = TRUE) {
  if (is.null(version)) {
    version <- .minimum_r_version()
  }

  major_r <- R.Version()$major
  minor_r <- R.Version()$minor
  ver <- paste0(major_r, ".", minor_r)
  if (.version_is_at_least(ver, version)) {
    if (verdict) cat("Your version of R is fine")
    invisible(TRUE)
  } else {
    if (verdict) cat(paste0("You need to upgrade your R version to at least ", version))
    invisible(FALSE)
  }
}
