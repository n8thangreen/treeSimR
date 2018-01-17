#
# YAML decision tree representation
# and probabilistic sensitivity analysis
# with cost-effectiveness plane plot
#
#

library(data.tree)

## have a separate tree for health and cost so that we can then calculate ICER more easily
## only non-zero payoffs at terminal nodes
## payoffs in YAML tree are for _current_ pathway cost only so will need enhanced pathway costs added

tree_cost <- tree_cost.orig <- IDEA_dtree_cost
tree_health <- tree_health.orig <- IDEA_dtree_health

tree_cost.node <- tree_cost.node.orig <- as.Node(tree_cost)
tree_health.node <- tree_health.node.orig <- as.Node(tree_health)
print(tree_cost.node, "type", "payoff", "p")
print(tree_health.node, "type", "payoff", "p")

tree_cost.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
tree_health.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
print(tree_cost.node, "type", "payoff", "p")
print(tree_health.node, "type", "payoff", "p")


##
CEplane_yaml(N = 1000,
             tree_cost = tree_cost.orig,
             tree_health = tree_health.orig)


