
#' from purrr but now deprecated
#'
#' Compute the depth of a vector
#'
#' The depth of a vector is basically how many levels that you can index
#' into it.
#'
#' @param x A vector
#' @return An integer.
#' @export
#' @examples
#' x <- list(
#'   list(),
#'   list(list()),
#'   list(list(list(1)))
#' )
#' vec_depth(x)
#' x %>% map_int(vec_depth)
#'
vec_depth <- function(x) {
  if (is.null(x)) {
    0L
  } else if (is.atomic(x)) {
    1L
  } else if (is.list(x)) {
    depths <- map_int(x, vec_depth)
    1L + max(depths, 0L)
  } else {
    abort("`x` must be a vector")
  }
}
