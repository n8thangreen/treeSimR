context("test-costeffectiveness_tree.R")


library(treeSimR)
library(data.tree)
library(purrr)
library(yaml)


test_that("warnings and errors", {

})


test_that("", {

  res <- costeffectiveness_tree(yaml_tree = "../testdata/test3.yaml")

  probs <- res$osNode$Get("p")
  expect_equivalent(probs['TB'] + probs['Not TB'], 1)
  expect_equivalent(probs['Enhanced'] + probs['Standard'], 1)

})
