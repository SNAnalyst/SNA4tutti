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
  tutorials <- learnr::available_tutorials("sna4tutti")
  .open_selected_tutorial(tutorials = tutorials, graphics = graphics)
  base::invisible()
}

#' Open one selected tutorial from a tutorial table
#'
#' This helper isolates the interactive selection logic from the exported
#' launcher so we can test it without starting a real browser session. The
#' public API still stays simple, while tests can inject a fake menu and a fake
#' tutorial runner.
#'
#' @param tutorials data.frame returned by \code{learnr::available_tutorials()}
#' @param graphics logical, should \code{utils::menu()} use the graphical menu?
#' @param menu_fun function used to collect the user's selection
#' @param run_fun function used to launch the selected tutorial
#'
#' @return invisibly returns the selected tutorial name, or \code{NULL} when
#'   the user cancels the menu
#' @keywords internal
#' @noRd
.open_selected_tutorial <- function(tutorials,
                                    graphics = TRUE,
                                    menu_fun = utils::menu,
                                    run_fun = learnr::run_tutorial) {
  if (!base::is.logical(graphics) || base::length(graphics) != 1L || base::is.na(graphics)) {
    base::stop("You need to set 'graphics' to TRUE or FALSE only (without parentheses)")
  }

  if (base::NROW(tutorials) == 0L) {
    base::stop("No tutorials are currently available in package 'sna4tutti'.")
  }

  base::cat("\n\nPlease pick which tutorial you want to run, it will open in your default browser.\n")
  base::cat("The following tutorials are currently available to pick from:\n")

  pick <- menu_fun(tutorials$title, graphics = graphics)

  # A menu choice of 0 means that the user cancelled. Returning NULL keeps this
  # branch explicit and avoids the brittle parse/eval logic that used to live
  # here.
  if (pick == 0L) {
    return(base::invisible(NULL))
  }

  if (!pick %in% base::seq_len(base::NROW(tutorials))) {
    base::stop("Tutorial selection is out of range.")
  }

  tutorial_name <- tutorials$name[[pick]]
  run_fun(tutorial_name, package = "sna4tutti")

  base::invisible(tutorial_name)
}

