## PSA-using-yaml tests

tree_cost <- tree_cost.orig <- yaml.load_file("C:/Users/ngreen1/Dropbox/TB/IDEA/output_data/IDEA_dtree-cost.yaml")
tree_health <- tree_health.orig <- yaml.load_file("C:/Users/ngreen1/Dropbox/TB/IDEA/output_data/IDEA_dtree-health.yaml")


calcCostHealthGrid(tree_cost$Enhanced, tree_health$Enhanced,
                   prop_highrisk = 0,
                   Ctest = 100, spec=0.9, sens=0.9)


# see Radient website
# https://github.com/vnijs/radiant


##simple tree
testyaml <- yaml.load_file("C:/Users/ngreen1/Dropbox/TB/IDEA/output_data/test.yaml")

test.node <- as.Node(testyaml)
print(test.node, "type", "payoff", "p")
test.node$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
print(test.node, "type", "payoff", "p")



