
osNode <- create.costeffectiveness.tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
print(osNode, "type", "p", "distn", "mean", "sd")

osNode <- calc.expectedValues(osNode)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

## calculate optimal (max) decision at decision nodes
osNode$Do(decision, filterFun = function(x) x$type == 'decision')
osNode$Get('decision')[1]

## ad-hoc
## probabilty of successfully & correctly treating LTBI
dummy <- rep(0, osNode$totalCount)
dummy[12] <- 1
osNode$Set(payoff = dummy)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
osNode$Get('payoff')[1]

