
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
#'
assign_branch_vals <- function(osNode,
                               parameter_p,
                               parameter_val) {
  UseMethod("assign_branch_vals")
}

#' @rdname assign_branch_vals
#' @export
#'
assign_branch_vals.costeffectiveness_tree <- function(osNode,
                                                      parameter_p = NA,
                                                      parameter_val = NA) {

  if (all(is.na(parameter_p)) && all(is.na(parameter_val))) {

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

    # point values
    if ("p" %in% names(parameter_p)) {

      vals <- subset(x = parameter_p,
                     subset = (node == node_p),
                     select = p)

      osNode$Set(p = vals,
                 filterFun = function(x) x$name == node_p)

      if (all(c("pmin", "pmax") %in% osNode$fields)) {

        osNode$Set(pmin = vals,
                   pmax = vals,
                   filterFun = function(x) x$name == node_p)
      }
      # distns
    } else{

      vals <- subset(x = parameter_p,
                     subset = (node == node_p))

      osNode$Set(distn = "unif",
                 pmin = vals$min,
                 pmax = vals$max,
                 filterFun = function(x) x$name == node_p)
    }
  }

  # assign branching _values_
  for (node_val in names_val) {

    vals <- subset(x = parameter_val,
                   subset = (node == node_val))

    osNode$Set(distn = as.character(vals$distn),
               filterFun = function(x) x$name == node_val)

    ##TODO: tidy up duplication. switch? do.call?
    ##TODO: removed filter to outside to delete commented code? test

    subPop <- Traverse(osNode, filterFun = function(x) x$name == node_val)

    if ('min' %in% names(vals)) {
      # osNode$Set(min = vals$min,
      #            filterFun = function(x) x$name == node_val)

      Set(subPop, min = vals$min)
    }
    if ('max' %in% names(vals)) {

      # osNode$Set(max = vals$max,
      #            filterFun = function(x) x$name == node_val)

      Set(subPop, max = vals$max)
    }
    if ('shape' %in% names(vals)) {

      # osNode$Set(shape = vals$shape,
      #            filterFun = function(x) x$name == node_val)

      Set(subPop, shape = vals$shape)
    }
    if ('scale' %in% names(vals)) {

      # osNode$Set(scale = vals$scale,
      #            filterFun = function(x) x$name == node_val)

      Set(subPop, scale = vals$scale)
    }
  }

  return()
}
