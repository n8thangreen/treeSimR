
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
#'
means_distributions <- function(param.distns){

  if (plotrix::listDepth(param.distns) == 1) {param.distns <- list(param.distns)}
  n.distns <- length(param.distns)

  out <- data.frame(matrix(NA, nrow = 1, ncol = n.distns))
  names(out) <- NULL

  for (i in seq_len(n.distns)) {

    distn <- match.arg(param.distns[[i]]$distn,
                       c("lognormal", "pert", "beta", "gamma", "unif", "triangle", "none"))

    out[i] <- switch(distn,
                     gamma = param.distns[[i]]$params["shape"] * param.distns[[i]]$params["scale"],

                     unif = param.distns[[i]]$params["min"] + (param.distns[[i]]$params["max"] - param.distns[[i]]$params["min"])/2,

                     pert = param.distns[[i]]$params["mode"],

                     none = param.distns[[i]]$params["mean"])
  }

  return(setNames(out, names(param.distns)))
}


