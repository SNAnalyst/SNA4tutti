

# test "r grade_code4" line 280
a <- 3
b <- 5

tinytest::expect_false(isTRUE(a == b))
tinytest::expect_false(isFALSE((a + b) == 8))
