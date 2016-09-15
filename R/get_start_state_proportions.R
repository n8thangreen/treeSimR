#' Get Start State Proportions
#'
#' @param path_probs
#' @param startstateid
#' @param samplesize
#' @param numsamples
#'
#' @return
#' @export
#'
#' @examples
get_start_state_proportions <- function(path_probs, startstateid, samplesize, numsamples){

  stopifnot(length(path_probs)==length(startstateid))

  nterminal <- length(path_probs)
  sample.mat <- matrix(NA, nrow = nterminal, ncol = numsamples)
  for (i in 1:numsamples){

    sample.mat[,i] <- table(sample(x = 1:nterminal, size = samplesize, prob = path_probs, replace = TRUE))/samplesize
  }

  apply(sample.mat, 2, function(x) aggregate(x, by=list(startstateid), FUN=sum))
}
