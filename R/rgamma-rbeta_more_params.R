
#' rgamma_more_params
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
rgamma_more_params <- function(...) {

  params <- list(...)

  if (all(c("mean", "sd") %in% params)) {

    params <- c(params,
                MoM_gamma(mean = params$mean,
                          var  = params$sd^2))
  }

  rgamma(1,
         shape = params$shape,
         scale = params$scale)
}


#' rbeta_more_params
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
rbeta_more_params <- function(...) {

  params <- list(...)

  if (all(c("mean", "sd") %in% params)) {

    params <- c(params,
                MoM_beta(xbar = params$mean,
                         vbar  = params$sd^2))
  }

  rbeta(1,
        shape1 = params$a,
        shape2 = params$b)
}
