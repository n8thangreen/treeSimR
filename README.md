`treeSimR`
==========

An R package for easy forward simulating probability decision trees,
calculating cost-effectiveness and PSA.

Currently contains functions to:

-   read-in and check tree object
-   simulate final expected outcomes
-   Monte-Carlo simulate multiple simulations

*TODO*

-   \[ \] iteratively collapse expected outcome (from right to left)
-   \[ \] iteratively collapse chance nodes (from right to left)
-   \[ \] optimal decision function (iterative from right to left)
-   \[ \] plotting functions: C-E plane, C-E curve, risk profile (with
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

    osNode <- treeSimR::costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
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

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 1.065540955
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 2.362700912
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 5.867139063
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.510800833
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.592948521
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.982461641
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.044948357
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.346516472
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.620119579
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.403064816
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.072035252
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.629429168
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.173363176
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.410271173
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.308918243
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.491710940
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.001206717
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.494738030
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.227338663
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.371744566
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.712976427
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.991292482
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.125564783
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.621938829
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.337989282
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.304827987
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.007755855
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.041965755
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.633868681
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 1.252178076
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.477603670
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.251634781
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.621995463
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.323280824
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.288916436
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.456408472
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.701889131
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.161062859
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.608965923
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.122581665
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.642569688
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 2.478393153
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.746226037
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.365471018
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.322333501
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.382893249
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.182840633
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.122680713
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.745592003
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.043165683
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.459125843
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.342029740
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.267400907
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.709775757
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.499876883
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.251678315
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 1.085998404
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.910110456
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.084037838
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.257170700
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.889118010
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.080847605
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.133571285
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.490612545
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.546354151
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.826705565
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.614672624
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.474878561
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 3.522003527
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 3.022685154
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.423539190
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.854999802
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.078595944
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.054504960
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.335708661
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 4.085199711
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.051757134
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.821504594
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.222021963
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.539243106
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.012324747
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 2.609863355

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.317633547
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.273355453
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.465140018
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.358639058
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.592948521
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.803649125
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.044948357
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.961133518
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.620119579
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.752928304
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.072035252
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.437725762
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.173363176
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.410271173
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.501921014
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.491710940
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.763091595
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.494738030
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.777081295
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.371744566
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.738371570
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.991292482
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.469946084
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.621938829
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.337989282
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.628281795
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.007755855
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.041965755
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.379033322
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.332296855
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.405358222
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.251634781
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.761760775
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.323280824
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.946320469
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.456408472
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.895477912
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.161062859
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.823863515
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.122581665
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.642569688
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.923829199
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.746226037
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.563346961
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.322333501
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.283244768
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.182840633
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.078937607
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.745592003
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.850866687
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.459125843
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.342029740
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.183836432
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.709775757
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.499876883
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.618145411
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.501733734
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.338164718
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.084037838
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.761373955
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.889118010
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.379838583
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.133571285
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.409055262
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.546354151
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.817163388
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.614672624
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.474878561
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.668770217
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 3.022685154
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.149240387
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.854999802
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.060400844
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.054504960
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.460353389
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 4.085199711
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.782644918
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.821504594
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.222021963
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.970847912
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.012324747
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 2.609863355

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc_expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.371089544
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.532919997
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.291287572
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.408400608
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.282025433
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.738976086
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.793713179
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.437913631
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.295846783
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.329744118
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.666538011
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.432609049
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.481554196
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.095257870
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.756749680
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.581102728
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.310771471
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.406665772
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.777953347
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.997997461
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.541935891
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.006402203
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.800050767
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.348391406
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.051676283
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.840392417
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.568919809
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.354707489
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.269453147
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.421789707
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.686103164
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.187459082
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.527798829
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.213758187
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.665906527
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.668422268
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.282872771
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.287072109
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.655837127
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.130450011
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.743999492
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.001055664
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.138149717
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.364489444
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.115447336
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.158701737
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.130440684
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.524847513
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.137979466
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.611512242
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.205802739
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.609546917
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.656022882
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.065659716
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.049598326
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.681985033
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.808029602
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 2.772430024
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 5.956693627
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.974381433
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.437277603
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.186691452
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.038846293
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.227855781
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.216587089
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.542932182
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.411417218
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.312492358
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.459688385
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.141690138
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.007530824
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.737236577
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.941981463
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.099471665
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.246216139
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.051791003
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 4.102262794
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 5.389813717
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.079870008
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.919910530
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.159929525
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 2.426564533

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo_expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]      [,2]      [,3]       [,4]       [,5]      [,6]
    ##   [1,] 0.3232609 0.6835081 0.3672304 1.03176234 0.62421010 0.5444789
    ##   [2,] 0.6964978 1.2049602 0.3881589 0.12696429 0.35000338 1.5623564
    ##   [3,] 0.7202719 1.6582977 0.7303728 1.81255999 0.49870905 1.3698544
    ##   [4,] 0.2995246 1.5065555 0.4731119 0.40213580 0.43056662 0.2340803
    ##   [5,] 0.8966355 0.8961596 0.7529334 1.01381242 0.61727162 2.1881475
    ##   [6,] 0.5635623 0.6414155 0.6292944 0.22853489 0.37673211 1.1662773
    ##   [7,] 0.3371462 0.5130042 0.3059740 0.69047652 0.31243552 0.8381354
    ##   [8,] 0.3481218 1.3673479 0.2448679 1.24939343 0.76021696 0.5951169
    ##   [9,] 0.5587040 0.9067694 0.7610807 0.59852228 0.51486344 2.3243548
    ##  [10,] 0.8071196 2.1422735 0.3465192 1.54799586 0.77465295 0.4494778
    ##  [11,] 0.8462775 0.4823000 0.7374544 1.17799963 0.92031021 0.4143791
    ##  [12,] 0.2561692 2.0361558 0.4446252 0.44217921 0.41128368 0.6510162
    ##  [13,] 0.6028919 0.3798373 0.6891040 0.90109839 0.46805506 0.3417296
    ##  [14,] 0.3180189 0.7623084 0.3790690 1.07277288 0.79538669 0.8717527
    ##  [15,] 0.5497368 1.4290396 0.3409963 0.47041837 0.51266209 1.0180046
    ##  [16,] 0.4021609 1.0756192 0.6902597 1.11636010 0.17568881 1.1850748
    ##  [17,] 0.5227595 1.0390008 0.3415556 0.38038848 0.45313769 0.5539337
    ##  [18,] 0.5323787 0.7122935 0.5484883 0.59531443 0.40933367 1.0387443
    ##  [19,] 0.4767363 1.1230458 0.4630621 0.75244574 0.24662409 0.6486309
    ##  [20,] 0.4119425 0.1602734 0.4981245 2.60444601 0.33408955 0.7307051
    ##  [21,] 0.4253065 0.6917347 0.2427009 0.07820628 0.92963153 1.8191903
    ##  [22,] 0.4238163 0.6653247 0.7771143 2.24444467 0.31875456 1.0915797
    ##  [23,] 0.3924421 0.7603016 0.5359225 0.90993983 0.51109621 1.1294474
    ##  [24,] 0.5195401 1.6362238 0.6904030 0.59276044 0.40641171 0.5616644
    ##  [25,] 0.5328633 0.8130143 0.3485020 2.13174876 0.38822944 0.1590414
    ##  [26,] 0.6446276 0.1231718 0.6482983 1.05191944 0.45621599 1.8428991
    ##  [27,] 0.4546978 0.9962094 0.4243091 0.32136878 0.62852477 1.1886154
    ##  [28,] 0.5005223 0.3449234 0.3774153 0.63896038 0.44192582 2.9341468
    ##  [29,] 0.4355271 1.1749631 0.4236337 0.52726699 0.39685767 0.6701441
    ##  [30,] 0.2404736 0.2458311 0.4742451 0.93991684 0.29824674 1.0669729
    ##  [31,] 0.6502576 0.5137268 0.3458760 0.66289657 0.54152659 1.5844835
    ##  [32,] 0.8543176 0.1879225 0.5550753 0.34250618 0.31445418 0.3621959
    ##  [33,] 0.4587174 0.4993910 0.2626166 0.27095935 0.44923146 1.3560342
    ##  [34,] 0.5114296 0.4878038 0.5473882 1.20262776 0.48280895 1.6799118
    ##  [35,] 0.3951660 0.2080020 0.9002561 0.73451281 0.44948878 0.7397302
    ##  [36,] 0.4582623 1.2372934 0.3141777 1.49785884 0.18350629 0.5366933
    ##  [37,] 0.5660695 1.1090181 0.4325759 0.66174737 0.57575758 0.5940766
    ##  [38,] 0.2991124 0.2014849 0.4247919 1.51038962 0.51023290 0.8256493
    ##  [39,] 0.4088865 0.6342022 0.2409069 0.93828713 0.69736810 2.3657452
    ##  [40,] 0.1808044 1.4609458 0.7407140 1.08932900 0.64763597 0.4110038
    ##  [41,] 0.6779899 1.7391602 0.4927552 1.12836240 0.62628101 1.0942345
    ##  [42,] 0.3825316 0.5207529 0.2234234 0.77670957 0.33268617 2.3381582
    ##  [43,] 0.3164707 0.7580173 0.7980596 1.10000578 0.19005259 0.8037581
    ##  [44,] 0.4246102 1.0125042 0.3766346 1.59806179 0.59340045 0.5893256
    ##  [45,] 0.2139501 1.0047223 0.2895539 0.38492687 0.30599750 1.1757043
    ##  [46,] 0.4834164 2.7130645 0.4550648 1.32824162 1.04374145 1.1284984
    ##  [47,] 0.8935900 0.8181926 0.6100243 0.26640939 0.37796301 0.4316696
    ##  [48,] 0.2729610 0.4204535 0.4735197 0.73946846 0.46303590 1.9358008
    ##  [49,] 0.4231109 1.5444885 0.6869012 0.77658369 0.29186893 2.5166311
    ##  [50,] 0.6033766 0.9696912 0.2787346 0.33600620 0.45540046 1.6091524
    ##  [51,] 0.4939209 0.9796357 0.9565264 0.34509445 0.58914794 0.5811071
    ##  [52,] 0.7407472 1.0342947 0.2596234 1.09969044 0.45806471 0.7721460
    ##  [53,] 0.5515865 1.2361001 0.4863269 2.07732862 0.26790256 1.0698043
    ##  [54,] 0.2866987 0.7513340 0.5526245 0.76750274 0.37681374 0.6533335
    ##  [55,] 0.2134526 0.0160386 0.4426958 1.11774442 0.52419259 0.6675773
    ##  [56,] 0.2126776 0.9819053 0.6485895 0.94206176 0.29015858 0.8914786
    ##  [57,] 0.4834415 0.5646137 0.2888197 1.76077466 0.49709944 0.9984050
    ##  [58,] 0.3705716 0.8563370 0.4322095 0.39585131 0.64025273 0.5780463
    ##  [59,] 0.3486621 0.9585735 0.7906858 0.69850536 0.69432136 0.8518472
    ##  [60,] 0.1959667 0.8204074 0.2708879 0.31025057 0.31036914 0.7995312
    ##  [61,] 0.5694752 2.5483006 0.4731512 1.47765940 0.37736356 1.1318559
    ##  [62,] 0.4167611 0.2662382 0.5677986 1.59620230 0.31439640 0.3965329
    ##  [63,] 0.4175886 0.7226233 0.2949177 0.45081938 0.23843455 0.1554870
    ##  [64,] 0.6398151 0.3620064 0.3074242 0.21521058 0.30760450 0.7658134
    ##  [65,] 0.3158073 0.3227099 0.4719362 1.72557874 0.65833044 0.2407803
    ##  [66,] 0.7142734 1.0287440 0.3950380 0.34670108 0.39002297 0.2034419
    ##  [67,] 0.7568918 1.0517411 0.2058142 0.90143354 0.38966219 0.6905722
    ##  [68,] 0.5078116 0.3351905 0.7317199 0.52029590 0.49429645 0.3735853
    ##  [69,] 0.5823928 0.2720048 0.5992400 0.14580065 0.35320235 1.3937066
    ##  [70,] 0.5040999 1.5315710 0.2127964 0.98586953 0.47230776 0.7362362
    ##  [71,] 0.2837520 1.0783836 0.4845600 1.77922947 0.09341069 1.3384003
    ##  [72,] 0.3926923 1.2828062 0.6641739 0.18766168 0.51713086 0.3694258
    ##  [73,] 0.3708565 2.0511313 0.6343914 1.79838489 0.26693492 0.6323165
    ##  [74,] 0.2452411 2.1257805 0.4928995 0.20705296 0.22348798 0.4053168
    ##  [75,] 0.2541805 0.9272076 0.5785618 1.25855580 0.13239574 2.3766609
    ##  [76,] 0.3239234 1.6703004 0.2633615 0.37519614 0.40367183 1.7045859
    ##  [77,] 0.3828993 4.0937459 0.4210102 1.29453253 0.62814351 2.8394189
    ##  [78,] 0.7830368 2.4297254 0.3508696 0.89745675 0.62787300 0.3878696
    ##  [79,] 0.3723194 0.7962027 0.4902865 1.58447720 0.78947532 0.5270949
    ##  [80,] 0.8333815 0.8944765 0.4356633 0.59856934 0.39629784 0.4790582
    ##  [81,] 0.8773884 0.8904637 0.7288895 2.99519160 0.66843572 1.4141293
    ##  [82,] 0.4625296 0.1027823 0.2851740 0.41050459 0.42725585 0.9095354
    ##  [83,] 0.6360948 0.4793049 0.5002534 0.36399129 0.34985872 1.9579574
    ##  [84,] 0.3903001 4.5440681 0.4774326 0.83473293 0.55757188 0.6470076
    ##  [85,] 0.8473379 1.6698034 0.5985930 0.34713367 0.22128624 0.5407788
    ##  [86,] 0.5236719 0.4644858 0.3713091 0.55073561 1.06172976 1.8552953
    ##  [87,] 0.6377553 0.8491966 0.4559807 1.21705537 0.49336228 0.7606705
    ##  [88,] 0.4324052 0.5728573 0.2484771 1.21928954 0.56004794 0.4029901
    ##  [89,] 0.5974723 0.4369039 0.5309873 0.20172519 0.35163528 0.2148925
    ##  [90,] 0.4614018 1.1716214 0.6909655 1.39897923 0.49658576 1.6466991
    ##  [91,] 0.4261347 1.5629597 0.5913326 0.85225312 0.47876256 0.1941225
    ##  [92,] 0.3126356 0.8190381 0.5537385 0.14182310 0.37459030 1.9296556
    ##  [93,] 0.4909266 0.9251934 0.5098614 0.20906309 0.30196706 1.2593094
    ##  [94,] 0.3251466 0.2648765 0.8247512 0.82065867 0.93320922 2.0182747
    ##  [95,] 0.7947585 0.7091472 0.9049825 0.60509334 0.80546354 0.3822281
    ##  [96,] 0.3041859 0.3932182 0.5521135 0.66536758 0.58104099 1.3483222
    ##  [97,] 0.5197080 0.5122088 0.3756277 3.54249005 0.18656908 0.6028502
    ##  [98,] 0.4154280 0.4039040 0.2399176 1.56091631 0.43960152 0.4270544
    ##  [99,] 0.3328653 0.5206777 0.4230900 1.36837136 0.46125233 0.2418186
    ## [100,] 0.2201490 1.0460712 0.5087441 0.98954911 0.59522985 0.7110559
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

    path_probs <- calc_pathway_probs(osNode)
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
sum over these in an ad-hoc way.

The non-LTBI individuals either never had LTBI or where successfully
treated.

    startstate.nonLTBI <- grepl("/Complete Treatment", x = terminal_states$pathname) | grepl("nonLTBI", x = terminal_states$pathname)
    startstate.LTBI <- !startstate.nonLTBI

The expected proportion of individuals in LTBI and non-LTBI after
screening is thus,

    healthstatus <- NA
    healthstatus[startstate.nonLTBI] <- "nonLTBI"
    healthstatus[startstate.LTBI] <- "LTBI"

    aggregate(terminal_states$path_probs, by=list(healthstatus), FUN=sum)

    ##   Group.1          x
    ## 1    LTBI 0.27151875
    ## 2 nonLTBI 0.00354375

Further, we can sample from the terminal state probabilities to give a
sample of compartmental model start state proportions. This can capture
the variability due to the cohort size.

    samplesize <- 100000
    numsamples <- 10

    sample.mat <- matrix(NA, nrow = nrow(terminal_states), ncol = numsamples)
    for (i in 1:numsamples){
      
      sample.mat[,i] <- table(sample(x = 1:nrow(terminal_states), size = samplesize, prob = terminal_states$path_probs, replace = TRUE))/samplesize
    }

    head(sample.mat)

    ##         [,1]    [,2]    [,3]    [,4]    [,5]    [,6]    [,7]    [,8]    [,9]   [,10]
    ## [1,] 0.02288 0.02240 0.02246 0.02275 0.02215 0.02268 0.02250 0.02320 0.02225 0.02202
    ## [2,] 0.01353 0.01383 0.01359 0.01368 0.01423 0.01333 0.01333 0.01358 0.01396 0.01348
    ## [3,] 0.00984 0.00913 0.00947 0.00973 0.00987 0.00967 0.00932 0.00928 0.00945 0.00961
    ## [4,] 0.00296 0.00284 0.00305 0.00271 0.00298 0.00250 0.00302 0.00259 0.00295 0.00272
    ## [5,] 0.00221 0.00221 0.00202 0.00192 0.00226 0.00229 0.00218 0.00236 0.00213 0.00240
    ## [6,] 0.00214 0.00213 0.00240 0.00194 0.00210 0.00219 0.00211 0.00200 0.00234 0.00190

    apply(sample.mat, 2, function(x) aggregate(x, by=list(healthstatus), FUN=sum))

    ## [[1]]
    ##   Group.1       x
    ## 1    LTBI 0.98701
    ## 2 nonLTBI 0.01299
    ## 
    ## [[2]]
    ##   Group.1       x
    ## 1    LTBI 0.98723
    ## 2 nonLTBI 0.01277
    ## 
    ## [[3]]
    ##   Group.1       x
    ## 1    LTBI 0.98764
    ## 2 nonLTBI 0.01236
    ## 
    ## [[4]]
    ##   Group.1       x
    ## 1    LTBI 0.98744
    ## 2 nonLTBI 0.01256
    ## 
    ## [[5]]
    ##   Group.1       x
    ## 1    LTBI 0.98674
    ## 2 nonLTBI 0.01326
    ## 
    ## [[6]]
    ##   Group.1       x
    ## 1    LTBI 0.98664
    ## 2 nonLTBI 0.01336
    ## 
    ## [[7]]
    ##   Group.1       x
    ## 1    LTBI 0.98771
    ## 2 nonLTBI 0.01229
    ## 
    ## [[8]]
    ##   Group.1       x
    ## 1    LTBI 0.98702
    ## 2 nonLTBI 0.01298
    ## 
    ## [[9]]
    ##   Group.1       x
    ## 1    LTBI 0.98693
    ## 2 nonLTBI 0.01307
    ## 
    ## [[10]]
    ##   Group.1       x
    ## 1    LTBI 0.98669
    ## 2 nonLTBI 0.01331

Risk Profile
------------

Further, the pathway probabilities can be used to give the distribution
of the terminal state values e.g. cost or time. This is called the risk
profile of the decision tree.

    osNode <- calc_riskprofile(osNode)
    print(osNode, "type", "path_prob", "path_payoff")

    ##                                                 levelName     type   path_prob path_payoff
    ## 1  LTBI screening cost                                      chance 1.000000000   0.2544249
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   0.5709800
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   0.7911290
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.2301084
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   1.3154273
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.2422381
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.2655947
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   2.9057642
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   3.1961443
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   3.5632785
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   4.2083044
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   5.1099669
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   6.9831256
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.2990595
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.2327454
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.3988675
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   2.1706645
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   3.3255988
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   2.5789287
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   2.7120797
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   3.0290122
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   3.0802191
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   4.4780836
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   5.0635122
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   5.8247501
    ## 26  ¦   °--No Screening                                    logical 0.062500000   1.6170512
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   2.2712785
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   2.9243517
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.6289982
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   1.1377423
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.9376639
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   2.9344610
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.9406706
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.6170985
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   3.9359206
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   3.9708468
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   5.3227802
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   6.9879256
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   8.2805001
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  10.0778834
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625  10.4267434
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   2.3727972
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   3.7411444
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   4.0920872
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   4.3518564
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   6.6978012
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   8.7858664
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   8.3321846
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   9.1322989
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500  12.9800150
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625  17.2309797
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625  14.9261575
    ## 53  ¦   °--No Screening                                    logical 0.062500000   1.6185474
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   2.9721757
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   2.3653770
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.5809964
    ## 57      ¦--Screening                                       logical 0.062500000   1.1762262
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   2.4536616
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   5.1615714
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   2.9393401
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   2.9716018
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   3.7165427
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   3.9658769
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   4.5774980
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   5.9890069
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   6.0358400
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   7.6349333
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   6.3812027
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   2.2797103
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   2.5382837
    ## 71      ¦       °--GP registered                            chance 0.006250000   4.7798470
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   5.4581450
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   8.2684437
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000  11.8364420
    ## 75      ¦               °--Test Positive                    chance 0.002625000   9.6841549
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500  12.5033092
    ## 77      ¦                   °--Start Treatment              chance 0.000787500  11.5840379
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625  13.5399651
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625  12.1612880
    ## 80      °--No Screening                                    logical 0.062500000   1.2920523
    ## 81          ¦--LTBI                                       terminal 0.025000000   2.9516314
    ## 82          °--non-LTBI                                   terminal 0.037500000   1.3707593

    plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
               osNode$Get('path_prob', filterFun = isLeaf)), type="h",
         xlab="payoff", ylab="probability")

![](README_files/figure-markdown_strict/unnamed-chunk-16-1.png)

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
