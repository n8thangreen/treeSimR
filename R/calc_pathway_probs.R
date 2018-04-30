
#' Calculate Total Pathway Probabilities of Decision Tree
#'
#' Sequential event operations.
#' The probabilities are calculate with \code{FUN="product"}
#' and the values are calculated with \code{FUN="sum"}.
#'
#' @param osNode object of class costeffectiveness_tree
#' @param FUN sum or product
#' @param sample_p Sample from distirbution or use mean values. default: FALSE
#'
#' @return vector of values
#' @export
#'
#' @seealso \code{\link{calc_riskprofile}}
#'
calc_pathway_probs <- function(osNode, FUN, sample_p = FALSE) UseMethod("calc_pathway_probs", osNode)

#' @rdname calc_pathway_probs
#' @export
calc_pathway_probs.default <- function(osNode, ...) stop("Error: inappropriate object")


#' @rdname calc_pathway_probs
#' @export
calc_pathway_probs.costeffectiveness_tree <- function(osNode,
                                                      FUN = "product",
                                                      sample_p = FALSE){

  FUN <- match.arg(FUN, c("sum", "product"))
  if (!FUN %in% c("sum", "product")) stop("Error: unknown operator in 'FUN'")

  ##TODO:
  #check p's are uptodate and consistent
  if (all(c("pmin", "pmax") %in% osNode$fields)) {

    osNode$Set(p = osNode$Get("pmin")) #assume that its NA

    rprob <-
      if (sample_p) {
        osNode$Get(sampleNodeUniform)
      } else {
        osNode$Get(meanNodeUniform)
      }

    osNode$Set(p = rprob)
    osNode$Set(p = fill_in_missing_tree_probs(osNode, "p"))
  }

  if (FUN == "product") {

    probs <- osNode$Get("p")
    x <- rep(x = probs[1],
             osNode$totalCount)
    x[is.na(x)] <- 1

  } else {

    probs <- osNode$Get("payoff")
    x <- rep(x = probs[1],
             osNode$totalCount)
    x[is.na(x)] <- 0
  }

  t <- Traverse(osNode, traversal = "pre-order")
  traversalCount <- Get(t, "totalCount")

  for (i in 2:osNode$totalCount) {

    currentCount <- traversalCount[i]
    pos <- i + currentCount - 1

    if (FUN == "product") {
      x[i:pos] <- x[i:pos] * rep(x = probs[i], currentCount)

    } else {
      x[i:pos] <- x[i:pos] + rep(x = probs[i], currentCount)
    }
  }

  names(x) <- NULL

  return(x)
}
