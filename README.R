## ----set-options, echo=FALSE, cache=FALSE--------------------------------
options(width = 1000)

## ----eval=FALSE----------------------------------------------------------
## library(devtools)
## install_github("n8thangreen/treeSimR")

## ----eval=FALSE----------------------------------------------------------
## library("treeSimR")

## ----load packages, echo=FALSE, warning=FALSE----------------------------
library(yaml)
library(data.tree)
devtools::load_all(".")


## ------------------------------------------------------------------------
# osList <- yaml.load(yaml)
osList <- yaml.load_file("raw data/LTBI_dtree-cost-distns.yaml")
osNode <- as.Node(osList)
osNode

## ------------------------------------------------------------------------
osNode <- treeSimR::costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
print(osNode, "type", "p", "distn", "mean", "sd")

## ----eval=FALSE----------------------------------------------------------
## library(listviewer)
## l <- ToListSimple(osNode)
## jsonedit(l)

## ------------------------------------------------------------------------
rpayoff <- osNode$Get(sampleNode)
osNode$Set(payoff = rpayoff)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

## ------------------------------------------------------------------------
osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

## ------------------------------------------------------------------------
osNode <- calc_expectedValues(osNode)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

## ------------------------------------------------------------------------
MonteCarlo_expectedValues(osNode, n=100)

## ------------------------------------------------------------------------
path_probs <- calc_pathway_probs(osNode)
osNode$Set(path_probs = path_probs)

terminal_states <- data.frame(pathname = osNode$Get('pathString', filterFun = isLeaf),
                              path_probs = osNode$Get('path_probs', filterFun = isLeaf))
terminal_states

## ------------------------------------------------------------------------
startstate_prob <- matrix(NA, nrow = 3, ncol = 2,
                          dimnames = list(c("<40k","40-150k",">150k"), c("LTBI","nonLTBI")))

startstate.LTBI <- grepl("/Complete Treatment", x = terminal_states$pathname) | grepl("non-LTBI", x = terminal_states$pathname)

startstate_prob["<40k","nonLTBI"] <- sum(terminal_states$path_probs[grepl("under 40k cob incidence", x = terminal_states$pathname) &
                                                                  startstate.LTBI])

startstate_prob["<40k","LTBI"] <- sum(terminal_states$path_probs[grepl("under 40k cob incidence", x = terminal_states$pathname) &
                                                               !startstate.LTBI])

startstate_prob["40-150k","nonLTBI"] <- sum(terminal_states$path_probs[grepl("40-150k cob incidence", x = terminal_states$pathname) &
                                                                     startstate.LTBI])

startstate_prob["40-150k","LTBI"] <- sum(terminal_states$path_probs[grepl("40-150k cob incidence", x = terminal_states$pathname) &
                                                                  !startstate.LTBI])

startstate_prob[">150k","nonLTBI"] <- sum(terminal_states$path_probs[grepl("over 150k cob incidence", x = terminal_states$pathname) &
                                                                   startstate.LTBI])

startstate_prob[">150k","LTBI"] <- sum(terminal_states$path_probs[grepl("over 150k cob incidence", x = terminal_states$pathname) &
                                                                  !startstate.LTBI])

knitr::kable(startstate_prob/sum(startstate_prob))

## ------------------------------------------------------------------------
osNode <- calc_riskprofile(osNode)
print(osNode, "type", "path_prob", "path_payoff")

## ------------------------------------------------------------------------
plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
           osNode$Get('path_prob', filterFun = isLeaf)), type="h",
     xlab="payoff", ylab="probability")

## ----eval=FALSE----------------------------------------------------------
## ##TODO##
## osNode$Do(decision, filterFun = function(x) x$type == 'decision')
## osNode$Get('decision')[1]

## ----eval=FALSE----------------------------------------------------------
## ##TODO##
## ## probabilty of successfully & correctly treating LTBI
## dummy <- rep(0, osNode$totalCount)
## dummy[12] <- 1
## osNode$Set(payoff = dummy)
## print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
## osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
## print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
## osNode$Get('payoff')[1]

