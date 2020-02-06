
#' Means values from distributions
#'
#' @param param.distns list of distribution name and hyper-parameters
#'
#' @return double
#' @export
#'
#' @examples
#'
#' param.distns <- list(distn = "unif", params = c(min = 0, max = 1))
#' means_distributions(param.distns)
#' param.distns <- list(distn = "gamma", params = c(shape = 21, scale = 2))
#' means_distributions(param.distns)
#' param.distns <- list(distn = "gamma", params = c(mean = 21, scale = 2))
#' means_distributions(param.distns)
#'
means_distributions <- function(param.distns){

  if (plotrix::listDepth(param.distns) == 1) {param.distns <- list(param.distns)}
  n.distns <- length(param.distns)

  out <- data.frame(matrix(NA, nrow = 1, ncol = n.distns))
  names(out) <- NULL

  for (i in seq_len(n.distns)) {

    param_vals <- as.list(param.distns[[i]]$params)

    distn <- match.arg(param.distns[[i]]$distn,
                       c("lognormal", "pert", "beta", "gamma", "unif", "triangle", "none"))

    out[i] <- switch(distn,
                     gamma = do.call(mean_gamma, args = param_vals),

                     unif = param_vals$min + (param_vals$max - param_vals$min)/2,

                     pert = param_vals$mode,

                     none = param_vals$mean)
  }

  return(setNames(out, names(param.distns)))
}


#' mean_gamma
#'
#' @param ...
#'
#' @return
#' @export
#'
mean_gamma <- function(...) {

  params <- list(...)

  if ("mean" %in% names(params)) {

    return(params$mean)

  } else if (all(c("shape", "scale") %in% names(params))) {

    return(params$shape * params$scale)
  }

  stop("cannot determine mean")
}
