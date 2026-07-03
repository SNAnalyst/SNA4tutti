pkgname <- "sna4tutti"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('sna4tutti')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("broken_info")
### * broken_info

flush(stderr()); flush(stdout())

### Name: broken_info
### Title: Report which hidden tutorial chunk failed
### Aliases: broken_info

### ** Examples

## Not run: 
##D broken_info()
## End(Not run)




cleanEx()
nameEx("check_packages")
### * check_packages

flush(stderr()); flush(stdout())

### Name: check_packages
### Title: Check for presence of packages
### Aliases: check_packages
### Keywords: internal

### ** Examples

## Not run: 
##D check_packages()
## End(Not run)



cleanEx()
nameEx("check_sna4tutti")
### * check_sna4tutti

flush(stderr()); flush(stdout())

### Name: check_sna4tutti
### Title: Check whether the installed 'sna4tutti' package is current on
###   GitHub
### Aliases: check_sna4tutti

### ** Examples

## Not run: 
##D check_sna4tutti()
## End(Not run)



cleanEx()
nameEx("open_sna4tutti_tutorials")
### * open_sna4tutti_tutorials

flush(stderr()); flush(stdout())

### Name: open_sna4tutti_tutorials
### Title: Pick a tutorial
### Aliases: open_sna4tutti_tutorials

### ** Examples

## Not run: 
##D open_sna4tutti_tutorials()
## End(Not run)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
