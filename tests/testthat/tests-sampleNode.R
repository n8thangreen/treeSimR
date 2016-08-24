context("sampleNode")

test_that("different distributions and parameter values", {

  osList <- yaml.load_file("raw data/test1.yaml")
  osNode <- data.tree::as.Node(osList)
  # print(osNode, "type", "p", "distn", "min", "max", "mean", "sd")

  sample <- unlist(osNode$Get(sampleNode))
  names(sample) <- NULL

  expect_equal(sample, rep(1, length(sample)))

  osList$distn <- "gamma"
  osList$mean <- 1
  osList$sd <- 1

  osNode <- data.tree::as.Node(osList)
  sample <- unlist(osNode$Get(sampleNode))
  names(sample) <- NULL

  expect_true(sample[1]!=1)


  osList$mean <- NA
  osNode <- data.tree::as.Node(osList)
  expect_error(osNode$Get(sampleNode), "mean >= 0 is not TRUE")


  osList$distn <- "other"
  osNode <- data.tree::as.Node(osList)
  sample <- unlist(osNode$Get(sampleNode))
  names(sample) <- NULL

  expect_equal(sample, c(NA, rep(1, length(sample)-1)))

})
