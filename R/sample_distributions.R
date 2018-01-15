
#' Sample from Standard Distributions
#'
#' Supply a list of defined distributions (log-normal, beta, gamma, uniform, triangle)
#' and one sample realisation is taken of each.
#'
#' @param param.distns List of distribution names and their respective parameter values
#'
#' @return vector of sample points
#' @export
#'
#' @examples
#'
#' sample_distributions(param.distns = list(distn = "unif", params = c(min=0, max=1)))
#' sample_distributions(param.distns = list(distn = "lognormal", params = c(mean=10, sd=1)))
#' sample_distributions(param.distns = list(distn = "beta", params = c(mean=0.1, sd=0.1)))
#' sample_distributions(param.distns = list(distn = "beta", params = c(a=0.1, b=0.1)))
#' sample_distributions(param.distns = list(list(distn = "beta", params = c(a=0.1, b=0.1)), list(distn = "beta", params = c(a=0.1, b=0.1))))

sample_distributions <- function(param.distns){

  try(library(triangle), silent = TRUE)
  stopifnot(is.list(param.distns))

  if(plotrix::listDepth(param.distns)==1) {param.distns <- list(param.distns)}
  n.distns <- length(param.distns)

  out <- data.frame(matrix(NA, nrow = 1, ncol = n.distns))
  names(out) <- NULL

  for (i in seq_len(n.distns)){

    distn <- match.arg(param.distns[[i]]$distn,
                       c("lognormal", "pert", "beta", "gamma", "unif", "triangle", "none"))

    out[i] <- switch(distn,
                     gamma = {
                       if(!is.na(param.distns[[i]]$params["mean"]) &
                          !is.na(param.distns[[i]]$params["sd"])){

                         mom <- MoM_gamma(mean = param.distns[[i]]$params["mean"],
                                          var = param.distns[[i]]$params["sd"]^2)
                         gamma = rgamma(1, shape = mom$shape,
                                           scale = mom$scale)
                       }else{
                         gamma = rgamma(1, shape = param.distns[[i]]$params["shape"],
                                           scale = param.distns[[i]]$params["scale"])
                       }
                     },

                     unif = runif(1, param.distns[[i]]$params["min"],
                                     param.distns[[i]]$params["max"]),

                     lognormal = rlnorm(1, param.distns[[i]]$params["mean"],
                                           param.distns[[i]]$params["sd"]),

                     beta = {
                       if(!is.na(param.distns[[i]]$params["mean"]) &
                          !is.na(param.distns[[i]]$params["sd"])){

                         mom <- MoM_beta(xbar = param.distns[[i]]$params["mean"],
                                         vbar = param.distns[[i]]$params["sd"]^2)

                         beta = rbeta(1, shape1 = mom$a, shape2 = mom$b)
                       }else{
                         beta = rbeta(1, shape1 = param.distns[[i]]$params["a"],
                                         shape2 = param.distns[[i]]$params["b"])
                       }
                     },

                     triangle = rtriangle(1, param.distns[[i]]$params["min"],
                                             param.distns[[i]]$params["max"]),

                     pert = rpert(1, x.min = param.distns[[i]]$params["min"],
                                     x.max = param.distns[[i]]$params["max"],
                                     x.mode = param.distns[[i]]$params["mode"]),

                     none = param.distns[[i]]$params["mean"])
  }

  return(setNames(out, names(param.distns)))
}


#' Sample a data.tree Node
#'
#' @param node data.tree node
#'
#' @return
#' @export
#' @seealso  \link{sample_distributions}
#' @examples
#'
#' rpayoff <- osNode$Get(sampleNode)
#'
sampleNode <- function(node) {

  DISTN <- list(distn = node$distn,
                params = c(mean = node$mean, sd = node$sd,
                           min = node$min, max = node$max,
                           mode = node$mode,
                           shape = node$shape, scale = node$scale,
                           a = node$a, b = node$b))
  suppressWarnings(
    DISTN$params <-
      DISTN$params %>%
      map_dbl(function(x) as.numeric(as.character(x))))

  sample_distributions(list(DISTN))
}


#' Sample a data.tree uniform node
#'
#' @param node data.tree node
#'
#' @return
#' @export
#' @seealso  \link{sample_distributions}
#' @examples
#'
#' rprob <- osNode$Get(sampleNodeUniform)
#'
sampleNodeUniform <- function(node) {

  DISTN <- list(distn = "unif",
                params = c(min = node$pmin,
                           max = node$pmax))
  suppressWarnings(
    DISTN$params <-
      DISTN$params %>%
      map_dbl(function(x) as.numeric(as.character(x))))

  sample_distributions(list(DISTN))
}



#' Get Standard Deviation from Normal Confidence Interval
#'
#' \link{http://stats.stackexchange.com/questions/30402/how-to-calculate-mean-and-standard-deviation-in-r-given-confidence-interval-and}
#'
#' @param n Sample size
#' @param x_bar Mean
#' @param upperCI Upper 95% CI
#' @param lowerCI Lower 95% CI
#'
#' @return sd
#' @export
#'
get_sd_from_normalCI <- function(n, x_bar=NA, upperCI=NA, lowerCI=NA){

  if(!is.na(lowerCI) & !is.na(x_bar)){
    sd <- sqrt(n) * (x_bar - lowerCI)/1.96
  }else if(!is.na(upperCI) & !is.na(x_bar)){
    sd <- sqrt(n) * (upperCI - x_bar)/1.96
  }else if (!is.na(lowerCI) & !is.na(upperCI)){
    sd <- sqrt(n) * (upperCI - lowerCI)/(2*1.96)
  }
  return(sd)
}


#' Method of Moments Beta Distribution Parameter Transformation
#'
#' Could alternatively use the beta-PERT \code{\link{rpert}} with maximum and minimum instead of variance.
#'
#' @param xbar Mean
#' @param vbar Variance
#'
#' @return a and b of Beta(a,b)
#' @seealso \link{rpert}
#' @export
#'
MoM_beta <- function(xbar, vbar){

  if(vbar==0){stop("zero variance not allowed")
  }else if(xbar*(1-xbar)<vbar){
    stop("mean or var inappropriate")
  }else{
    a <- xbar * (((xbar*(1-xbar))/vbar)-1)
    b <- (1-xbar) * (((xbar*(1-xbar))/vbar)-1)
  }
  list(a=a, b=b)
}


#' Method of Moments Gamma Distribution Parameter Transformation
#'
#' @param mean Mean
#' @param var Variance
#'
#' @return shape, scale
#' @seealso \link{MoM_beta}
#' @export
#'
MoM_gamma <- function(mean, var){

  stopifnot(var>=0)
  stopifnot(mean>=0)
  names(mean) <- NULL
  names(var)  <- NULL

  list(shape = mean^2/var,
       scale = var/mean)
}


#' Sample from Beta-PERT Distribution
#'
#' see https://reference.wolfram.com/language/ref/PERTDistribution.html
#'
#' @param n Sample size
#' @param x.min Lower limit
#' @param x.max Upper limit
#' @param x.mode Mode
#' @param lambda Shape parameter
#'
#' @return sampled value
#' @export
#'
rpert <- function(n, x.min, x.max, x.mode, lambda = 4){

  if( x.min > x.max || x.mode > x.max || x.mode < x.min ) stop( "invalid parameters" )

  x.range <- x.max - x.min
  if( x.range == 0 ) return( rep( x.min, n ))

  mu <- ( x.min + x.max + lambda * x.mode ) / ( lambda + 2 )

  # special case if mu == mode
  if( mu == x.mode ){
    v <- ( lambda / 2 ) + 1
  }
  else {
    v <- (( mu - x.min ) * ( 2 * x.mode - x.min - x.max )) /
      (( x.mode - mu ) * ( x.max - x.min ));
  }

  w <- ( v * ( x.max - mu )) / ( mu - x.min )
  return ( rbeta( n, v, w ) * x.range + x.min )
}

