
#' Print Method for Cost-Effectiveness Trees
#'
#' @param decisiontree
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
print.costeffectiveness_tree <- function(decisiontree, ...){

  do.call(data.tree:::print.Node, c(decisiontree, decisiontree$fieldsAll, limit = 1000))
}


