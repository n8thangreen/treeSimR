#' calcCostHealthGrid
#'
#' blah
#'
#' @param treeCost
#' @param treeHealth
#' @param pwaytimetodiagTB
#' @param pwaycostTB
#' @param pwaytimetodiagNonTB
#' @param pwaycostNonTB
#' @param FNtime
#' @param cat4percent
#' @param prop_highrisk
#' @param Ctest.seq
#' @param sens.seq
#' @param spec.seq
#'
#' @return
#' @export
#'
#' @examples
calcCostHealthGrid <- function(treeCost, treeHealth,
                               pwaytimetodiagTB=NA, pwaycostTB=NA,
                               pwaytimetodiagNonTB=NA, pwaycostNonTB=NA,
                               FNtime=42, cat4percent=75, prop_highrisk=1,#0.4,
                               Ctest.seq=100, sens.seq=0.9, spec.seq=0.9){   #seq(0.8, 1, by=0.1), spec.seq=seq(0.8, 1, by=0.1)){
    require(Hmisc)
    require(data.tree)

    stopifnot(FNtime>=0, cat4percent>=0, prop_highrisk>=0, cat4percent<=100, prop_highrisk<=1)

    Ttest <- 1

    ## pre-test clinical judgement
    ECDF.TB <- ecdf(data$riskfacScore[data$DosanjhGrouped%in%c(1,2)])
    ECDF.nonTB <- ecdf(data$riskfacScore[data$DosanjhGrouped==4])
    spec.clinical <- ECDF.nonTB(prop_highrisk)
    sens.clinical <- 1-ECDF.TB(prop_highrisk)
    if(1-spec.clinical>sens.clinical) warning("More non-TB than TB patients clinical pre-tested as high risk!")

    EC_cost <- EC_health <- NULL
    grid <- expand.grid(spec.seq=spec.seq, sens.seq=sens.seq, Ctest.seq=Ctest.seq)

    treeCost$TB$p <- 1-(cat4percent/100)
    treeCost$`Not TB`$p <- cat4percent/100

    treeCost$TB$`Clinical judgement low risk`$p  <- 1-sens.clinical
    treeCost$TB$`Clinical judgement high risk`$p <- sens.clinical
    treeCost$`Not TB`$`Clinical judgement low risk`$p  <- spec.clinical
    treeCost$`Not TB`$`Clinical judgement high risk`$p <- 1-spec.clinical

    treeHealth$TB$`Clinical judgement low risk`$p  <- 1-sens.clinical
    treeHealth$TB$`Clinical judgement high risk`$p <- sens.clinical
    treeHealth$`Not TB`$`Clinical judgement low risk`$p  <- spec.clinical
    treeHealth$`Not TB`$`Clinical judgement high risk`$p <- 1-spec.clinical


    ## edit baseline in-practice routine values -----------
    if(!is.na(pwaytimetodiagTB)){
      treeHealth$TB$`Clinical judgement high risk`$payoff <- pwaytimetodiagTB
      treeHealth$TB$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaytimetodiagTB
      treeHealth$TB$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaytimetodiagTB
    }
    if(!is.na(pwaytimetodiagNonTB)){
      treeHealth$`Not TB`$`Clinical judgement high risk`$payoff <- pwaytimetodiagNonTB
      treeHealth$`Not TB`$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaytimetodiagNonTB
      treeHealth$`Not TB`$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- 0
    }
    if(!is.na(pwaycostTB)){
      treeCost$TB$`Clinical judgement high risk`$payoff <- pwaycostTB
      treeCost$TB$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaycostTB
      treeCost$TB$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaycostTB
    }
    if(!is.na(pwaycostNonTB)){
      treeCost$`Not TB`$`Clinical judgement high risk`$payoff <- pwaycostNonTB
      treeCost$`Not TB`$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaycostNonTB
      treeCost$`Not TB`$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- 0}


    ## add enhanced pathway costs -----------
    ## fixed values
    inc(treeHealth$TB$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ttest
    inc(treeHealth$TB$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ttest + FNtime
    inc(treeHealth$`Not TB`$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ttest
    inc(treeHealth$`Not TB`$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ttest

    treeCost.orig <- treeCost
    treeHealth.orig <- treeHealth

    ## variable values
    for (Ctest in Ctest.seq){

      treeCost <- treeCost.orig
      treeHealth <- treeHealth.orig

      inc(treeCost$TB$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ctest
      inc(treeCost$TB$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ctest
      inc(treeCost$`Not TB`$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ctest
      inc(treeCost$`Not TB`$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ctest

      for(sens in sens.seq){

        ## sensitivity
        treeCost$TB$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
        treeHealth$TB$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
        ## 1-sensitivity
        treeCost$TB$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens
        treeHealth$TB$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens

        for(spec in spec.seq){

          ## 1-specificity
          treeCost$`Not TB`$`Clinical judgement low risk`$`Ruleout test positive`$p <- 1-spec
          treeHealth$`Not TB`$`Clinical judgement low risk`$`Ruleout test positive`$p <- 1-spec
          ## specificity
          treeCost$`Not TB`$`Clinical judgement low risk`$`Ruleout test negative`$p <- spec
          treeHealth$`Not TB`$`Clinical judgement low risk`$`Ruleout test negative`$p <- spec

          ## fold-back decision tree
          treeCost.node <- as.Node(treeCost)
          treeHealth.node <- as.Node(treeHealth)

          ##logfile
          # print("sens/spec/Ctest/n")
          # print(c(sens, spec, Ctest))
          # print("BEFORE")
          # print(treeCost.node, "type", "payoff", "p")
          # print(treeHealth.node, "type", "payoff", "p")

          treeCost.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
          treeHealth.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

          # print("AFTER")
          # print(treeCost.node, "type", "payoff", "p")
          # print(treeHealth.node, "type", "payoff", "p")

          EC_cost <- c(EC_cost, treeCost.node$payoff)
          EC_health <- c(EC_health, treeHealth.node$payoff)
        }
      }
    }

    return(cbind(grid, EC_cost, EC_health))
}

#' createParamGrid
#'
#' blah
#'
#' @param Nrepl
#' @param Ctest.vec
#' @param sens.vec
#' @param sens.mean
#' @param sens.sd
#' @param spec.vec
#' @param spec.mean
#' @param spec.sd
#' @param cat4percent.vec
#' @param cat4percent.mean
#' @param cat4percent.sd
#' @param prop_highrisk.vec
#' @param prop_highrisk.mean
#' @param prop_highrisk.sd
#' @param FNtime.vec
#' @param FNtime.mean
#' @param FNtime.sd
#'
#' @return
#' @export
#'
#' @examples
createParamGrid <- function(Nrepl=10,
                            Ctest.vec=100,
                            sens.vec=0.9, sens.mean=NA, sens.sd=NA,
                            spec.vec=0.9, spec.mean=NA, spec.sd=NA,
                            cat4percent.vec=75, cat4percent.mean=NA, cat4percent.sd=NA,
                            prop_highrisk.vec=1, prop_highrisk.mean=NA, prop_highrisk.sd=NA,
                            FNtime.vec=42, FNtime.mean=NA, FNtime.sd=NA){
  ##TODO##
  #at the moment only does random sampling, not deterministic scenarios

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

  if(!is.na(sens.mean) & !is.na(sens.sd)){
    params <- MoM.beta(sens.mean, sens.sd^2)
    sens.vec <- rbeta(n=Nrepl, params$a, params$b)
  }
  if(!is.na(spec.mean) & !is.na(spec.sd)){
    params <- MoM.beta(spec.mean, spec.sd^2)
    spec.vec <- rbeta(n=Nrepl, params$a, params$b)
  }
  if(!is.na(cat4percent.mean) & !is.na(cat4percent.sd)){  #0.71, 0.16   #a=5,b=2
    params <- MoM.beta(cat4percent.mean, cat4percent.sd^2)
    cat4percent.vec <- rbeta(n=Nrepl, params$a, params$b)*100
  }
  if(!is.na(prop_highrisk.mean) & !is.na(prop_highrisk.sd)){  #0.41, 0.15   #a=4, b=6
    params <- MoM.beta(prop_highrisk.mean, prop_highrisk.sd^2)
    prop_highrisk.vec <- rbeta(n=Nrepl, params$a, params$b)
  }
  if(!is.na(FNtime.mean) & !is.na(FNtime.sd)){  #42, 10
    FNtime.vec <- rnorm(n=Nrepl, mean=FNtime.mean, sd=FNtime.sd)
  }

  cbind(sens=sens.vec, spec=spec.vec, cat4percent=cat4percent.vec, prop_highrisk=prop_highrisk.vec, FNtime=FNtime.vec)
}



#' Cost-effectiveness plane
#'
#' blah
#'
#' @param N
#' @param tree_cost
#' @param tree_health
#' @param Ctest
#' @param sens
#' @param spec
#' @param table
#'
#' @return
#' @export
#'
#' @examples
#'
CEplane_yaml <- function(N = 2, tree_cost, tree_health,
                         Ctest=100, sens=0.9, spec=0.9, table=FALSE){

  ##TODO##
  #use more generalisable list of names, distn, params
  ## see main IDEA code
  ##...
  grid <- data.frame(createParamGrid(Nrepl=N,
                                     FNtime.mean=41, FNtime.sd=10,
                                     cat4percent.mean=0.71, cat4percent.sd=0.16,
                                     prop_highrisk.mean=0.41, prop_highrisk.sd=0.15,
                                     sens.mean = 0.9, sens.sd = 0.01,
                                     spec.mean = 0.9, spec.sd = 0.01))

  # grid <- data.frame(createParamGrid(Nrepl=N))  #basecase
  # grid <- data.frame(createParamGrid(Nrepl=N, FNtime.mean=42, FNtime.sd=0)) #bootstrap error only

  NCOLgrid <- ncol(grid)

  ## initialise outputs
  testrun <- calcCostHealthGrid(treeCost=tree_cost$Enhanced, treeHealth=tree_health$Enhanced,
                                sens=sens, spec=spec)
  NCOL <- ncol(testrun)
  out  <- matrix(NA, ncol=NCOL, nrow=nrow(grid))
  colnames(out) <- names(testrun)
  out <- data.frame(grid, out)
  enhanced <- current <- out

  currentEChealth <-  currentECcost <- NULL

  for (i in 1:nrow(grid)){

    ## (balanced) bootstrapped final `payoffs'
    sboot.nonTB <- sample(which(data$DosanjhGrouped==4), replace=TRUE)
    sboot.TB <- sample(which(data$DosanjhGrouped%in%c(1,2,3)), replace=TRUE)
    pwaycostNonTB <- mean(data$totalcost[sboot.nonTB], na.rm=TRUE)
    pwaycostTB <- mean(data$totalcost[sboot.TB], na.rm=TRUE)
    pwaytimetodiagNonTB <- mean(data$start.to.diag[sboot.nonTB], na.rm=TRUE)
    pwaytimetodiagTB <- mean(data$start.to.diag[sboot.TB], na.rm=TRUE)

    # bootrows <- sample(1:nrow(data), replace=TRUE)
    # bootdata <- data[bootrows,]
    # stat <- "Mean" #Median"
    # pwaytimetodiagTB <- summary(bootdata$start.to.diag[bootdata$DosanjhGrouped%in%c("1","2","3")], na.rm=T)[stat]
    # pwaycostTB <- summary(bootdata$totalcost[bootdata$DosanjhGrouped%in%c("1","2","3")])[stat]
    # pwaytimetodiagNonTB <- summary(bootdata$start.to.diag[bootdata$DosanjhGrouped=="4"], na.rm=T)[stat]
    # pwaycostNonTB <- summary(bootdata$totalcost[bootdata$DosanjhGrouped=="4"])[stat]


    ## index i if random sampled
    enhanced[i, NCOLgrid+(1:NCOL)] <- calcCostHealthGrid(treeCost=tree_cost$Enhanced, treeHealth=tree_health$Enhanced,
                                                         pwaytimetodiagTB, pwaycostTB,
                                                         pwaytimetodiagNonTB, pwaycostNonTB,
                                                         FNtime = grid$FNtime[i],
                                                         cat4percent = grid$cat4percent[i],
                                                         prop_highrisk = grid$prop_highrisk[i],
                                                         Ctest = Ctest, spec=grid$spec[i], sens=grid$sens[i])

    ## equivalent to above
    currentEChealth <- c(currentEChealth, (grid$cat4percent[i]*pwaytimetodiagNonTB + (100-grid$cat4percent[i])*pwaytimetodiagTB)/100)
    currentECcost <- c(currentECcost, (grid$cat4percent[i]*pwaycostNonTB + (100-grid$cat4percent[i])*pwaycostTB)/100)
  }

  df <- data.frame(x = 0.67*(currentEChealth - enhanced$EC_health),
                   y = (enhanced$EC_cost - currentECcost))

  if(table==FALSE){
    return(
      ggplot(data=df, aes(x,y)) + geom_point(colour="grey") + geom_density2d(aes(colour=..level..)) +
        ylim(-400,100) + xlim(-5,20) +
        scale_colour_gradient(high="black", low="black") + theme_bw() + theme(legend.position="none") +
        xlab("Health differential") + ylab("Cost differential") +
        ggtitle(paste("Rule-out test cost=£", Ctest, "\n and sensitivity=", sens, ", specificity=", spec, sep="")) +
        geom_abline(intercept=0, slope=55) +
        geom_abline(intercept=0, slope=82, linetype="dashed") +
        geom_point(aes(x=median(df$x), y=median(df$y)), colour="red")
    )}
  if(table==TRUE){
    return(round(c(
      topright=sum(df$x>0 & df$y>0)/npatients,
      bottomright=sum(df$x>0 & df$y<0)/npatients,
      topleft=sum(df$x<0 & df$y>0)/npatients,
      bottomleft=sum(df$x<0 & df$y<0)/npatients),2))
  }
}

