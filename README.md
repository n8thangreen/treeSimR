`treeSimR`
==========

An R package for easy forward simulating probability decision trees,
calculating cost-effectiveness and PSA.

Currently contains functions to:

-   read-in and check tree object
-   simulate final expected outcomes
-   Monte-Carlo simulate multiple simulations

*TODO*

-   iteratively collapse expected outcome (from right to left)
-   iteratively collapse chance nodes (from right to left)
-   optimal decision function (iterative from right to left)
-   plotting functions: C-E plane, C-E curve, risk profile (with
    uncertainty), tornado, spider, ...

The package leans heavily on the `data.tree` package, (introduction
[here](https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html)
and examples
[here](https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html)
).

Installing `treeSimR`
---------------------

To install the development version from github:

    library(devtools)
    install_github("n8thangreen/treeSimR")

Then, to load the package, use:

    library("treeSimR")

Read-in trees
-------------

    ## Warning: package 'yaml' was built under R version 3.3.1

    ## Warning: package 'data.tree' was built under R version 3.3.1

    ## Loading treeSimR

The raw decision tree file is a tab-spaced file such as the following:

    sink("raw data/LTBI_dtree-cost-distns.yaml")

    cat("
        name: LTBI screening cost
        type: decision
        distn: gamma
        mean: 1
        sd: 1
        Screening:
          distn: gamma
          mean: 1
          sd: 1
          type: chance
          LTBI:
            p: 0.25
            distn: gamma
            mean: 1
            sd: 1
            type: chance
            Not GP registered:
              type: terminal
              p: 0.4
              distn: gamma
              mean: 1
              sd: 1
            GP registered:
              type: chance
              p: 0.4
              distn: gamma
              mean: 1
              sd: 1
              Not Agree to Screen:
                p: 0.6
                type: terminal
                distn: gamma
                mean: 1
                sd: 1
              Agree to Screen:
                p: 0.6
                type: chance
                distn: gamma
                mean: 1
                sd: 1
                Test Negative:
                  type: terminal
                  p: 0.7
                  distn: gamma
                  mean: 1
                  sd: 1
                Test Positive:
                  type: chance
                  p: 0.7
                  distn: gamma
                  mean: 1
                  sd: 1
                  Not Start Treatment:
                    type: terminal
                    p: 0.3
                    distn: gamma
                    mean: 1
                    sd: 1
                  Start Treatment:
                    type: chance
                    p: 0.3
                    distn: gamma
                    mean: 1
                    sd: 1
                    Complete Treatment:
                      type: terminal
                      p: 0.75
                      distn: gamma
                      mean: 1
                      sd: 1
                    Not Complete Treatment:
                      type: terminal
                      p: 0.75
                      distn: gamma
                      mean: 1
                      sd: 1
          non-LTBI:
            p: 0.25
            distn: gamma
            mean: 1
            sd: 1
            type: chance
            Not GP registered:
              type: terminal
              p: 0.4
              distn: gamma
              mean: 1
              sd: 1
            GP registered:
              type: terminal
              p: 0.4
              distn: gamma
              mean: 1
              sd: 1
              Not Agree to Screen:
                p: 0.6
                type: chance
                distn: gamma
                mean: 1
                sd: 1
              Agree to Screen:
                p: 0.6
                type: chance
                distn: gamma
                mean: 1
                sd: 1
                Test Negative:
                  type: terminal
                  p: 0.7
                  distn: gamma
                  mean: 1
                  sd: 1
                Test Positive:
                  type: terminal
                  p: 0.7
                  distn: gamma
                  mean: 1
                  sd: 1
                  Not Start Treatment:
                    type: terminal
                    p: 0.3
                    distn: gamma
                    mean: 1
                    sd: 1
                  Start Treatment:
                    type: terminal
                    p: 0.3
                    distn: gamma
                    mean: 1
                    sd: 1
                    Complete Treatment:
                      type: terminal
                      p: 0.75
                      distn: gamma
                      mean: 1
                      sd: 1
                    Not Complete Treatment:
                      type: terminal
                      p: 0.75
                      distn: gamma
                      mean: 1
                      sd: 1
        No Screening:
          p: 0.25
          distn: gamma
          mean: 1
          sd: 1
          type: chance
          LTBI:
            type: terminal
            p: 0.4
            distn: gamma
            mean: 1
            sd: 1
          non-LTBI:
            p: 0.6
            type: terminal
            distn: gamma
            mean: 1
            sd: 1
        ", fill=TRUE)
    sink()

We save this to a .yaml text file and then read it in as a yaml file to
a data.tree object using the yaml and data.tree packages. This is then
represented as a list in R.

    # osList <- yaml.load(yaml)
    osList <- yaml.load_file("raw data/LTBI_dtree-cost-distns.yaml")
    osNode <- as.Node(osList)
    osNode

    ##                                                 levelName
    ## 1  LTBI screening cost                                   
    ## 2   ¦--under 40k cob incidence                           
    ## 3   ¦   ¦--Screening                                     
    ## 4   ¦   ¦   ¦--LTBI                                      
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                     
    ## 6   ¦   ¦   ¦   °--GP registered                         
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen               
    ## 8   ¦   ¦   ¦       °--Agree to Screen                   
    ## 9   ¦   ¦   ¦           ¦--Test Negative                 
    ## 10  ¦   ¦   ¦           °--Test Positive                 
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment       
    ## 12  ¦   ¦   ¦               °--Start Treatment           
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment    
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment
    ## 15  ¦   ¦   °--non-LTBI                                  
    ## 16  ¦   ¦       ¦--Not GP registered                     
    ## 17  ¦   ¦       °--GP registered                         
    ## 18  ¦   ¦           ¦--Not Agree to Screen               
    ## 19  ¦   ¦           °--Agree to Screen                   
    ## 20  ¦   ¦               ¦--Test Negative                 
    ## 21  ¦   ¦               °--Test Positive                 
    ## 22  ¦   ¦                   ¦--Not Start Treatment       
    ## 23  ¦   ¦                   °--Start Treatment           
    ## 24  ¦   ¦                       ¦--Complete Treatment    
    ## 25  ¦   ¦                       °--Not Complete Treatment
    ## 26  ¦   °--No Screening                                  
    ## 27  ¦       ¦--LTBI                                      
    ## 28  ¦       °--non-LTBI                                  
    ## 29  ¦--40-150k cob incidence                             
    ## 30  ¦   ¦--Screening                                     
    ## 31  ¦   ¦   ¦--LTBI                                      
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                     
    ## 33  ¦   ¦   ¦   °--GP registered                         
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen               
    ## 35  ¦   ¦   ¦       °--Agree to Screen                   
    ## 36  ¦   ¦   ¦           ¦--Test Negative                 
    ## 37  ¦   ¦   ¦           °--Test Positive                 
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment       
    ## 39  ¦   ¦   ¦               °--Start Treatment           
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment    
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment
    ## 42  ¦   ¦   °--non-LTBI                                  
    ## 43  ¦   ¦       ¦--Not GP registered                     
    ## 44  ¦   ¦       °--GP registered                         
    ## 45  ¦   ¦           ¦--Not Agree to Screen               
    ## 46  ¦   ¦           °--Agree to Screen                   
    ## 47  ¦   ¦               ¦--Test Negative                 
    ## 48  ¦   ¦               °--Test Positive                 
    ## 49  ¦   ¦                   ¦--Not Start Treatment       
    ## 50  ¦   ¦                   °--Start Treatment           
    ## 51  ¦   ¦                       ¦--Complete Treatment    
    ## 52  ¦   ¦                       °--Not Complete Treatment
    ## 53  ¦   °--No Screening                                  
    ## 54  ¦       ¦--LTBI                                      
    ## 55  ¦       °--non-LTBI                                  
    ## 56  °--over 150k cob incidence                           
    ## 57      ¦--Screening                                     
    ## 58      ¦   ¦--LTBI                                      
    ## 59      ¦   ¦   ¦--Not GP registered                     
    ## 60      ¦   ¦   °--GP registered                         
    ## 61      ¦   ¦       ¦--Not Agree to Screen               
    ## 62      ¦   ¦       °--Agree to Screen                   
    ## 63      ¦   ¦           ¦--Test Negative                 
    ## 64      ¦   ¦           °--Test Positive                 
    ## 65      ¦   ¦               ¦--Not Start Treatment       
    ## 66      ¦   ¦               °--Start Treatment           
    ## 67      ¦   ¦                   ¦--Complete Treatment    
    ## 68      ¦   ¦                   °--Not Complete Treatment
    ## 69      ¦   °--non-LTBI                                  
    ## 70      ¦       ¦--Not GP registered                     
    ## 71      ¦       °--GP registered                         
    ## 72      ¦           ¦--Not Agree to Screen               
    ## 73      ¦           °--Agree to Screen                   
    ## 74      ¦               ¦--Test Negative                 
    ## 75      ¦               °--Test Positive                 
    ## 76      ¦                   ¦--Not Start Treatment       
    ## 77      ¦                   °--Start Treatment           
    ## 78      ¦                       ¦--Complete Treatment    
    ## 79      ¦                       °--Not Complete Treatment
    ## 80      °--No Screening                                  
    ## 81          ¦--LTBI                                      
    ## 82          °--non-LTBI

Better still, use the treeSimR package function to do this, checking for
tree integrity and defining an additional costeffectiveness.tree class.

    osNode <- treeSimR::create.costeffectiveness.tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
    print(osNode, "type", "p", "distn", "mean", "sd")

    ##                                                 levelName     type    p distn mean sd
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1

A neat way of exploring the tree is with the `listviewer` package
widget.

    library(listviewer)
    l <- ToListSimple(osNode)
    jsonedit(l)

Simulate a scenario
-------------------

We can now sample values for each branch, given the distributions
defined for each. This could be the cost or health detriment.

    rpayoff <- osNode$Get(sampleNode)
    osNode$Set(payoff = rpayoff)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 1.57930023
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.20993462
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 1.10714337
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.71067502
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.67145575
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.40332973
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.18866767
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.31592786
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.64661469
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.36720432
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.86453577
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.40899666
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.11138912
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.25519418
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.33931784
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.82920300
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.65934403
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.01487274
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.33193907
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.40562640
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.08418405
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.29575911
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.56971454
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.37926027
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.41248400
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.53457368
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.43417157
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.48987114
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.23815467
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.22884843
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.91143094
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.75575091
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.24478884
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.82041125
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.41669714
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.55770273
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.25766529
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.81873457
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.37678080
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.38684289
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.94219199
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.10226487
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.26878442
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.91511419
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.49440394
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 3.38235831
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.14634082
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.03455561
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.59223300
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.28406791
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.28891363
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.27173665
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 3.42341294
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.69055819
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 3.26891316
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.95537016
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 2.32670329
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.23536457
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.88577212
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.38819433
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.47481872
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.76238444
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.17349496
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.18963858
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.78674785
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.09540673
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.10023026
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.22106595
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.77355945
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.52890024
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.97823809
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.37184682
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.19503607
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.63282829
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.85390780
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.47873238
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.01302433
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.23437624
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.68358027
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.97424318
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.49495311
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.02452955

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.36337416
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.36329491
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.38558834
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.61852326
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.67145575
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.87485240
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.18866767
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.26941967
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.64661469
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.16684197
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.86453577
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.02493748
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.11138912
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.25519418
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.92383008
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.82920300
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.48037222
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.01487274
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.78574762
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.40562640
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.71687019
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.29575911
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.09380820
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.37926027
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.41248400
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.06759131
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.43417157
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.48987114
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.76284229
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.41379799
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.82299486
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.75575091
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.30173625
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.82041125
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.34914916
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.55770273
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.36965322
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.81873457
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.74677616
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.38684289
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.94219199
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.83219710
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.26878442
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.81170832
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.49440394
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.52510992
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.14634082
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.60381621
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.59223300
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.42048771
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.28891363
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.27173665
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.63757117
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.69055819
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 3.26891316
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.32735943
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.49673873
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.98700958
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.88577212
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.58175184
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.47481872
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.49476767
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.17349496
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.53331600
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.78674785
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.99097216
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.10023026
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.22106595
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.99994535
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.52890024
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.97096314
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.37184682
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.91309175
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.63282829
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.10015993
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.47873238
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.18846738
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.23437624
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.68358027
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.81269897
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.49495311
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.02452955

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.18219651
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.12404819
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.36533344
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.27769232
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.82899670
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.36523410
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.19458441
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.08080575
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.15974755
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.81283210
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.41788996
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.29155036
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.52023444
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.53516604
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.18364143
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.09971454
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.35938903
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.16760742
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.43137430
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.06028325
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.55596575
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.02918432
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.82403485
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.38305820
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.04898826
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.13085934
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.16898828
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.10544004
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.39343063
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.36430297
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.65515191
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.90652612
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.73135366
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.31662445
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.90229831
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.07560072
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.21339686
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.55068294
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.16063993
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.09731089
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.11687568
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.80205998
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.31443755
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.69071240
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.90985553
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.90799848
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.64262578
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.65451490
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.15286240
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.02885395
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.41997111
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.28516748
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.20941955
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.71046173
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.54205809
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.21130721
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.36967018
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.82665867
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.52063042
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.54601624
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.09778904
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.47890470
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.01511722
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.66903235
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.02752353
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.20258431
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.54167729
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.06176845
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.65202206
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.06790967
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.56214547
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.70103515
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.90254064
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.26052765
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.02881612
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.09980861
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.32957846
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.96571530
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 3.47372265
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.47555867
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.88377061
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.20341737

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]      [,2]      [,3]       [,4]      [,5]       [,6]
    ##   [1,] 0.7877327 0.5962358 0.7035158 0.61942053 0.2743615 1.28527769
    ##   [2,] 0.3284971 0.5426118 0.3130301 0.48017951 0.4016904 1.68273796
    ##   [3,] 0.4690091 0.9259291 0.3653543 1.68161946 0.5958123 0.87483167
    ##   [4,] 0.5294777 1.0030548 0.2834965 0.10796624 0.4164305 0.29928650
    ##   [5,] 0.2970006 1.2553507 0.2334913 1.16342139 0.6286045 0.91767268
    ##   [6,] 0.5121434 1.3021134 0.5290887 0.07857220 0.4022767 2.06508309
    ##   [7,] 0.3768786 1.0718861 0.5186381 2.41454529 0.4145303 0.25527305
    ##   [8,] 0.4034603 0.1483787 0.2758702 0.50724092 0.4695391 0.62971736
    ##   [9,] 0.3146500 1.4091815 0.4583129 1.16125015 0.5063774 0.72502688
    ##  [10,] 0.2203975 1.5905683 0.4651222 0.08416591 0.2759277 1.51227379
    ##  [11,] 0.7688588 3.9134004 0.4476114 0.02532597 0.6441723 0.72658687
    ##  [12,] 0.3746666 2.9853881 0.3456730 1.49741814 0.3186218 0.55937809
    ##  [13,] 0.3337320 2.3353533 0.4251028 0.30055655 0.4860681 1.18549024
    ##  [14,] 0.2094548 0.8634542 0.3202808 0.51215711 0.6178004 0.39609936
    ##  [15,] 0.3395696 1.5454944 0.5429458 0.35964734 0.5281125 0.96784090
    ##  [16,] 0.1470033 1.6504459 0.3233033 2.09791517 0.5757292 0.92393618
    ##  [17,] 0.4442313 1.0710196 0.4923608 0.38629331 0.5839333 0.57449199
    ##  [18,] 0.4468008 1.1018748 0.7183228 0.27502547 0.3459673 1.18201984
    ##  [19,] 0.3590818 0.1896025 0.2869926 1.84289225 0.3319596 0.23591736
    ##  [20,] 0.3211617 1.4262608 0.3987646 0.79541094 0.6118958 0.47042753
    ##  [21,] 0.4595279 1.6833327 0.4533433 1.56984061 0.6538322 0.11757985
    ##  [22,] 0.3298593 1.1477086 0.3463224 0.49949049 0.4012319 0.38746530
    ##  [23,] 0.4360479 1.0745109 0.7285893 1.08752580 0.6410190 0.77390491
    ##  [24,] 0.4443386 0.6006803 0.4820928 1.07977744 0.2619488 2.45839683
    ##  [25,] 0.5338705 0.8724544 0.4127522 0.20732077 0.1601342 1.47871048
    ##  [26,] 0.2199139 1.5552540 0.6055395 0.95671986 0.7102143 0.90643861
    ##  [27,] 0.4141091 2.2337331 0.3783307 0.22553402 0.3637658 0.48520418
    ##  [28,] 0.5342781 0.7318907 0.4347381 0.32476427 0.3392496 1.86485373
    ##  [29,] 1.0037219 0.1113625 0.4474608 0.83988487 0.1499305 1.17923594
    ##  [30,] 0.2003133 0.7836562 0.3564126 1.08667309 0.3923388 0.59680499
    ##  [31,] 0.4541787 0.5191265 0.3811364 0.96805130 0.4384428 0.01774935
    ##  [32,] 0.2914465 0.4003218 0.5283717 0.44345436 0.3658783 1.88570887
    ##  [33,] 0.3626586 0.6694642 0.9312224 0.18528463 0.2283585 0.82274238
    ##  [34,] 0.6813572 0.6304605 0.5396171 1.67043639 0.5538592 1.01207161
    ##  [35,] 0.4092062 1.1876572 0.4989114 0.22362510 0.3930293 0.92952918
    ##  [36,] 0.4323690 0.8857658 0.4265505 0.64284649 0.5079841 0.36293881
    ##  [37,] 0.6945511 0.4194260 0.2568289 0.21684319 0.5051723 1.14858255
    ##  [38,] 0.3518126 1.1252597 0.4415345 0.46987721 0.3504616 1.60120460
    ##  [39,] 0.4967263 0.7718111 0.4728925 0.52413014 0.2864143 0.65786623
    ##  [40,] 0.4814633 2.5004317 0.3133257 1.69915584 0.3769276 1.43288142
    ##  [41,] 0.3623029 0.1078361 0.3404788 0.98538032 0.4318018 0.78390665
    ##  [42,] 0.3387498 1.4212101 0.9910060 1.75951529 0.3736547 3.07945749
    ##  [43,] 0.2846265 0.7147634 0.3417923 2.73175043 0.5314894 0.33966628
    ##  [44,] 0.4023905 0.2925318 0.4695684 0.14882517 0.4498945 0.72472634
    ##  [45,] 0.6914921 1.0007535 0.6820120 1.22322676 0.5060991 1.43324523
    ##  [46,] 0.2661357 1.0763419 0.3821492 0.24570113 0.3956904 0.78399040
    ##  [47,] 0.6860086 3.4208728 0.6913607 0.36287072 0.1633722 0.31802604
    ##  [48,] 0.3965179 2.5375740 0.3486704 0.92662402 0.4257241 0.93818300
    ##  [49,] 0.2533951 0.6158478 0.4962386 2.63055090 0.6928245 0.81961254
    ##  [50,] 0.4928039 1.7333845 0.6377646 1.97785067 0.4983335 1.98054406
    ##  [51,] 0.3597517 0.5415418 0.2925357 0.82807258 0.1956947 0.54079594
    ##  [52,] 0.5240796 0.2593812 0.5281116 1.61497410 0.6471712 0.24604585
    ##  [53,] 0.2028853 1.2756552 0.7736236 0.62457696 0.5943101 2.53128510
    ##  [54,] 0.3131735 1.3184552 0.4951818 0.50222461 0.5601143 1.21877545
    ##  [55,] 0.8795074 0.4402743 0.2625183 0.10868896 0.2387011 2.02787218
    ##  [56,] 0.7185622 0.6940318 0.2653580 0.62439676 0.4344394 0.09908777
    ##  [57,] 0.4342771 0.9906428 0.6274555 0.24798461 0.5592598 0.73134561
    ##  [58,] 0.3632192 0.1953987 0.5850304 1.75538318 0.3750021 0.49112219
    ##  [59,] 1.2997029 0.4480127 0.2698830 0.87927515 0.3834180 0.79423185
    ##  [60,] 0.4050386 0.2275377 0.5367734 1.71817547 0.2663102 1.47183705
    ##  [61,] 0.4610107 0.7535136 0.2914046 0.93678979 0.6200355 0.93772728
    ##  [62,] 0.4186503 0.5158953 0.7645988 0.99637461 0.2863081 0.44732383
    ##  [63,] 0.2451483 1.4859927 0.3069482 0.72470382 0.3692172 0.59093983
    ##  [64,] 0.2360060 1.0934452 0.8003443 0.64357808 0.5465009 0.21898287
    ##  [65,] 0.8120239 4.0303754 0.4969605 2.13125315 0.4288363 2.01970242
    ##  [66,] 0.4006184 0.9537868 0.3681038 1.38817440 0.3097444 0.98345711
    ##  [67,] 0.4195488 1.4563116 0.2746568 0.70598638 0.6392945 3.12409447
    ##  [68,] 0.4986821 0.6174785 0.3543122 1.22028862 0.3759889 0.54457662
    ##  [69,] 0.3027684 1.4363628 0.2348188 1.04426249 0.3338311 0.93179487
    ##  [70,] 0.7807782 0.5447581 0.4591439 1.43627688 0.4685998 0.80210726
    ##  [71,] 0.4147144 1.4635230 0.3390799 1.47500985 0.4072033 1.21238202
    ##  [72,] 0.2827167 0.5053570 0.3967656 0.52159879 0.5373170 1.30614018
    ##  [73,] 0.1945826 0.4587456 0.4922366 0.71298833 0.3554494 0.05033791
    ##  [74,] 0.4356021 0.4006623 0.4037376 0.90629228 0.3987690 0.75638874
    ##  [75,] 0.2993499 1.0050527 0.4316465 0.97978040 0.5564334 0.85015646
    ##  [76,] 0.5987908 0.4651259 0.5761309 0.50096664 0.1110426 0.86936488
    ##  [77,] 0.3418378 0.8743193 0.4195199 1.36906667 0.3800563 1.16047345
    ##  [78,] 0.5227893 2.5472855 0.6482081 1.14586695 0.3243070 1.88680209
    ##  [79,] 0.4444869 0.5730565 0.6826526 1.34152359 0.6367987 1.42488370
    ##  [80,] 0.3600436 0.4460370 0.2730657 2.12721467 0.2215195 0.88889327
    ##  [81,] 0.2184946 0.5794765 0.4227265 1.01939465 0.6499481 0.78727279
    ##  [82,] 0.4335079 1.7400155 0.4382775 0.64959015 0.3074738 0.29098907
    ##  [83,] 0.3113033 0.3690241 0.5364345 1.03016412 0.2728452 0.85538278
    ##  [84,] 0.2817188 0.2986389 0.4809827 1.24633176 0.4872842 1.48048341
    ##  [85,] 0.5104505 0.9631481 0.3210773 3.36505402 0.1610048 0.55147046
    ##  [86,] 0.5395330 0.2637810 0.2404506 0.69770678 0.6161217 0.99442043
    ##  [87,] 0.8976715 0.1054928 0.5611417 0.78192366 0.4389275 0.93450940
    ##  [88,] 0.3268455 0.9387473 0.7263524 1.76367164 0.3211697 0.47703066
    ##  [89,] 0.5150851 0.2797686 0.5795540 1.09204657 0.5522864 1.19204698
    ##  [90,] 0.5342536 0.7323463 0.8606923 0.60754160 0.2851925 1.35012640
    ##  [91,] 0.3569942 0.4058306 0.3836881 0.55508748 0.7070016 1.05861671
    ##  [92,] 0.4769051 0.7820933 0.4182187 0.80591052 0.2173776 0.18759635
    ##  [93,] 0.3786063 1.9189102 0.9077171 2.03471894 1.0391200 0.50331599
    ##  [94,] 0.5621094 0.6177906 0.4956811 0.47372325 0.3231578 0.73574339
    ##  [95,] 0.3706772 1.6006324 0.8828005 1.40441030 0.5145023 1.41211365
    ##  [96,] 0.6243080 0.4462595 0.4192979 2.00781082 0.7363421 0.39073147
    ##  [97,] 0.3134657 1.6685887 0.3368848 1.26054348 0.2262543 2.76928054
    ##  [98,] 0.3055297 0.3816794 0.7797759 0.47405955 0.4385406 1.77473413
    ##  [99,] 0.4996080 0.8955956 0.6647913 0.49944025 0.3076283 0.47922054
    ## [100,] 0.4322806 0.1657111 0.2847802 0.80240712 0.2504702 0.85652105
    ## 
    ## $`node names`
    ## [1] "LTBI screening cost/under 40k cob incidence/Screening"    "LTBI screening cost/under 40k cob incidence/No Screening" "LTBI screening cost/40-150k cob incidence/Screening"      "LTBI screening cost/40-150k cob incidence/No Screening"   "LTBI screening cost/over 150k cob incidence/Screening"    "LTBI screening cost/over 150k cob incidence/No Screening"

Pathway Probabilities
---------------------

To feed into a compartmental model like a Markov model we need state
probabilities. That is, the probability of ending-up in the one of the
terminal state of the tree that are also starting states for the other
model. These are calculated by taking the product of the probabilities
along each pathway from root to leaf.

Once again, we've written a function to do this, which we can append to
the the tree. Below we give the terminal states in a dataframe.

    path_probs <- calc.pathway_probs(osNode)
    osNode$Set(path_probs = path_probs)

    terminal_states <- data.frame(pathname = osNode$Get('pathString', filterFun = isLeaf),
                                  path_probs = osNode$Get('path_probs', filterFun = isLeaf))
    terminal_states

    ##                                                                                                                                             pathname  path_probs
    ## 1                                                                       LTBI screening cost/under 40k cob incidence/Screening/LTBI/Not GP registered 0.006250000
    ## 2                                                       LTBI screening cost/under 40k cob incidence/Screening/LTBI/GP registered/Not Agree to Screen 0.003750000
    ## 3                                             LTBI screening cost/under 40k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Negative 0.002625000
    ## 4                         LTBI screening cost/under 40k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Not Start Treatment 0.000787500
    ## 5          LTBI screening cost/under 40k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Complete Treatment 0.000590625
    ## 6      LTBI screening cost/under 40k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Not Complete Treatment 0.000590625
    ## 7                                                                   LTBI screening cost/under 40k cob incidence/Screening/non-LTBI/Not GP registered 0.006250000
    ## 8                                                   LTBI screening cost/under 40k cob incidence/Screening/non-LTBI/GP registered/Not Agree to Screen 0.003750000
    ## 9                                         LTBI screening cost/under 40k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Negative 0.002625000
    ## 10                    LTBI screening cost/under 40k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Not Start Treatment 0.000787500
    ## 11     LTBI screening cost/under 40k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Complete Treatment 0.000590625
    ## 12 LTBI screening cost/under 40k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Not Complete Treatment 0.000590625
    ## 13                                                                                     LTBI screening cost/under 40k cob incidence/No Screening/LTBI 0.025000000
    ## 14                                                                                 LTBI screening cost/under 40k cob incidence/No Screening/non-LTBI 0.037500000
    ## 15                                                                        LTBI screening cost/40-150k cob incidence/Screening/LTBI/Not GP registered 0.006250000
    ## 16                                                        LTBI screening cost/40-150k cob incidence/Screening/LTBI/GP registered/Not Agree to Screen 0.003750000
    ## 17                                              LTBI screening cost/40-150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Negative 0.002625000
    ## 18                          LTBI screening cost/40-150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Not Start Treatment 0.000787500
    ## 19           LTBI screening cost/40-150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Complete Treatment 0.000590625
    ## 20       LTBI screening cost/40-150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Not Complete Treatment 0.000590625
    ## 21                                                                    LTBI screening cost/40-150k cob incidence/Screening/non-LTBI/Not GP registered 0.006250000
    ## 22                                                    LTBI screening cost/40-150k cob incidence/Screening/non-LTBI/GP registered/Not Agree to Screen 0.003750000
    ## 23                                          LTBI screening cost/40-150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Negative 0.002625000
    ## 24                      LTBI screening cost/40-150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Not Start Treatment 0.000787500
    ## 25       LTBI screening cost/40-150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Complete Treatment 0.000590625
    ## 26   LTBI screening cost/40-150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Not Complete Treatment 0.000590625
    ## 27                                                                                       LTBI screening cost/40-150k cob incidence/No Screening/LTBI 0.025000000
    ## 28                                                                                   LTBI screening cost/40-150k cob incidence/No Screening/non-LTBI 0.037500000
    ## 29                                                                      LTBI screening cost/over 150k cob incidence/Screening/LTBI/Not GP registered 0.006250000
    ## 30                                                      LTBI screening cost/over 150k cob incidence/Screening/LTBI/GP registered/Not Agree to Screen 0.003750000
    ## 31                                            LTBI screening cost/over 150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Negative 0.002625000
    ## 32                        LTBI screening cost/over 150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Not Start Treatment 0.000787500
    ## 33         LTBI screening cost/over 150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Complete Treatment 0.000590625
    ## 34     LTBI screening cost/over 150k cob incidence/Screening/LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Not Complete Treatment 0.000590625
    ## 35                                                                  LTBI screening cost/over 150k cob incidence/Screening/non-LTBI/Not GP registered 0.006250000
    ## 36                                                  LTBI screening cost/over 150k cob incidence/Screening/non-LTBI/GP registered/Not Agree to Screen 0.003750000
    ## 37                                        LTBI screening cost/over 150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Negative 0.002625000
    ## 38                    LTBI screening cost/over 150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Not Start Treatment 0.000787500
    ## 39     LTBI screening cost/over 150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Complete Treatment 0.000590625
    ## 40 LTBI screening cost/over 150k cob incidence/Screening/non-LTBI/GP registered/Agree to Screen/Test Positive/Start Treatment/Not Complete Treatment 0.000590625
    ## 41                                                                                     LTBI screening cost/over 150k cob incidence/No Screening/LTBI 0.025000000
    ## 42                                                                                 LTBI screening cost/over 150k cob incidence/No Screening/non-LTBI 0.037500000

Specifically, the starting state probabilities of the subsequent
compartmental model are for aggregated sub-populations. We can simply
sum over these in an ad-hoc way:

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

<table>
<thead>
<tr class="header">
<th align="left"></th>
<th align="right">LTBI</th>
<th align="right">nonLTBI</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">&lt;40k</td>
<td align="right">0.1417973</td>
<td align="right">0.191536</td>
</tr>
<tr class="even">
<td align="left">40-150k</td>
<td align="right">0.1417973</td>
<td align="right">0.191536</td>
</tr>
<tr class="odd">
<td align="left">&gt;150k</td>
<td align="right">0.1417973</td>
<td align="right">0.191536</td>
</tr>
</tbody>
</table>

Risk Profile
------------

Further, the pathway probabilities can be used to give the distribution
of the terminal state values e.g. cost or time. This is called the risk
profile of the decision tree.

    osNode <- calc.riskprofile(osNode)
    print(osNode, "type", "path_prob", "path_payoff")

    ##                                                 levelName     type   path_prob path_payoff
    ## 1  LTBI screening cost                                      chance 1.000000000   0.1745106
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   0.3240086
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   0.7562892
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.5394204
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   2.7900461
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.2466228
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   2.9505209
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   2.7213953
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   2.8367897
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   3.2842474
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   4.0911772
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   4.3534911
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   4.6172967
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.5153440
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.7022804
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   2.2077067
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   3.5618322
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   4.3881286
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   5.8347887
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   8.6629481
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   6.2537100
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   7.4965331
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   6.4072914
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   6.4128835
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   6.6064744
    ## 26  ¦   °--No Screening                                    logical 0.062500000   0.4897196
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   0.5372179
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   0.7342392
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.4463075
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   0.7310877
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.1124416
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   1.1313739
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.0468938
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.0697619
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   2.5814460
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   3.0094516
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   2.9170866
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   3.3293136
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   3.6236613
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   4.2966740
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   3.8927482
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.4888549
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.6225909
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   3.2495368
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   3.8987884
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   5.5347549
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   7.5680051
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   6.7661021
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   9.3019414
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   8.3347536
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   9.5831273
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   9.1779151
    ## 53  ¦   °--No Screening                                    logical 0.062500000   1.2487146
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   2.8732651
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   1.5030262
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.4512584
    ## 57      ¦--Screening                                       logical 0.062500000   0.7017286
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   1.0645961
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   1.1105862
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   1.9257747
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   2.2374734
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   3.0493737
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   4.2041855
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   3.4997033
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   3.6418623
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   4.8586431
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   5.8098553
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.7193506
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   1.3407418
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   2.2412780
    ## 71      ¦       °--GP registered                            chance 0.006250000   2.0377385
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.2137617
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   3.0233766
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000   4.0956944
    ## 75      ¦               °--Test Positive                    chance 0.002625000   3.3591131
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   3.4103715
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   4.4269766
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   4.7632950
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   5.5144760
    ## 80      °--No Screening                                    logical 0.062500000   1.3077795
    ## 81          ¦--LTBI                                       terminal 0.025000000   2.7418269
    ## 82          °--non-LTBI                                   terminal 0.037500000   1.7792829

    plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
               osNode$Get('path_prob', filterFun = isLeaf)), type="h",
         xlab="payoff", ylab="probability")

![](README_files/figure-markdown_strict/unnamed-chunk-14-1.png)

Optimal decisions
-----------------

We can get the software to calculate the optimal decision for us, rather
than returning the expections to compare. This can be done from right to
left, iteratively.

    ##TODO##
    osNode$Do(decision, filterFun = function(x) x$type == 'decision')
    osNode$Get('decision')[1]

    ##TODO##
    ## probabilty of successfully & correctly treating LTBI
    dummy <- rep(0, osNode$totalCount)
    dummy[12] <- 1
    osNode$Set(payoff = dummy)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
    osNode$Get('payoff')[1]
