#' Calculate Expected Values for Each Branch of Decision Tree
#'
#' @param osNode
#'
#' @return osNode
#' @export
#'
#' @examples
#'
calc.expectedValues <- function(osNode){

  stopifnot(class(osNode)=="costeffectiveness.tree")

  rpayoff <- osNode$Get(sampleNode)
  osNode$Set(payoff = rpayoff)

  osNode$Do(payoff, traversal = "post-order")#, filterFun = isNotLeaf)

  osNode
}


#' Monte Carlo Forward Simulation of Decision Tree
#'
#' @param osNode data.tree object
#' @param n Number of simulations
#'
#' @return column names array of n sets of expected values
#' @export
#'
#' @examples
#'
MonteCarlo.expectedValues <- function(osNode, n=100){

  if(!any(osNode$Get("type")=="logical"))
    stop("Error: Need at least one node labeled 'logical'")

  out <-  NULL
  for (i in 1:n){

    osNode <- calc.expectedValues(osNode)

    res <- osNode$Get("payoff", filterFun = function(x) x$type=="logical")
    names(res) <- osNode$Get("pathString", filterFun = function(x) x$type=="logical")

    out <- rbind(out, res)
  }

  out
}
