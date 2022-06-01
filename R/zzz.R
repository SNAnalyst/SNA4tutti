

.onLoad <- function(libname, pkgname) {
  op <- options()
  invisible()
}


.onAttach <- function(lib, pkg,...){
  print_message <-  paste("\n",
                          "Welcome to sna4tutti version ", utils::packageDescription("sna4tutti")$Version,
                          "\n",
                          "Type ?sna4tutti to access the package documentation\n\n",
                          "To suppress this message use:\n",
                          "\tsuppressPackageStartupMessages(library(sna4tutti))\n\n",
                          "You can check if you have the latest version with 'check_sna4tutti()'\n",
                          sep = "")
  packageStartupMessage(print_message)
}


