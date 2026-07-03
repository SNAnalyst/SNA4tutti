# These tests translate the hidden tutorial smoke checks into package-level
# regressions. They are intentionally concrete: if an upstream dependency or
# bundled data object changes, we want the failure to point directly at the
# teaching material that will drift.

if (!"tinytest_expectations" %in% base::search()) {
  base::attach(base::asNamespace("tinytest"), name = "tinytest_expectations")
}

# T02: classic Florentine and bipartite examples used throughout the basics.
data("florentine", package = "snafun")
flobus <- florentine$flobusiness

expect_equal(snafun::count_vertices(flobus), 16)
expect_equal(snafun::count_edges(flobus), 15)

data("judge_net_bp", package = "SNA4DSData")
judges <- judge_net_bp
judge_matrix <- snafun::to_matrix(judges)

expect_true(snafun::is_bipartite(judges))
expect_true(base::is.matrix(judge_matrix))
expect_false(base::isSymmetric(judge_matrix))

# T05: the visualization tutorial depends on the DSstudents object being stable.
students <- SNA4DSData::DSstudents

expect_equal(igraph::vcount(students), 81)
expect_identical(
  igraph::V(students)$name,
  paste0("S", base::seq_len(81))
)
expect_identical(
  base::as.integer(base::table(igraph::V(students)$year)),
  c(54L, 19L, 8L)
)
expect_identical(
  base::as.integer(base::table(igraph::V(students)$`Hang.Out`)),
  c(3L, 16L, 31L, 18L, 13L)
)
expect_identical(
  base::as.integer(base::table(igraph::V(students)$gender)),
  c(30L, 51L)
)
expect_identical(
  base::as.integer(base::table(igraph::E(students)$frequency)),
  c(27L, 36L, 32L, 38L, 15L)
)
expect_identical(
  base::as.integer(base::table(igraph::E(students)$closeness)),
  c(58L, 52L, 34L, 3L, 1L)
)

# T06: converting Florentine marriage data through snafun must preserve the
# attributes the ERGM tutorials rely on.
florentine_data <- SNA4DSData::florentine
flo_mar <- florentine_data$flomarriage
florentine_network <- snafun::to_network(flo_mar)

expect_equal(network::network.size(florentine_network), 16)
expect_identical(
  network::get.vertex.attribute(florentine_network, "vertex.names"),
  c(
    "Acciaiuoli", "Albizzi", "Barbadori", "Bischeri", "Castellani",
    "Ginori", "Guadagni", "Lamberteschi", "Medici", "Pazzi",
    "Peruzzi", "Pucci", "Ridolfi", "Salviati", "Strozzi",
    "Tornabuoni"
  )
)
expect_identical(
  network::get.vertex.attribute(florentine_network, "NumberPriorates")[2],
  65
)
expect_equal(
  base::unname(network::get.vertex.attribute(florentine_network, "NumberTies")[16]),
  7
)
expect_equal(
  base::unname(network::get.vertex.attribute(florentine_network, "Wealth")[9]),
  103
)
expect_identical(
  base::length(network::get.edge.attribute(florentine_network, "weight")),
  20L
)
expect_equal(network::network.edgecount(florentine_network), 20)

# T07: faux.mesa.high is the canonical nodal-attribute example.
data("faux.mesa.high", package = "ergm")
mesa <- faux.mesa.high

expect_identical(
  base::sum(network::get.vertex.attribute(mesa, "Grade")),
  1790
)
expect_identical(
  base::as.integer(base::table(network::get.vertex.attribute(mesa, "Race"))),
  c(6L, 109L, 68L, 4L, 18L)
)
expect_identical(
  base::as.integer(base::table(network::get.vertex.attribute(mesa, "Sex"))),
  c(99L, 106L)
)

# T08 bipartite setup: the hand-built teaching example should not drift.
mdata <- matrix(
  c(
    1, 1, 1, 1, 1, 0, 0, 1, 0, 0,
    1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    1, 0, 1, 0, 0, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 1, 1, 1, 1, 1, 1
  ),
  10,
  4
)
kidsnet <- network::network(mdata, directed = FALSE, bipartite = TRUE)

expect_equal(
  base::sum(network::get.vertex.attribute(kidsnet, "vertex.names")),
  105
)

vertex_names <- c(LETTERS[1:10], 1:4)
age <- c(6, 7, 7, 7, 9, 9, 10, 9, 12, 12, NA, NA, NA, NA)
gender <- base::as.character(c(0, 0, 0, 0, 0, 1, 1, 1, 1, 1, NA, NA, NA, NA))

network::set.vertex.attribute(kidsnet, "vertex.names", vertex_names)
network::set.vertex.attribute(kidsnet, "Age", age)
network::set.vertex.attribute(kidsnet, "Gender", gender)

expect_identical(
  network::get.vertex.attribute(kidsnet, "vertex.names")[c(1, 4)],
  c("A", "D")
)
expect_identical(
  network::get.vertex.attribute(kidsnet, "Age")[c(3, 7)],
  c(7, 10)
)
expect_identical(
  network::get.vertex.attribute(kidsnet, "Gender")[c(1, 8)],
  c("0", "1")
)
expect_identical(
  base::as.integer(base::table(sna::degree(kidsnet, gmode = "graph"))),
  c(5L, 4L, 1L, 2L, 2L)
)

# T08 weighted GERGM data: fixed spot checks are enough to catch broken data
# loads without making the test suite expensive.
data("lending_2005", package = "GERGM")
expect_equal(
  base::round(lending_2005[cbind(c(2, 3, 4, 5, 6), c(2, 17, 2, 17, 2))], 3),
  c(0.000, 9.096, 7.141, 7.879, 9.985)
)

data("covariate_data_2005", package = "GERGM")
expect_equal(
  base::round(
    c(
      base::sum(covariate_data_2005[2, 1:2]),
      base::sum(covariate_data_2005[3, 1:2]),
      covariate_data_2005[5, 2],
      covariate_data_2005[6, 2]
    ),
    3
  ),
  c(693338595730, 892106837602, 28.450, 28.421)
)

data("net_exports_2005", package = "GERGM")
expect_equal(
  base::round(
    c(
      base::sum(net_exports_2005[2, 2:17]),
      base::sum(net_exports_2005[3, 2:17]),
      base::sum(net_exports_2005[4, 2:17]),
      base::sum(net_exports_2005[5, 2:17]),
      base::sum(net_exports_2005[6, 2:17])
    ),
    3
  ),
  c(-0.094, 0.137, 0.242, 1.013, -0.056)
)
