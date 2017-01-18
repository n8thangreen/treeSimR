
library(treeSimR)
library(yaml)

context("sampleNode")

test_that("different distributions and parameter values", {

  osList <- yaml.load_file("../testdata/test1.yaml")
  osNode <- data.tree::as.Node(osList)
  # treeSimR:::print.costeffectiveness_tree(osNode)

  sample <- unlist(osNode$Get(sampleNode))
  names(sample) <- NULL

  expect_equal(sample, rep(1, length(sample)), info = "sampling from distn centred at 1, sd 0")

  osList$distn <- "gamma"
  osList$mean <- 1
  osList$sd <- 1

  osNode <- data.tree::as.Node(osList)
  sample <- unlist(osNode$Get(sampleNode))
  names(sample) <- NULL

  expect_true(sample[1]!=1, info = "haven't modified distribution (weak test)")

  osList$mean <- NA
  osNode <- data.tree::as.Node(osList)
  expect_error(osNode$Get(sampleNode), info = "mean >= 0 is not TRUE")

  # osList$distn <- "other"
  # osNode <- data.tree::as.Node(osList)
  # sample <- unlist(osNode$Get(sampleNode))
  # names(sample) <- NULL
  #
  # expect_equal(sample, c(NA, rep(1, length(sample)-1)), info = "distn not available returns NA sample")

})
