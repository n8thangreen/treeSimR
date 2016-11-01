
#' Calculate Weighted Expectations
#'
#' Calculates sum of probabilities multiplied by values (e.g. cost) for all branches in decision tree.
#'
#' (previous version: Gives maximum payoff, given optimal decisions)
#' \href{https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html}{This is the original example using data.tree}
#'
#' @param node The node of a data.tree package tree object
#'
#' @return jl$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
#' @export
#' @example

payoff <- function(node) {

  if (node$type != 'terminal') node$payoff <- node$payoff + sum(sapply(node$children, function(child) child$payoff * child$p))
}
