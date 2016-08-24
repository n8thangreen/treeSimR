
#' Calculate weighted expectations
#'
#' Gives maximum payoff, given optimal decisions
#' [This is the original example using data.tree](https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html)
#'
#' @param node
#'
#' @return jl$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
#' @export

payoff <- function(node) {

  if (node$type == 'chance') node$payoff <- sum(sapply(node$children, function(child) child$payoff * child$p))
  else if (node$type == 'decision') node$payoff <- max(sapply(node$children, function(child) child$payoff))
}


#' Randomly Sample a Value for a Node
#'
#' @param node
#'
#' @return sampled value
#' @export
#'
#' @examples
sampleNode <- function(node) {

  DISTN <- switch(node$distn,
                  gamma = list(distn=node$distn, params=c(mean=node$mean, sd=node$sd)),
                  unif = list(distn=node$distn,  params=c(min=node$min, max=node$max)))

  return(sample.distributions(list(DISTN)))
}



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

