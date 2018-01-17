
## examples taken from:
##
## http://vnijs.github.io/radiant/quant/dtree.html
## radiant::radiant("analytics")   #web app for creating and visualising
## https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html#jenny-lind-decision-tree


file <- system.file("extdata/", "IDEA_dtree-cost.yaml", package="treeSimR") #YAML
l <- IDEA_dtree_cost <- yaml::yaml.load_file(file)
save(IDEA_dtree_cost, file="data/IDEA_dtree_cost.RData")

file <- system.file("extdata/", "IDEA_dtree-health.yaml", package="treeSimR") #YAML
l <- IDEA_dtree_health <- yaml::yaml.load_file(file)
save(IDEA_dtree_health, file="data/IDEA_dtree_health.RData")

# file <- system.file("extdata/", "example.nwk", package="treeSimR")  #Newick
# l <- ape::read.tree(file)


jl <- data.tree::as.Node(l)
print(jl, "type", "payoff", "p")


jl$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

jl$Do(decision, filterFun = function(x) x$type == 'decision')


# PLOTTING ----------------------------------------------------------------

jl$Revert()
jlp <- ape::as.phylo(jl)

# x11()
par(mar=c(1,1,1,1))
plot(jlp, show.tip.label = FALSE, type = "cladogram") #branches only

## set arrow heads to the leaf-edges
for (node in jl$leaves) edges(GetPhyloNr(node$parent, "node"),
                              GetPhyloNr(node, "node"),
                              arrows = 2,
                              type = "triangle",
                              angle = 60)

## finally, we iterate over all the nodes and print the labels
## Note that the `GetPhyloNr`
## methods lets us map a `Node` in the data.tree to its counterpart in the phylo object.

for(node in Traverse(jl)) {
  if(node$type == 'decision') {
    nodelabels(Nodelabel(node), GetPhyloNr(node, "node"), frame = 'none', adj = c(0.3, -0.5))
  } else if(node$type == 'chance') {
    if (node$name == node$parent$decision) edges(GetPhyloNr(node$parent, "node"),
                                                 GetPhyloNr(node, "node"), col = "red")
    nodelabels(" ", GetPhyloNr(node, "node"), frame = "circle")
    nodelabels(Nodelabel(node), GetPhyloNr(node, "node"), frame = 'none', adj = c(0.5, -0.5))
    edgelabels(node$name, GetPhyloNr(node, "edge"), bg = "white")
  } else if(node$type == 'terminal') {
    tiplabels(Nodelabel(node), GetPhyloNr(node, "node"), frame = "none", adj = c(0.5, -0.6))
    edgelabels(paste0(node$name," (", node$p, ")"), GetPhyloNr(node, "edge"), bg = "white")
  }
}

nodelabels("   ", GetPhyloNr(jl, "node"), frame = "rect")


#  ------------------------------------------------------------------------

# library(diagram)
# #
# #
# #
#
#
# library(igraph)
# g <- graph.empty(n=3)
# g <- graph(c(1,2,3,2,1,3), directed=T)
# E(g)$weight <- c(3,2,5)
# plot(g, edge.label = E(g)$weight)
# g
#
# g3 <- graph_from_literal( Alice +-+ Bob --+ Cecil +-- Daniel,
#                           +                           Eugene --+ Gordon:Helen )
#
#
# ## or some kind of XML is all that is really needed
# # http://stackoverflow.com/questions/14291536/how-to-represent-decision-tree-with-yes-no
# library("xml2", lib.loc="~/R/win-library/3.2")
# cd <- read_xml("http://www.xmlfiles.com/examples/cd_catalog.xml")
# xml_structure(cd)
#
# # http://www.sabufrancis.com/decisiontree
# <?xml version="1.0"?>
#   <decision desc="How to proceed from today?">
#   <decision name="New Product">
#   <decision name="Thorough development" cost="75000">
#   <outcome type="poor" probability="0.2" returns="1000"/>
#   <outcome type="moderate" probability="0.4" returns="25000"/>
#   <outcome type="good" probability="0.4" returns="500000" />
#   </decision>
#   <decision name="Rapid development" cost="40000">
#   <outcome type="poor" probability="0.7" returns="1000"/>
#   <outcome type="moderate" probability="0.2" returns="25000"/>
#   <outcome type="good" probability="0.1" returns="500000" />
#   </decision>
#
#
#   </decision>
#   <decision name="Consolidate">
#   <decision name="Strengthen products" cost="15000">
#   <outcome type="poor" probability="0.3" returns="3000"/>
#   <outcome type="moderate" probability="0.4" returns="10000"/>
#   <outcome type="good" probability="0.3" returns="200000" />
#
#   </decision>
#   <decision name="Reap products" cost="0">
#   <outcome type="poor" probability="0.6" returns="10000"/>
#   <outcome type="good" probability="0.4" returns="1000" />
#
#   </decision>
#
#   </decision>
#
#
#   </decision>
#
#
# sensitivity <- 0.9
# specificity <- 0.7
#
# ## example formats
# decisiontree <- list(TB=list(outcomes=TRUE, prob=0.4, cost=0, health=0,
#                              clinjudgehighrisk=list(outcomes=TRUE, prob=0.4, cost=200, health=100),
#                              clinjudgelowrisk=list(outcomes=FALSE, prob=0.6, cost=100, health=50,
#                                                    ruleouttestpositive=list(outcome=TRUE, prob=sensitivity, cost=200, health=100),
#                                                    ruleouttestnegative=list(outcome=FALSE, prob=1-sensitivity, cost=200, health=100+50))),
#                      notTB=list(outcomes=FALSE, prob=0.6, cost=0, health=0,
#                                 clinjudgehighrisk=list(outcomes=TRUE, prob=0.4, cost=200, health=100),
#                                 clinjudgelowrisk=list(outcomes=FALSE, prob=0.6, cost=100, health=50,
#                                                       ruleouttestpositive=list(outcome=TRUE, prob=1-specificity, cost=200, health=100),
#                                                       ruleouttestnegative=list(outcome=FALSE, prob=specificity, cost=0, health=0))
#                      ))
#
#
# # copying xml above
# # xmlToList('file.xml') to convert from external XML file
#
# decisiontree <- list(decision=list(name="TB",
#                                    outcome=list(type="yes", prob=0.7, cost=100, health=0,
#                                                 decision=list(name="clinjudge",
#                                                               outcome=list(type="high", prob=0.4, cost=0, health=0),
#                                                               outcome=list(type="low", prob=0.6, cost=0, health=0,
#                                                                            decision=list(name="ruleouttest",
#                                                                                          outcome=list(type="positive", prob=sensitivity, cost=0, health=0),
#                                                                                          outcome=list(type="negative", prob=1-sensitivity, cost=0, health=0))))),
#                                    outcome=list(type="no", prob=0.3, cost=100, health=0,
#                                                 decision=list(name="clinjudge",
#                                                               outcome=list(type="high", prob=0.4, cost=0, health=0),
#                                                               outcome=list(type="low", prob=0.6, cost=0, health=0,
#                                                                            decision=list(name="ruleouttest",
#                                                                                          outcome=list(type="positive", prob=sensitivity, cost=0, health=0),
#                                                                                          outcome=list(type="negative", prob=1-sensitivity, cost=0, health=0)))))
# ))
#
#
# str(decisiontree)




