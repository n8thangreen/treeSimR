
#' Calculate Total Pathway Probabilities of Decision Tree
#'
#' @param osNode
#'
#' @return vector of values
#' @export
#'
#' @examples
#'
calc.pathway_probs <- function(osNode){

  x <- rep(osNode$Get("p")[1], osNode$totalCount)
  x[is.na(x)] <- 0  ##TODO## depending on sum or prod

  for(i in 2:osNode$totalCount){

    currentCount <- Get(t, "totalCount")[i]
    if (currentCount!=1){
      pos <- i + currentCount - 1
    }else{
      pos <- i
    }
    x[i:pos] <- x[i:pos] + rep(osNode$Get("p")[i], currentCount)
  }

  names(x) <- NULL

  return(x)
}
