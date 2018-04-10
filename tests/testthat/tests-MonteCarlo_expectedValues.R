
context("Calculate expected values of decision tree")

library(treeSimR)
library(data.tree)
library(purrr)
library(yaml)


osList <- yaml.load_file("../testdata/test2.yaml")
osNode <- data.tree::as.Node(osList)
class(osNode) <- c("costeffectiveness_tree", class(osNode))
# treeSimR:::print.costeffectiveness_tree(osNode)


test_that("upper and lower bounds", {

  mc_res <- MonteCarlo_expectedValues(osNode = osNode, n = 1)[[1]]

  expect_gt(mc_res, 0)
  expect_lt(mc_res, 2)

})


