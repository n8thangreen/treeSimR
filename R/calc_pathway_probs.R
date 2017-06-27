
#' Calculate Total Pathway Probabilities of Decision Tree
#'
#' Sequential event operations.
#' The probabilities are calculate with \code{FUN="product"}
#' and the values are calculated with \code{FUN="sum"}.
#'
#' @param osNode object of class costeffectiveness_tree
#' @param FUN sum or product
#'
#' @return vector of values
#' @export
#'
#' @seealso \link{calc_riskprofile}
#'
calc_pathway_probs <- function(osNode, FUN) UseMethod("calc_pathway_probs", osNode)


#' Calculate Total Pathway Probabilities of Decision Tree
#'
#' Sequential event operations.
#' The probabilities are calculate with \code{FUN="product"}
#' and the values are calculated with \code{FUN="sum"}.
#'
#' @param osNode object of class costeffectiveness_tree
#' @param FUN sum or product
#'
#' @return vector of values
#' @export
#'
#' @seealso \link{calc_riskprofile}
#'
calc_pathway_probs.default <- function(osNode, ...) print("Error: inappropriate object")


#' Calculate Total Pathway Probabilities of Decision Tree
#'
#' Sequential event operations.
#' The probabilities are calculate with \code{FUN="product"}
#' and the values are calculated with \code{FUN="sum"}.
#'
#' @param osNode object of class costeffectiveness_tree
#' @param FUN sum or product
#'
#' @return vector of values
#' @export
#'
#' @seealso \link{calc_riskprofile}
#' @examples
#'
calc_pathway_probs.costeffectiveness_tree <- function(osNode,
                                                      FUN = "product"){

  FUN <- match.arg(FUN, c("sum", "product"))

  if (FUN == "product"){
    probs <- osNode$Get("p")
    x <- rep(x = probs[1],
             osNode$totalCount)
    x[is.na(x)] <- 1
  }else if (FUN == "sum"){
    probs <- osNode$Get("payoff")
    x <- rep(x = probs[1],
             osNode$totalCount)
    x[is.na(x)] <- 0
  }

  t <- Traverse(osNode, traversal = "pre-order")
  traversalCount <- Get(t, "totalCount")

  for(i in 2:osNode$totalCount){

    currentCount <- traversalCount[i]
    pos <- i + currentCount - 1

    if (FUN == "product"){
      x[i:pos] <- x[i:pos] * rep(x = probs[i], currentCount)
    }else if (FUN == "sum"){
      x[i:pos] <- x[i:pos] + rep(x = probs[i], currentCount)
    }else{
      stop("Error: unknown operator")
    }
  }

  names(x) <- NULL

  return(x)
}
