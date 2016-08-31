
#' Calculate Optimal Decision
#'
#' Depends on how we calculate the payoff function.
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
decision <- function(x) {

  po <- sapply(x$children, function(child) child$payoff)
  x$decision <- names(po[po == x$payoff])
}


#' Node label
#'
#' @param node
#'
#' @return
#' @export
#'
#' @examples
Nodelabel <- function(node) {

  po <- paste0( '$ ', format(node$payoff, scientific = FALSE, big.mark = "'"))
  if (node$type == 'terminal') return (po)
  return ( paste0('ER\n', po) )
}
