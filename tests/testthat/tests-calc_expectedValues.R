
library(treeSimR)
library(data.tree)
library(purrr)

context("Calculate expected values of decision tree")


osList <- yaml.load_file("../testdata/test2.yaml")
osNode <- data.tree::as.Node(osList)
class(osNode) <- c("costeffectiveness_tree", class(osNode))
# treeSimR:::print.costeffectiveness_tree(osNode)


test_that("upper and lower bounds", {

  expect_gt(MonteCarlo_expectedValues(osNode = osNode, n = 1)[[1]], 0)
  expect_lt(MonteCarlo_expectedValues(osNode = osNode, n = 1)[[1]], 2)

})


