#' Get Start State Proportions
#'
#' Population sizes of individuals in each starting state as input for the competing risks model.
#'
#' @param path_probs  Probabilitites along each branch, from root to leaf usinghj \link{calc_pathway_probs}
#' @param startstateid How to group terminal nodes
#' @param samplesize Total population size
#' @param numsamples Number of realisations
#'
#' @return list
#' @export
#'
#' @examples
#'
get_start_state_proportions <- function(path_probs, startstateid, samplesize, numsamples){

  stopifnot(length(path_probs)==length(startstateid))

  nterminal  <- length(path_probs)
  sample.mat <- matrix(0, nrow = nterminal, ncol = numsamples)
  for (i in 1:numsamples){

    tab <- table(sample(x = 1:nterminal, size = samplesize, prob = path_probs, replace = TRUE))/samplesize
    sample.mat[as.numeric(names(tab)), i] <- tab
  }

  apply(sample.mat, 2, function(x) setNames(object = aggregate(x, by=list(startstateid), FUN=sum), nm = c("state", "prob")))
}
