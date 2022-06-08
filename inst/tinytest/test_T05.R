############################# tests T05 ########################################

## test "r 07nonNetPlot" line 192

# test 5-1 (numeration is important for the final check with tinytest::test_all)

x <- 1:10
y1 <- x*x
y2  <- 2*y1

expect_equal(y2, c(2, 8, 18, 32, 50, 72, 98, 128, 162, 200))

# test "r testquiz" line 258

# test 5-2 test on quiz() output
q1 <- quiz(question("What is the main problem with the plots of igraphNet and networkNet?",
                    answer("nodes are too small"),
                    answer("the colors are not color blind friendly"),
                    answer("the plot does not inform us on what the network represents", correct = TRUE),
                    correct = "Yes! Well done!",
                    random_answer_order = TRUE,
                    allow_retry = TRUE
)
)


expect_true(q1$questions[[1]]$question == "What is the main problem with the plots of igraphNet and networkNet?")


# test 5-3 testing correct answer on question() structure
q1in <- question("What is the main problem with the plots of igraphNet and networkNet?",
                 answer("nodes are too small"),
                 answer("the colors are not color blind friendly"),
                 answer("the plot does not inform us on what the network represents", correct = TRUE)
                 )

expect_true(q1in$answers[[3]]$correct)


"✔: \"the plot does not inform us on what the network represents\"" == q1in$answers[[3]]
# test "r dataload" line 280

## test 5-4 test that data name is properly loaded (implicitly checking for number of nodes)

net <- SNA4DSData::DSstudents

expect_equal(igraph::V(net)$name, c(paste0("S", 1:81)))


## test 5-5 test that the attribute "year" is properly loaded (implicitly checking for number of nodes)

expect_equal(as.vector(table(igraph::V(net)$year)), c(54, 19, 8))


## test 5-6 test that the attribute "Hang.Out" is properly loaded (implicitly checking for number of nodes)

expect_equal(as.vector(table(igraph::V(net)$Hang.Out)), c(3, 16, 31, 18, 13))


## test 5-7 test that the attribute "gender" is properly loaded (implicitly checking for number of nodes)

expect_equal(as.vector(table(igraph::V(net)$gender)), c(30, 51))

## test 5-8 test that the attribute "frequency" is properly loaded (implicitly checking for number of edges)

expect_equal(as.vector(table(igraph::E(net)$frequency)), c(28, 37, 32, 38, 15))

## test 5-9 test that the attribute "closeness" is properly loaded (implicitly checking for number of edges)

expect_equal(as.vector(table(igraph::E(net)$closeness)), c(60, 52, 34, 3, 1))


# test "r quiz_viz1" line 405

## test 5-10
q2 <- quiz(
  question("How do you interpret this visualization?",
           answer("The year matters for friednship formation but the gender does not"),
           answer("Both matter, but since there are many more males the year is a better predictor of friendship", correct = TRUE),
           answer("The year does not matter for friendship formation but the gender does"),
           answer("Both the year and the gender equally matter in predicting friendship"),
           correct = "Yes! Well done!",
           random_answer_order = TRUE,
           allow_retry = TRUE
  )
)


