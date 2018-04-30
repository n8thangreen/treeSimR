
#' Calculate Risk Profile
#'
#' Calculate the distribution of outcome values.
#' TODO: overlap with subset_pop_dectree()
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


#' @rdname calc_riskprofile
#' @export
#'
calc_riskprofile.default <- function(osNode, ...) stop("Error: inappropriate object")


#' @rdname calc_riskprofile
#' @export
#'
calc_riskprofile.costeffectiveness_tree <- function(osNode){

  path_val <- calc_pathway_probs(osNode, FUN = "product")
  osNode$Set(path_prob = path_val)
  path_val <- calc_pathway_probs(osNode, FUN = "sum")
  osNode$Set(path_payoff = path_val)

  osNode
}
