
library(yaml)

## test tree
yaml <- "
name: IDEA study cost
type: decision
distn: gamma
mean: 1
sd: 1
Enhanced:
  distn: gamma
  mean: 1
  sd: 1
  type: chance
  TB:
    type: terminal
    p: 0
    distn: gamma
    mean: 1
    sd: 1
  Not TB:
    type: terminal
    p: 1
    distn: gamma
    mean: 1
    sd: 1
Standard:
  distn: gamma
  mean: 1
  sd: 1
  type: chance
  TB:
    type: terminal
    p: 1
    distn: gamma
    mean: 1
    sd: 1
  Not TB:
    type: terminal
    p: 0
    distn: gamma
    mean: 1
    sd: 1
"

## full tree
sink("raw data/IDEA_dtree-cost-distns.yaml")

# yaml <-
cat("
name: IDEA study cost
type: decision
distn: gamma
mean: 1
sd: 1
Enhanced:
  distn: gamma
  mean: 1
  sd: 1
  type: chance
  TB:
    p: 0.25
    distn: gamma
    mean: 1
    sd: 1
    type: chance
    Clinical judgement high risk:
      type: terminal
      p: 0.4
      distn: gamma
      mean: 1
      sd: 1
    Clinical judgement low risk:
      p: 0.6
      type: chance
      distn: gamma
      mean: 1
      sd: 1
      Ruleout test positive:
        type: terminal
        p: 0.7
        distn: gamma
        mean: 1
        sd: 1
      Ruleout test negative:
        type: terminal
        p: 0.3
        distn: gamma
        mean: 1
        sd: 1
  Not TB:
    type: chance
    p: 0.75
    distn: gamma
    mean: 1
    sd: 1
    Clinical judgement high risk:
      type: terminal
      p: 0.4
      distn: gamma
      mean: 1
      sd: 1
    Clinical judgement low risk:
      type: chance
      p: 0.6
      distn: gamma
      mean: 1
      sd: 1
      Ruleout test positive:
        type: terminal
        p: 0.7
        distn: gamma
        mean: 1
        sd: 1
      Ruleout test negative:
        type: terminal
        p: 0.3
        distn: gamma
        mean: 1
        sd: 1
Standard:
  distn: gamma
  mean: 1
  sd: 1
  type: chance
  TB:
    type: terminal
    p: 0.25
    distn: gamma
    mean: 1
    sd: 1
  Not TB:
    type: terminal
    p: 0.75
    distn: gamma
    mean: 1
    sd: 1
", fill=TRUE)
sink()


# osList <- yaml.load(yaml)
osList <- yaml.load_file("raw data/IDEA_dtree-cost-distns.yaml")
osNode <- as.Node(osList)
print(osNode, "type", "p", "distn", "mean", "sd")

sampleNode <- function(node) {
  DISTN <- list(distn=node$distn, params=c(mean=node$mean, sd=node$sd))
  sample.distributions(list(DISTN))
}

rpayoff <- osNode$Get(sampleNode)
osNode$Set(payoff = rpayoff)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

