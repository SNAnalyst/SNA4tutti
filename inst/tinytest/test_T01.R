
############################# tests T01 ########################################

## test "r grade_code4" line 280

# test 1-1 (numeration is important for the final check with tinytest::test_all)
a <- 3
b <- 5
expect_false(isTRUE(a == b))

# test 1-2 (numeration is important for the final check with tinytest::test_all)
expect_false(isFALSE((a + b) == 8))

## test "try_something13" and "grade_code5" lines 601 - 640

# test 1-3 (numeration is important for the final check with tinytest::test_all)

grades <- c('mildly spicy', 'mildly spicy', 'very spicy', 'a bit spicy', 'Waw! Fire!',
'not spicy', 'very spicy', 'mildly spicy', 'a bit spicy', 'a bit spicy')


grades <- as.factor(grades)

levels(grades)<- c("not spicy", "a bit spicy", "mildly spicy", "very spicy", "Waw! Fire!")

expect_equal((c("not spicy", "a bit spicy", "mildly spicy", "very spicy", "Waw! Fire!") == levels(grades)), c(TRUE, TRUE, TRUE, TRUE, TRUE))

# test 1-4 (numeration is important for the final check with tinytest::test_all)

cont <- attributes(grades)

expect_equal(cont$class, "factor")

############################# tests T02 ########################################
