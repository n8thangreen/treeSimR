#' Calculate Expected Values for Each Node of Decision Tree
#'
#' Takes an object of class costeffectiveness_tree.
#'
#' @param osNode
#'
#' @return osNode
#' @export
#'
#' @seealso \link{costeffectiveness_tree}, \link{payoff}
#'
calc_expectedValues <- function(osNode) UseMethod("calc_expectedValues")


#' Calculate Expected Values for Each Node of Decision Tree
#'
#' Takes an object of class costeffectiveness_tree.
#'
#' @param osNode
#'
#' @return osNode
#' @export
#'
#' @seealso \link{costeffectiveness_tree}, \link{payoff}
#'
calc_expectedValues.default <- function(osNode) print("Error: inappropriate object")


#' Calculate Expected Values for Each Node of Decision Tree
#'
#' Takes an object of class costeffectiveness_tree.
#'
#' @param osNode
#'
#' @return osNode
#' @export
#'
#' @seealso \link{costeffectiveness_tree}, \link{payoff}
#'
#' @examples
#' \dontrun{
#' ## read-in decision tree
#' osNode <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
#' print(osNode, "type", "p", "distn", "mean", "sd")
#'
#' ## calculate a single realisation expected values
#' osNode <- calc_expectedValues(osNode)
#' print(osNode, "type", "p", "distn", "mean", "sd", "payoff", "sampled")
#'
#' ## calculate multiple realisation for specific nodes
#' MonteCarlo_expectedValues(osNode, n=100)
#' }
#'
calc_expectedValues.costeffectiveness_tree <- function(osNode){

  rpayoff <- osNode$Get(sampleNode)
  osNode$Set(payoff = rpayoff)
  osNode$Set(sampled = rpayoff)

  if (all(c("pmin", "pmax") %in% osNode$fields)) {

    rprob <- osNode$Get(sampleNodeUniform)
    osNode$Set(p = rprob)
  }

  osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

  osNode
}


#' Monte Carlo Forward Simulation of Decision Tree
#'
#' Results are returned for the nodes labelled logical in decision tree.
#' Require at least one logical node.
#'
#' @param osNode A data.tree object with class costeffectiveness_tree
#' @param n Number of simulations
#'
#' @return list containing array of n sets of expected values and sampled nodes full names
#' @export
#' @seealso calc_expectedValues
#'
MonteCarlo_expectedValues <- function(osNode, n){
  UseMethod("MonteCarlo_expectedValues", osNode)
}


#' Monte Carlo Forward Simulation of Decision Tree
#'
#' Results are returned for the nodes labelled logical in decision tree.
#' Require at least one logical node.
#'
#' @param osNode A data.tree object with class costeffectiveness_tree
#' @param n Number of simulations
#'
#' @return list containing array of n sets of expected values and sampled nodes full names
#' @export
#' @seealso calc_expectedValues
#'
MonteCarlo_expectedValues.default <- function(osNode, ...) print("Error: inappropriate object")


#' Monte Carlo Forward Simulation of Decision Tree
#'
#' Results are returned for the nodes labelled logical in decision tree.
#' Require at least one logical node.
#'
#' @param osNode A data.tree object with class costeffectiveness_tree
#' @param n Number of simulations
#'
#' @return list containing array of n sets of expected values and sampled nodes full names
#' @export
#' @seealso calc_expectedValues
#'
#' @examples
#' \dontrun{
#' ## read-in decision tree
#' osNode <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
#' print(osNode, "type", "p", "distn", "mean", "sd")
#'
#' ## calculate a single realisation expected values
#' osNode <- calc_expectedValues(osNode)
#' print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
#'
#' ## calculate multiple realisation for specific nodes
#' MonteCarlo_expectedValues(osNode, n=100)
#' }
#'
MonteCarlo_expectedValues.costeffectiveness_tree <- function(osNode,
                                                             n = 100){

  if (n <= 0)
    stop("n must be positive")

  if (n %% 1 != 0)
    stop("n must be a whole number")

  if (!any(osNode$Get("type") == "logical"))
    stop("Error: Need at least one node labeled 'logical'")

  NodeNames <- osNode$Get("pathString",
                          filterFun = function(x) x$type == "logical")
  names(NodeNames) <- NULL

  out <-  matrix(data = NA,
                 nrow = n, ncol = length(NodeNames))
  for (i in 1:n) {

    # osNode2 <- calc_expectedValues(osNode)
    osNode <- calc_expectedValues(osNode)

    res <- osNode$Get("payoff",
                      filterFun = function(x) x$type == "logical")
    out[i,] <- res
  }

  list("expected values" = out,
       "node names" = NodeNames)
}
