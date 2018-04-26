
#' Calculate Risk Profile
#'
#' This function can be used to calculate the Risk Profile.
#' That is, the distribution of outcome values.
#'
#' @param osNode
#'
#' @return
#' @export
#'
#' @seealso \link{calc_pathway_probs}
#' @examples
#'
calc_riskprofile <- function(osNode) UseMethod("calc_riskprofile")


#' Calculate Risk Profile
#'
#' This function can be used to calculate the Risk Profile.
#' That is, the distribution of outcome values.
#'
#' @param osNode
#'
#' @return
#' @export
#'
#' @seealso \link{calc_pathway_probs}
#' @examples
#'
calc_riskprofile.default <- function(osNode, ...) stop("Error: inappropriate object")


#' Calculate Risk Profile
#'
#' This function can be used to calculate the Risk Profile.
#' That is, the distribution of outcome values.
#'
#' @param osNode
#'
#' @return
#' @export
#'
#' @seealso \link{calc_pathway_probs}
#' @examples
#'
calc_riskprofile.costeffectiveness_tree <- function(osNode){

  path_val <- calc_pathway_probs(osNode, FUN = "product")
  osNode$Set(path_prob = path_val)
  path_val <- calc_pathway_probs(osNode, FUN = "sum")
  osNode$Set(path_payoff = path_val)

  osNode
}
