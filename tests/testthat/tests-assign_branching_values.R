
library(treeSimR)
library(yaml)

context("assign_branch_values")


test_that("values", {

  scenario_parameters <- tibble::tibble(node = c("Enhanced", "TB", "Enhanced", "TB"),
                                        min = c(2, 2, NA_real_, NA_real_),
                                        max = c(2, 2, NA, NA),
                                        distn = c("unif", "unif", NA_character_, NA_character_),
                                        val_type = c("cost", "cost", "QALYloss", "QALYloss"),
                                        p = c(NA_real_, NA_real_, 3, 4))

  CEtree <- costeffectiveness_tree(yaml_tree = "../testdata/test1.yaml")
  # treeSimR:::print.costeffectiveness_tree(CEtree)

  assign_branch_values(CEtree$osNode,
                       CEtree$osNode,
                       parameter_p = subset(scenario_parameters,
                                            val_type == "QALYloss"),
                       parameter_cost = subset(scenario_parameters,
                                               val_type == "cost"))

  ##TODO: add tests

})
