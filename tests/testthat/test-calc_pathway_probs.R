context("test-calc_pathway_probs.R")

library(treeSimR)
library(yaml)
library(data.tree)
library(dplyr)
library(purrr)
library(tibble)


CEtree <- costeffectiveness_tree(yaml_tree = "../testdata/test3.yaml")

CEtree$osNode$Set(pmax = 0.3,
                  filterFun = function(x) x$name == "TB")

mean_probs <- c(1.0000, 0.1500, 0.0300, 0.1200, 0.8500, 0.2125, 0.6375)


test_that("mean probabilities", {

  expect_equivalent(calc_pathway_probs(CEtree$osNode),
                    mean_probs)
})


test_that("sample probabilities", {

  N <-  200
  temp <- vector(mode = "numeric", length = 7)
  for (i in seq_len(N)) temp <- temp + calc_pathway_probs(osNode = CEtree$osNode,
                                                            sample_p = TRUE)
  expect_equal(temp/N, mean_probs, tolerance = 0.01)

})


