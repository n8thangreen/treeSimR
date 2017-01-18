
library(treeSimR)
library(data.tree)

context("Calculate expected values of decision tree")


osList <- yaml.load_file("tests/testdata/test2.yaml")
osNode <- data.tree::as.Node(osList)
class(osNode) <- c("costeffectiveness_tree", class(osNode))
# treeSimR:::print.costeffectiveness_tree(osNode)


test_that("", {

  expect_gt(MonteCarlo_expectedValues(osNode = osNode, n = 1)[[1]], 0)
  expect_lt(MonteCarlo_expectedValues(osNode = osNode, n = 1)[[1]], 1)

})


