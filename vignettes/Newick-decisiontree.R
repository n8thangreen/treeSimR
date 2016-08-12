## Newick tree format

t <- "owls(((neg:4.2,pos:4.2):3.1,not taken:7.3):6.3,not taken:13.5);"
# t <- "owls(None taken:0.36079,(culture only:0.33636,(:0.17147,(Chimp:0.19268, Human:0.11927):0.08386):0.06124):0.16);"

## 3-way (positive, negative, not taken)
t <- "owls((((E,D,F),(D,G,F),(E,D,F)),((E,D,F),(D,G,F),(E,D,F)),((E,D,F),(D,G,F),(E,D,F))),
          (((E,D,F),(D,G,F),(E,D,F)),((E,D,F),(D,G,F),(E,D,F)),((E,D,F),(D,G,F),(E,D,F))),
          (((E,D,F),(D,G,F),(E,D,F)),((E,D,F),(D,G,F),(E,D,F)),((E,D,F),(D,G,F),(E,D,F))));"

# t <- "owls( (((E,D),(D,G)),(((E,D),(D,G)),((E,D),(D,G)))),
#             (( ((E,D),(D,G)), (((E,D),(D,G)),((E,D),(D,G)))), ((((E,D),(D,G)),((E,D),(D,G))), (((E,D),(D,G)),((E,D),(D,G))))) );"
#
# t <- "owls( (((((E,D),(D,G)),((E,D),(D,G))), (((E,D),(D,G)),((E,D),(D,G)))), ((((E,D),(D,G)),((E,D),(D,G))),(((E,D),(D,G)),((E,D),(D,G))))),
#             (((((E,D),(D,G)),((E,D),(D,G))), (((E,D),(D,G)),((E,D),(D,G)))), ((((E,D),(D,G)),((E,D),(D,G))), (((E,D),(D,G)),((E,D),(D,G))))) );"

cat(t, file = "example.nwk", sep = "\n")
t.owls <- ape::read.tree("example.nwk")

# x11()
# width <- rep(1, nrow(t.owls$edge))
# width[7] <- 10

# collapse.singles(t.owls)

width <- res$x/10
plot(t.owls, edge.width = width)




