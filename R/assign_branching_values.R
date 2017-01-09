
#' Assign Branching Values to Decision Tree
#'
#' Used in deterministic sensitivity analysis.
#' ##TODO## at present no need for parameter_health
#'
#' @param osNode.cost data.tree object
#' @param osNode.health data.tree object
#' @param parameter_p Decision tree node probabilities
#' @param parameter_cost Decision tree node cost
#'
#' @return
#' @export
#'
#' @examples
assign_branch_values <- function(osNode.cost,
                                 osNode.health,
                                 parameter_p = NA,
                                 parameter_cost = NA) {

  # ##TODO##
  # #args
  # osNode.cost <- costeff.cost$osNode
  # osNode.health <- costeff.health$osNode
  # parameter_cost <- costeff.cost$data_cost
  # parameter_p <- costeff.cost$data_p



  if(all(class(osNode.cost)!="costeffectiveness_tree"))   stop("Cost decision tree is not a costeffectiveness_tree object")
  if(all(class(osNode.health)!="costeffectiveness_tree")) stop("Health decision tree is not a costeffectiveness_tree object")

  if(all(is.na(parameter_p)) & all(is.na(parameter_cost))) stop("No scenario parameter values")


  # if missing then use empty loop
  names.cost <- if(all(is.na(parameter_cost))){
                  NULL
                }else{unique(parameter_cost$node)}

  names.p <- if(all(is.na(parameter_p))){
                  NULL
                }else{unique(parameter_p$node)}

  # assign branching _probabilities_
  for (node_p in names.p){

    vals <- subset(parameter_p, node==node_p, select = p)

    osNode.cost$Set(p = vals,
                    filterFun = function(x) x$name==node_p)

    osNode.health$Set(p = vals,
                      filterFun = function(x) x$name==node_p)
  }

  # assign branching _costs_
  for (node_cost in names.cost){

    vals <- subset(x = parameter_cost, subset = node==node_cost)

    osNode.cost$Set(distn = as.character(vals$distn),
                    filterFun = function(x) x$name==node_cost)

    osNode.cost$Set(min = vals$min,
                    filterFun = function(x) x$name==node_cost)

    osNode.cost$Set(max = vals$max,
                    filterFun = function(x) x$name==node_cost)
  }
}
