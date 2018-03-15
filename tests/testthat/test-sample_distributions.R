context("test-sample_distributions.R")

test_that("multiplication works", {

  a <- sample_distributions(param.distns = list(distn = "unif",
                                                params = c(min = 0, max = 1)))
  expect_output(str(a), "'data.frame':	1 obs. of  1 variable:")

  # sample_distributions(param.distns = list(distn = "lognormal",
  #                                          params = c(mean = 10, sd = 1)))
  #
  # sample_distributions(param.distns = list(distn = "beta",
  #                                          params = c(mean = 0.1, sd = 0.1)))
  #
  # sample_distributions(param.distns = list(distn = "beta",
  #                                          params = c(a = 0.1, b = 0.1)))

  b <- sample_distributions(param.distns = list(list(distn = "beta",
                                                     params = c(a = 0.1, b = 0.1)),
                                                list(distn = "beta",
                                                     params = c(a = 0.1, b = 0.1))))

  expect_output(str(b), "'data.frame':	1 obs. of  2 variables:")

})
