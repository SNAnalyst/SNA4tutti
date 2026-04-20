#' Report which hidden tutorial chunk failed
#'
#' Hidden validation chunks inside the tutorials use this helper when a data
#' object or intermediate result no longer matches the expected value. The
#' function prints a highly visible message that includes the current chunk
#' label, so maintainers can trace the failing tutorial step quickly.
#'
#' The \code{broken_list} argument is kept only for backward compatibility with
#' older chunk code. The tutorials already manage their own \code{errors}
#' collection, so this helper only reports the failing label and returns it
#' invisibly for tests.
#'
#' @param broken_list deprecated compatibility argument. It is ignored.
#'
#' @return invisibly returns the current chunk label
#'
#' @examples
#' \dontrun{
#' broken_info()
#' }
#'
#' @export
broken_info <- function(broken_list = NULL) {
  lab <- knitr::opts_current$get(name = "label")

  # The chunk label is the most useful diagnostic because it maps directly back
  # to the tutorial source. Returning it invisibly gives us a stable value for
  # automated tests without changing the user-facing behavior.
  base::cat("==========================================================================\n")
  base::cat(">>> Codebox '", lab, "' is broken. Please, contact the maintainers! <<<\n",
            sep = "")
  base::cat("==========================================================================")
  base::invisible(lab)
}
