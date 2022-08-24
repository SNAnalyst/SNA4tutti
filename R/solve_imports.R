

# This is a hack to make the warnings disappear for packages that are used 
# inside chunks. For these packages, the 'check' function does not understand 
# that they are required, and hence complains about them being mentioned in 
# the "Imports" section of the NAMESPACE.
# The hack is simple: just call the packages here, once, so they are indeed 
# used outside of a chunk.
solve_imports <- function() {
  hack <- ergm::logLikNull
  hack <- gradethis::code_feedback
  hack <- igraph::add.edges
  hack <- learnr::answer
  hack <- network::add.edge
  hack <- tsna::as.network.tPath
  rm(hack)
}

