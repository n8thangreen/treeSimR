

## have a separate tree for health and cost so that we can then calculate ICER more easily
## only non-zero payoffs at terminal nodes
## payoffs in YAML tree are for current pathway cost only so will need enhanced pathway costs added
tree_cost <- tree_cost.orig <- yaml.load_file("C:/Users/ngreen1/Dropbox/TB/IDEA/output_data/IDEA_dtree-cost_byDosanjh.yaml")
tree_health <- tree_health.orig <- yaml.load_file("C:/Users/ngreen1/Dropbox/TB/IDEA/output_data/IDEA_dtree-health_byDosanjh.yaml")

tree_cost.node <- tree_cost.node.orig <- as.Node(tree_cost)
tree_health.node <- tree_health.node.orig <- as.Node(tree_health)
print(tree_cost.node, "type", "payoff", "p")
print(tree_health.node, "type", "payoff", "p")

tree_cost.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
tree_health.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
print(tree_cost.node, "type", "payoff", "p")
print(tree_health.node, "type", "payoff", "p")



#  functions -----------------------------------------------------


#' Calculate Health and Cost of Decision Tree
#'
#' @param tree_cost YAML decision tree
#' @param tree_health YAML decision tree
#'
#' @return grid of health and cost
#' @example calcCostHealthGrid_Dosanjh(tree_cost, tree_health)

calcCostHealthGrid_Dosanjh <- function(tree_cost, tree_health,
                               pwaytimetodiag1=NA, pwaycost1=NA, pwaytimetodiag2=NA, pwaycost2=NA, pwaytimetodiag3=NA, pwaycost3=NA, pwaytimetodiag4=NA, pwaycost4=NA,
                               pwaytimetodiagNonTB=NA, pwaycostNonTB=NA,
                               FNtime=42, cat4percent=75, prop_highrisk=0.4,
                               Ctest.seq=c(100, 200), sens.seq=seq(0.8, 1, by=0.1), spec.seq=seq(0.8, 1, by=0.1)){
  require(Hmisc)

  Ttest <- 1

  ECDF.TB <- ecdf(data$riskfacScore[data$DosanjhGrouped%in%c(1,2)])
  ECDF.nonTB <- ecdf(data$riskfacScore[data$DosanjhGrouped==4])
  spec.clinical <- ECDF.nonTB(prop_highrisk)
  sens.clinical <- 1-ECDF.TB(prop_highrisk)

  EC_cost <- EC_health <- NULL
  grid <- expand.grid(spec.seq=spec.seq, sens.seq=sens.seq, Ctest.seq=Ctest.seq)

  tree_cost$Dosanjh1$p <- tree_cost$Dosanjh1$p * (1-cat4percent/100)/(1-tree_cost$Dosanjh1$p)
  tree_cost$Dosanjh2$p <- tree_cost$Dosanjh2$p * (1-cat4percent/100)/(1-tree_cost$Dosanjh2$p)
  tree_cost$Dosanjh3$p <- tree_cost$Dosanjh3$p * (1-cat4percent/100)/(1-tree_cost$Dosanjh3$p)
  tree_cost$Dosanjh4$p <- cat4percent/100

  tree_cost$Dosanjh1$`Clinical judgement low risk`$p <- 1-sens.clinical
  tree_cost$Dosanjh2$`Clinical judgement low risk`$p <- 1-sens.clinical
  tree_cost$Dosanjh3$`Clinical judgement low risk`$p <- 1-sens.clinical
  tree_cost$Dosanjh4$`Clinical judgement low risk`$p <- spec.clinical

  tree_cost$Dosanjh1$`Clinical judgement high risk`$p <- sens.clinical
  tree_cost$Dosanjh2$`Clinical judgement high risk`$p <- sens.clinical
  tree_cost$Dosanjh3$`Clinical judgement high risk`$p <- sens.clinical
  tree_cost$Dosanjh4$`Clinical judgement high risk`$p <- 1-spec.clinical

  if(!is.na(pwaytimetodiag1)){
    tree_health$Dosanjh1$`Clinical judgement high risk`$payoff <- pwaytimetodiag1
    tree_health$Dosanjh1$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaytimetodiag1
    tree_health$Dosanjh1$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaytimetodiag1}
  if(!is.na(pwaytimetodiag2)){
    tree_health$Dosanjh2$`Clinical judgement high risk`$payoff <- pwaytimetodiag2
    tree_health$Dosanjh2$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaytimetodiag2
    tree_health$Dosanjh2$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaytimetodiag2}
  if(!is.na(pwaytimetodiag3)){
    tree_health$Dosanjh3$`Clinical judgement high risk`$payoff <- pwaytimetodiag3
    tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaytimetodiag3
    tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaytimetodiag3}
  if(!is.na(pwaytimetodiag4)){
    tree_health$Dosanjh4$`Clinical judgement high risk`$payoff <- pwaytimetodiag4
    tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaytimetodiag4
    tree_health$Dosanjh4$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- 0}

  if(!is.na(pwaycost1)){
    tree_cost$Dosanjh1$`Clinical judgement high risk`$payoff <- pwaycost1
    tree_cost$Dosanjh1$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaycost1
    tree_cost$Dosanjh1$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaycost1}
  if(!is.na(pwaycost2)){
    tree_cost$Dosanjh2$`Clinical judgement high risk`$payoff <- pwaycost2
    tree_cost$Dosanjh2$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaycost2
    tree_cost$Dosanjh2$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaycost2}
  if(!is.na(pwaycost3)){
    tree_cost$Dosanjh3$`Clinical judgement high risk`$payoff <- pwaycost3
    tree_cost$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaycost3
    tree_cost$Dosanjh3$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- pwaycost3}
  if(!is.na(pwaycost4)){
    tree_cost$Dosanjh4$`Clinical judgement high risk`$payoff <- pwaycost4
    tree_cost$Dosanjh4$`Clinical judgement low risk`$`Ruleout test positive`$payoff <- pwaycost4
    tree_cost$Dosanjh4$`Clinical judgement low risk`$`Ruleout test negative`$payoff <- 0}


  inc(tree_health$Dosanjh1$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ttest
  inc(tree_health$Dosanjh1$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ttest + FNtime
  inc(tree_health$Dosanjh2$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ttest
  inc(tree_health$Dosanjh2$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ttest + FNtime
  inc(tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ttest
  inc(tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ttest + FNtime
  inc(tree_health$Dosanjh4$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ttest
  inc(tree_health$Dosanjh4$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ttest

  tree_cost.orig <- tree_cost
  tree_health.orig <- tree_health

  for (Ctest in Ctest.seq){

    tree_cost <- tree_cost.orig
    tree_health <- tree_health.orig

    inc(tree_cost$Dosanjh1$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ctest
    inc(tree_cost$Dosanjh1$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ctest
    inc(tree_cost$Dosanjh2$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ctest
    inc(tree_cost$Dosanjh2$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ctest
    inc(tree_cost$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ctest
    inc(tree_cost$Dosanjh3$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ctest
    inc(tree_cost$Dosanjh4$`Clinical judgement low risk`$`Ruleout test positive`$payoff) <- Ctest
    inc(tree_cost$Dosanjh4$`Clinical judgement low risk`$`Ruleout test negative`$payoff) <- Ctest

    for(sens in sens.seq){

      tree_cost$Dosanjh1$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
      tree_health$Dosanjh1$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
      tree_cost$Dosanjh2$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
      tree_health$Dosanjh2$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
      tree_cost$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens
      tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test positive`$p <- sens

      tree_cost$Dosanjh1$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens
      tree_health$Dosanjh1$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens
      tree_cost$Dosanjh2$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens
      tree_health$Dosanjh2$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens
      tree_cost$Dosanjh3$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens
      tree_health$Dosanjh3$`Clinical judgement low risk`$`Ruleout test negative`$p <- 1-sens

      for(spec in spec.seq){

        tree_cost$Dosanjh4$`Clinical judgement low risk`$`Ruleout test positive`$p <- 1-spec
        tree_health$Dosanjh4$`Clinical judgement low risk`$`Ruleout test positive`$p <- 1-spec
        tree_cost$Dosanjh4$`Clinical judgement low risk`$`Ruleout test negative`$p <- spec
        tree_health$Dosanjh4$`Clinical judgement low risk`$`Ruleout test negative`$p <- spec

        tree_cost.node <- as.Node(tree_cost)
        tree_health.node <- as.Node(tree_health)
        tree_cost.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
        tree_health.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

        EC_cost <- c(EC_cost, tree_cost.node$payoff)
        EC_health <- c(EC_health, tree_health.node$payoff)
      }
    }
  }

  return(cbind(grid, EC_cost, EC_health))
}


#' Cost-Effectiveness Plane using YAML Decision Tree
#'
#' @param N Number of calculated points
#' @param tree_cost YAML decision tree
#' @param tree_health YAML decision tree
#' @param Ctest Unit cost rule-out test
#' @param sens Rule-out test sensitivity
#' @param spec Rule-out test specificity
#' @param table Output type (TRUE or FALSE)
#'
#' @return None
#' @example CEplane_yaml_Dosanjh(N = 500, tree_cost.orig, tree_health.orig)

CEplane_yaml_Dosanjh <- function(N = 200, tree_cost, tree_health,
                         Ctest=200, sens=0.9, spec=0.9, table=FALSE){

  require(ggplot2)

  grid <- data.frame(cbind(FNtime=rnorm(n = N, mean=42, sd=10),
                           cat4percent=rbeta(n=N, 5,2)*100,
                           prop_highrisk=rbeta(n=N, 4,6)))
  NCOLgrid <- ncol(grid)
  testrun <- calcCostHealthGrid_Dosanjh(tree_cost$Enhanced, tree_health$Enhanced, sens=sens, spec=spec)
  NCOL <- ncol(testrun)
  out  <- matrix(NA, ncol=NCOL, nrow=nrow(grid))
  colnames(out) <- names(testrun)
  out <- data.frame(grid, out)
  enhanced <- current <- out

  for (i in 1:nrow(grid)){

    bootrows <- sample(1:nrow(data), nrow(data), replace=TRUE)
    bootdata <- data[bootrows,]

    ## bootstrapped final payoffs
    pwaytimetodiag1 <- summary(bootdata$start.to.diag[bootdata$DosanjhGrouped=="1"], na.rm=T)["Median"]
    pwaycost1 <- summary(bootdata$totalcost[bootdata$DosanjhGrouped=="1"])["Median"]
    pwaytimetodiag2 <- summary(bootdata$start.to.diag[bootdata$DosanjhGrouped=="2"], na.rm=T)["Median"]
    pwaycost2 <- summary(bootdata$totalcost[bootdata$DosanjhGrouped=="2"])["Median"]
    pwaytimetodiag3 <- summary(bootdata$start.to.diag[bootdata$DosanjhGrouped=="3"], na.rm=T)["Median"]
    pwaycost3 <- summary(bootdata$totalcost[bootdata$DosanjhGrouped=="3"])["Median"]
    pwaytimetodiag4 <- summary(bootdata$start.to.diag[bootdata$DosanjhGrouped=="4"], na.rm=T)["Median"]
    pwaycost4 <- summary(bootdata$totalcost[bootdata$DosanjhGrouped=="4"])["Median"]

    enhanced[i, NCOLgrid+(1:NCOL)] <- calcCostHealthGrid_Dosanjh(tree_cost$Enhanced, tree_health$Enhanced,
                                                                 pwaytimetodiag1, pwaycost1,
                                                                 pwaytimetodiag2, pwaycost2,
                                                                 pwaytimetodiag3, pwaycost3,
                                                                 pwaytimetodiag4, pwaycost4,
                                                                 FNtime = grid$FNtime[i],
                                                                 cat4percent = grid$cat4percent[i],
                                                                 prop_highrisk = grid$prop_highrisk[i],
                                                                 Ctest = Ctest, spec=spec, sens=sens)

    current[i, NCOLgrid+(1:NCOL)] <- calcCostHealthGrid_Dosanjh(tree_cost$Enhanced, tree_health$Enhanced,
                                                                pwaytimetodiag1, pwaycost1,
                                                                pwaytimetodiag2, pwaycost2,
                                                                pwaytimetodiag3, pwaycost3,
                                                                pwaytimetodiag4, pwaycost4,
                                                                prop_highrisk = 1,
                                                                Ctest = Ctest, spec=spec, sens=sens)
  }

  df <- data.frame(x = 0.67*(current$EC_health - enhanced$EC_health),
                   y = (enhanced$EC_cost - current$EC_cost))

  if(table==FALSE){
    return(
      ggplot(data=df, aes(x,y)) + geom_point(colour="grey") + geom_density2d(aes(colour=..level..)) +
        scale_colour_gradient(high="black", low="black") + theme_bw() + theme(legend.position="none") +
        xlab("Health differential") + ylab("Cost differential") +
        ggtitle(paste("Rule-out test cost =?", Ctest, "\n and sensitivity=", sens, ", specificity=", spec, sep="")) +
        # ylim(-150,150) + xlim(4,5) +
        geom_abline(intercept=0, slope=55) +
        geom_abline(intercept=0, slope=82, linetype="dashed")
    )}
  if(table==TRUE){
    return(round(c(
      topright=sum(df$x>0 & df$y>0)/npatients,
      bottomright=sum(df$x>0 & df$y<0)/npatients,
      topleft=sum(df$x<0 & df$y>0)/npatients,
      bottomleft=sum(df$x<0 & df$y<0)/npatients),2))
  }
}


