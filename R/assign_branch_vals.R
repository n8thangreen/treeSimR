
assign_branch_vals <- function(osNode,
                               parameter_p,
                               parameter_val) {
  UseMethod("assign_branch_vals")
}


#' Assign Branching Values to Decision Tree
#'
#' Used in deterministic sensitivity analysis.
#'
#' @param osNode data.tree object
#' @param parameter_p Decision tree node probabilities
#' @param parameter_val Decision tree node value
#'
#' @return
#' @export
#'
#' @examples
assign_branch_vals.costeffectiveness_tree <- function(osNode,
                                                      parameter_p = NA,
                                                      parameter_val = NA) {

  if (all(is.na(parameter_p)) & all(is.na(parameter_val))) {

    message("No scenario parameter values")
    return()
  }

  # if missing then use empty (NULL) loop
  names_val <-
    if (all(is.na(parameter_val))) {
      NULL
    }else{unique(parameter_val$node)}

  names_p <-
    if (all(is.na(parameter_p))) {
      NULL
    }else{unique(parameter_p$node)}

  # assign branching _probabilities_
  for (node_p in names_p) {

    vals <- subset(parameter_p,
                   node == node_p,
                   select = p)

    osNode$Set(p = vals,
               filterFun = function(x) x$name == node_p)
  }

  # assign branching _values_
  for (node_val in names_val) {

    vals <- subset(x = parameter_val,
                   subset = node == node_val)

    osNode$Set(distn = as.character(vals$distn),
               filterFun = function(x) x$name == node_val)

    osNode$Set(min = vals$min,
               filterFun = function(x) x$name == node_val)

    osNode$Set(max = vals$max,
               filterFun = function(x) x$name == node_val)
  }
}
