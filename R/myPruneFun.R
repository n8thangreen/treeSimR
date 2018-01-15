
#' Prune Tree
#'
#' Return just the paths with the given leaf name
#'
#' @param x Tree node
#' @param leafName Character string
#'
#' @return
#' @export
#'
#' @examples
myPruneFun <- function(x, leafName) {

  if (isNotLeaf(x)) return(TRUE)
  if (x$name != leafName) return(FALSE)
  return(TRUE)
}

