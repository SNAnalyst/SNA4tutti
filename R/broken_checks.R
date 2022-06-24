#' Within tutorial sna4tutti unit test error report function
#'
#'
#' This function prints an error message in case of broken code chunk and it
#' reports the name of the broken code box
#'
#' @return nothing relevant, this function is useful for its side effect.
#' @export
#'
#' @examples
#' \dontrun{
#' broken_info()
#' }
broken_info <- function(broken_list = list() ) {
  lab <- knitr::opts_current$get(name = "label")
  broken_list <<- append(broken_list, lab)
  cat("=========================================\n")
  cat(">>> Codebox \'", lab , "\' is broken \n")
  cat("please contact the maintainers! <<<\n")
  cat("=========================================\n")
}
