# These tests focus on small runtime helpers that used to be hard to validate
# because they depended on interactive state. A light refactor makes them
# deterministic enough to protect with tinytest.

if (!"tinytest_expectations" %in% base::search()) {
  base::attach(base::asNamespace("tinytest"), name = "tinytest_expectations")
}

pkg_namespace <- base::getNamespace("sna4tutti")

open_selected_tutorial <- base::get(
  ".open_selected_tutorial",
  envir = pkg_namespace,
  inherits = FALSE
)

tutorials <- base::data.frame(
  name = c("intro", "ergm"),
  title = c("Introduction", "ERGMs"),
  stringsAsFactors = FALSE
)

menu_record <- list()
run_record <- list()

selection_result <- NULL
selection_output <- utils::capture.output(
  selection_result <- open_selected_tutorial(
    tutorials = tutorials,
    graphics = FALSE,
    menu_fun = function(choices, graphics) {
      menu_record$choices <<- choices
      menu_record$graphics <<- graphics
      2L
    },
    run_fun = function(name, package) {
      run_record$name <<- name
      run_record$package <<- package
      base::invisible(NULL)
    }
  )
)

expect_identical(menu_record$choices, tutorials$title)
expect_false(menu_record$graphics)
expect_identical(run_record$name, "ergm")
expect_identical(run_record$package, "sna4tutti")
expect_identical(selection_result, "ergm")
expect_true(base::length(selection_output) >= 2L)

# The helper returns the selected tutorial name invisibly; we check that by
# calling it again without capture so the return value stays available.
expect_identical(
  open_selected_tutorial(
    tutorials = tutorials,
    graphics = TRUE,
    menu_fun = function(choices, graphics) 1L,
    run_fun = function(name, package) base::invisible(NULL)
  ),
  "intro"
)

expect_identical(
  open_selected_tutorial(
    tutorials = tutorials,
    graphics = TRUE,
    menu_fun = function(choices, graphics) 0L,
    run_fun = function(name, package) {
      base::stop("Cancelled selections should not launch a tutorial.")
    }
  ),
  NULL
)

expect_error(
  open_selected_tutorial(
    tutorials = tutorials,
    graphics = "yes",
    menu_fun = function(choices, graphics) 1L,
    run_fun = function(name, package) base::invisible(NULL)
  ),
  pattern = "TRUE or FALSE"
)

expect_error(
  open_selected_tutorial(
    tutorials = tutorials,
    graphics = TRUE,
    menu_fun = function(choices, graphics) 3L,
    run_fun = function(name, package) base::invisible(NULL)
  ),
  pattern = "out of range"
)

expect_error(
  open_selected_tutorial(
    tutorials = tutorials[0, , drop = FALSE],
    graphics = TRUE,
    menu_fun = function(choices, graphics) 1L,
    run_fun = function(name, package) base::invisible(NULL)
  ),
  pattern = "No tutorials"
)

old_label <- knitr::opts_current$get("label")
base::on.exit({
  knitr::opts_current$set(label = old_label)
}, add = TRUE)

knitr::opts_current$set(label = "tinytest_chunk")

broken_output <- utils::capture.output(
  broken_label <- sna4tutti::broken_info()
)

expect_identical(broken_label, "tinytest_chunk")
expect_true(
  base::any(grepl("Codebox 'tinytest_chunk' is broken", broken_output, fixed = TRUE))
)

expect_identical(sna4tutti:::solve_imports(), NULL)
