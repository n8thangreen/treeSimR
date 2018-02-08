pkgname <- "treeSimR"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
base::assign(".ExTimings", "treeSimR-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('treeSimR')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
cleanEx()
nameEx("MonteCarlo_expectedValues.costeffectiveness_tree")
### * MonteCarlo_expectedValues.costeffectiveness_tree

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: MonteCarlo_expectedValues.costeffectiveness_tree
### Title: Monte Carlo Forward Simulation of Decision Tree
### Aliases: MonteCarlo_expectedValues.costeffectiveness_tree

### ** Examples

## read-in decision tree
osNode <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
print(osNode, "type", "p", "distn", "mean", "sd")

## calculate a single realisation expected values
osNode <- calc_expectedValues(osNode)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

## calculate multiple realisation for specific nodes
MonteCarlo_expectedValues(osNode, n=100)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("MonteCarlo_expectedValues.costeffectiveness_tree", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("calc_expectedValues.costeffectiveness_tree")
### * calc_expectedValues.costeffectiveness_tree

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: calc_expectedValues.costeffectiveness_tree
### Title: Calculate Expected Values for Each Node of Decision Tree
### Aliases: calc_expectedValues.costeffectiveness_tree

### ** Examples

## read-in decision tree
osNode <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
print(osNode, "type", "p", "distn", "mean", "sd")

## calculate a single realisation expected values
osNode <- calc_expectedValues(osNode)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

## calculate multiple realisation for specific nodes
MonteCarlo_expectedValues(osNode, n=100)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("calc_expectedValues.costeffectiveness_tree", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("costeffectiveness_tree")
### * costeffectiveness_tree

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: costeffectiveness_tree
### Title: Constructor for a Cost-Effectiveness Tree Object
### Aliases: costeffectiveness_tree

### ** Examples

osNode <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
print(osNode, "type", "p", "distn", "mean", "sd")

osNode <- calc.expectedValues(osNode)
print(osNode, "type", "p", "distn", "mean", "sd", "payoff")




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("costeffectiveness_tree", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
