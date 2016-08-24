
#' Sample from Standard Distributions
#'
#' Supply a list of defined distributions and one sample realisation is taken of each.
#'
#' @param param.distns List of distribution names and their respective parameter values
#'
#' @return vector of sample points
#' @examples
#' @export

sample.distributions <- function(param.distns){

  try(library(triangle), silent = TRUE)

  out <- data.frame(matrix(NA, nrow = 1, ncol = length(param.distns)))
  for (i in 1:length(param.distns)){

    distn <- match.arg(param.distns[[i]]$distn, c("gamma", "unif", "triangle", "none"))

    out[i] <- switch(distn,
                     gamma = {
                       mom <- MoM.gamma(mean=param.distns[[i]]$params["mean"],
                                        var=param.distns[[i]]$params["sd"]^2)
                       gamma = rgamma(1, shape = mom$shape, scale = mom$scale)
                     },
                     unif = runif(1, param.distns[[i]]$params["min"],
                                     param.distns[[i]]$params["max"]),
                     triangle = rtriangle(1, param.distns[[i]]$params["min"],
                                             param.distns[[i]]$params["max"]),
                     none = param.distns[[i]]$params["mean"])
  }

  names(out) <- names(param.distns)

  return(out)
}


#' Sample a data.tree Node
#'
#' @param node data.tree node
#'
#' @return
#' @export
#'
#' @examples
sampleNode <- function(node) {
  DISTN <- list(distn = node$distn,
                params = c(mean=node$mean, sd=node$sd, min=node$min, max=node$max))
  sample.distributions(list(DISTN))
}


#' Get Standard Deviation from Normal Confidence Interval
#'
#' http://stats.stackexchange.com/questions/30402/how-to-calculate-mean-and-standard-deviation-in-r-given-confidence-interval-and
#'
#' @param n Sample size
#' @param x_bar Mean
#' @param upperCI Upper 95% CI
#' @param lowerCI Lower 95% CI
#'
#' @return sd
#' @export
#'
get.sd.from.normalCI <- function(n, x_bar=NA, upperCI=NA, lowerCI=NA){

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
#' @seealso rpert
#' @export
#'
MoM.beta <- function(xbar, vbar){

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
#' @seealso MoM.beta
#' @export
#'
MoM.gamma <- function(mean, var){

  stopifnot(var>=0)
  stopifnot(mean>=0)
  names(mean) <- NULL
  names(var)  <- NULL

  list(shape = mean^2/var,
       scale = var/mean)
}


#' Beta-PERT
#'
#' https://reference.wolfram.com/language/ref/PERTDistribution.html
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
rpert <- function( n, x.min, x.max, x.mode, lambda = 4 ){

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

