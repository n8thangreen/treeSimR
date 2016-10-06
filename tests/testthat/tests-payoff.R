library(data.tree)

context("payoff")

f <- function(x) {
  warning("foo")
}


tryCatch(
  f(),
  warning = function(e) 2,
  message = function(e) 1,
  error = function(e) 3)
