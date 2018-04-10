context("test-calc_expectedvalues.R")

library(treeSimR)
library(data.tree)
library(purrr)
library(yaml)


osList <- yaml.load_file("../testdata/test3.yaml")
osNode <- data.tree::as.Node(osList)
class(osNode) <- c("costeffectiveness_tree", class(osNode))
# treeSimR:::print.costeffectiveness_tree(osNode)


test_that("", {


})

