
library(treeSimR)
library(yaml)

context("assign_branch_vals")

test_that("basic", {

  CEtree <- costeffectiveness_tree(yaml_tree = "../testdata/test1.yaml")
  # treeSimR:::print.costeffectiveness_tree(CEtree$osNode)

  scenario_parameters <- tibble::tibble(node = c("Enhanced", "TB", "Enhanced", "TB"),
                                        min = c(2, 2, NA_real_, NA_real_),
                                        max = c(2, 2, NA, NA),
                                        distn = c("unif", "unif", NA_character_, NA_character_),
                                        val_type = c("cost", "cost", "p", "p"),
                                        p = c(NA_real_, NA_real_, 3, 4))

  assign_branch_vals(CEtree$osNode,
                     parameter_p = subset(scenario_parameters,
                                          val_type == "p"),
                     parameter_val = subset(scenario_parameters,
                                            val_type == "cost"))

  expect_equivalent(CEtree$osNode$Get("p"), c(1,3,4,1,NA,4,0))

  expect_equivalent(CEtree$osNode$Get("min"), c(1,2,2,1,1,2,1))

  expect_equivalent(CEtree$osNode$Get("max"), c(1,2,2,1,1,2,1))

})

