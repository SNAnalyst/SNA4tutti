#' Pick a tutorial
#'
#' Pick a tutorial from the sna4tutti package
#'
#' Shows a list of currently available tutorials in the #' \code{sna4tutti} package.
#' The user can pick the preferred tutorial by entering the number that corresponds
#' to the preferred tutorial. The tutorial will then open in the user's default
#' web browser.
#'
#' When \code{graphics} is \code{TRUE}, a graphical choice menu is shown. If that
#' is not preferred, or if the user's machine lacks the graphical tools needed,
#' setting \code{graphics} to \code{FALSE} will show the list of tutorials in the
#' R console.
#'
#' @param graphics logical, should the list of options be shown as a clickable
#' graphical menu?
#'
#' @return nothing
#' @export
#' @examples
#' \dontrun{
#' open_sna4tutti_tutorials()
#' }
open_sna4tutti_tutorials <- function(graphics = TRUE) {
  if (!is.logical(graphics)) stop("You need to set 'graphics' to TRUE or FALSE only (without parentheses)")
  all_tuts <- learnr::available_tutorials("sna4tutti")
  # perform <- glue::glue("learnr::run_tutorial('{tuto}', package = 'sna4tutti')",
  #                       tuto = all_tuts$name)
  perform <- paste0("learnr::run_tutorial('", all_tuts$name, "', package = 'sna4tutti')")

  cat("\n\nPlease pick which tutorial you want to run, it will open in your default browser.\n")
  cat("The following tutorials are currently available to pick from:\n")
  pick <- utils::menu(all_tuts$title, graphics = graphics)
  eval(parse(text = perform[pick], keep.source = FALSE), envir = .GlobalEnv)
  # glue::identity_transformer(perform[pick], .GlobalEnv)
  invisible()
}

