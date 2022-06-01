library(shinytest)

  # Don't run these tests on the CRAN build servers
  # skip_on_cran() ADAPT TO TINYTEST

  # Use compareImages=FALSE because the expected image screenshots were created
  # on a Mac, and they will differ from screenshots taken on the CI platform,
  # which runs on Linux.

  appdir <- system.file("tutorials/T01_IntroR", package = "sna4tutti")
  # expect_pass(testApp(appdir, compareImages = FALSE)) ADAPT TO TINYTEST

