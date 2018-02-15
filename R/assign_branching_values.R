
#' Wrapper to Assign Branching Values to Decision Tree
#'
#' THIS REPLACES NON-S3 FUNCTION
#'
#' Used in deterministic sensitivity analysis.
#'
#' @param osNode.cost costeffectiveness.tree object
#' @param osNode.health costeffectiveness.tree object
#' @param parameter_p Decision tree node probabilities
#' @param parameter_cost Decision tree node values
#'
#' @return
#' @export
#'
#' @examples
assign_branch_values <-  function(osNode.cost,
                                  osNode.health,
                                  parameter_p = NA,
                                  parameter_cost = NA) {

  osNode.health %>% assign_branch_vals(parameter_p = parameter_p)

  osNode.cost %>% assign_branch_vals(parameter_p = parameter_p,
                                     parameter_val = parameter_cost)
}
