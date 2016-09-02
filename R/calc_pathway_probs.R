
#' Calculate Total Pathway Probabilities of Decision Tree
#'
#'
#' @param osNode object of class costeffectiveness.tree
#' @param FUN sum or product
#'
#' @return vector of values
#' @export
#'
#' @examples
#'
calc.pathway_probs <- function(osNode, FUN = "product"){

  stopifnot("costeffectiveness.tree" %in% class(osNode))
  FUN <- match.arg(FUN, c("sum", "product"))

  x <- rep(osNode$Get("p")[1], osNode$totalCount)
  x[is.na(x)] <- 1  ##TODO## depending on sum or prod

  for(i in 2:osNode$totalCount){

    currentCount <- Get(t, "totalCount")[i]
    pos <- i + currentCount - 1

    if (FUN=="product"){
      x[i:pos] <- x[i:pos] * rep(osNode$Get("p")[i], currentCount)
    }else if (FUN=="sum"){
      x[i:pos] <- x[i:pos] + rep(osNode$Get("p")[i], currentCount)
    }else{
      stop("Error: unknown operator")
    }
  }

  names(x) <- NULL

  return(x)
}
