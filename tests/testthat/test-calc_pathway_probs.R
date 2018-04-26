context("test-calc_pathway_probs.R")

library(treeSimR)
library(yaml)
library(data.tree)
library(dplyr)
library(purrr)
library(tibble)


test_that("dummy data", {

  CEtree <- costeffectiveness_tree(yaml_tree = "../testdata/test3.yaml")

  CEtree$osNode$Set(pmax = 0.3,
                    filterFun = function(x) x$name == "TB")

  expect_equivalent(calc_pathway_probs(CEtree$osNode),
                    c(1.0000, 0.1500, 0.0300, 0.1200, 0.8500, 0.2125, 0.6375))
})
