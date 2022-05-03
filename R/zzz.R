

.onLoad <- function(libname, pkgname) {
  op <- options()
  invisible()
}


.onAttach <- function(lib, pkg,...){
  print_message <-  paste("\n",
                          "Welcome to SNA4tutti version ", utils::packageDescription("SNA4tutti")$Version,
                          "\n",
                          "Type ?SNA4tutti to access the package documentation\n\n",
                          "To suppress this message use:\n",
                          "\tsuppressPackageStartupMessages(library(SNA4tutti))\n\n",
                          "You can check if you have the latest version with 'check_SNA4tutti()'\n",
                          sep = "")
  packageStartupMessage(print_message)
}


