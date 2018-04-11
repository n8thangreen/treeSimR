context("assign_branch_values")


library(treeSimR)
library(yaml)
library(dplyr)
library(tibble)


test_that("types of return", {

  scenario_parameters <- tibble(node = c("Enhanced", "TB", "Enhanced", "TB"),
                                min = c(2, 2, NA_real_, NA_real_),
                                max = c(2, 2, NA, NA),
                                distn = c("unif", "unif", NA_character_, NA_character_),
                                val_type = c("cost", "cost", "QALYloss", "QALYloss"),
                                p = c(NA_real_, NA_real_, 3, 4))

  CEtree <- costeffectiveness_tree(yaml_tree = "../testdata/test1.yaml")
  # treeSimR:::print.costeffectiveness_tree(CEtree)

  expect_message(assign_branch_values(CEtree$osNode,
                       CEtree$osNode,
                       parameter_p = subset(scenario_parameters,
                                            val_type == "QALYloss"),
                       parameter_cost = subset(scenario_parameters,
                                               val_type == "cost")), NA)

  expect_message(assign_branch_values(CEtree$osNode,
                       CEtree$osNode,
                       parameter_p = NA,
                       parameter_cost = subset(scenario_parameters,
                                               val_type == "cost")),
                       "No scenario parameter values")

  expect_message(assign_branch_values(CEtree$osNode,
                                      CEtree$osNode,
                                      parameter_p = NA,
                                      parameter_cost = NA),
                 "No scenario parameter values")

})
