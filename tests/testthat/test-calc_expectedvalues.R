context("test-calc_expectedvalues.R")

library(treeSimR)
library(data.tree)
library(purrr)
library(yaml)


osList <- yaml.load_file("../testdata/test3.yaml")
osNode <- data.tree::as.Node(osList)
class(osNode) <- c("costeffectiveness_tree", class(osNode))


test_that("proper probabilities", {

  calc_expectedValues(osNode)

  probs <- osNode$Get("p")
  expect_equivalent(probs['TB'] + probs['Not TB'], 1)
  expect_equivalent(probs['Enhanced'] + probs['Standard'], 1)
})

test_that("errors and warnings", {

  expect_warning(calc_expectedValues(osNode))

})
