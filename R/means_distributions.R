
#' means_distributions
#'
#' @param param.distns
#'
#' @return
#' @export
#'
#' @examples
#' means_distributions(unit_cost$aTB_TxDx)
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

                     pert = param.distns[[i]]$params["mode"])
  }

  return(setNames(out, names(param.distns)))
}


