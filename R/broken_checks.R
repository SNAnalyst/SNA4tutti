#' Within tutorial sna4tutti unit test error report function
#'
#'
#' This function prints an error message in case of broken code chunk and it
#' reports the name of the broken code box
#' @param broken_list internal parameter to fetch the name of the code box with broken code
#'
#' @return nothing relevant, this function is useful for its side effect.
#'
#'
#' @examples
#' \dontrun{
#' broken_info()
#' }
#'
#'
#' @export
broken_info <- function(broken_list = l ) {
  l <- list()
  lab <- knitr::opts_current$get(name = "label")
  broken_list <<- append(broken_list, lab)
  cat("==========================================================================\n")
  cat(">>> Codebox \'", lab , "\' is broken. Please, contact the maintainers! <<<\n")
  cat("==========================================================================")
}
