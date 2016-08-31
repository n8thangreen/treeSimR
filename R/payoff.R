
#' Calculate Weighted Expectations
#'
#' Calculates sum of probability times values (e.g. cost) for all branches in decision tree.
#'
#' (previously: Gives maximum payoff, given optimal decisions)
#' [This is the original example using data.tree](https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html)
#'
#' @param node The node of a data.tree package tree object
#'
#' @return jl$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
#' @export

payoff <- function(node) {

  if (node$type != 'terminal') node$payoff <- sum(sapply(node$children, function(child) child$payoff * child$p))

  # if (node$type == 'chance') node$payoff <- sum(sapply(node$children, function(child) child$payoff * child$p))
  # else if (node$type == 'decision') node$payoff <- max(sapply(node$children, function(child) child$payoff))
}
