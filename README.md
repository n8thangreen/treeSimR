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

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.516264007
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 2.907401743
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.419915731
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 5.050787366
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.379842261
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.213539966
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.138327436
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.335085905
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.594358144
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.733048888
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.956361677
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.652461494
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 4.156421394
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.170937370
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.642852525
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.100792195
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.094681632
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.519893273
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.925600875
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.523013025
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.788094182
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.069978579
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.274226678
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.128273961
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.216371731
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.121565600
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.002277891
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.106305409
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 2.026053809
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.066453519
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.020363371
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.129998800
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.768590340
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.026885627
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.014484070
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 5.229782984
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.626165587
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 4.991093676
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.244942617
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.829256396
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.491142976
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.520479624
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.280985342
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.560905868
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.268254790
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.688194244
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.565847666
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.236831019
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.368981529
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.316997500
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.505587010
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.594482767
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.566731395
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.131650817
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.400325999
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 1.266980726
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.029985310
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.928835749
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.661063070
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.571148211
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.878589149
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.202023635
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.538767220
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.789119791
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.163185930
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.267167532
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.368425557
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.431548544
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.195586147
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.124369360
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.559016759
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.126787603
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.055753952
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.286220195
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 2.088428361
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.683725860
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.072424180
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.946180626
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.105582177
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.386289171
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.910761450
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.621096601

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.231909407
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.269790752
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.414468607
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.736762447
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.379842261
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.462063857
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.138327436
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.298445658
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.594358144
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.260564225
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.956361677
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 3.245519073
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 4.156421394
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.170937370
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.921111979
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.100792195
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.201987753
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.519893273
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.150086315
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.523013025
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.548538854
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.069978579
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.758484269
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.128273961
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.216371731
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.664694402
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.002277891
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.106305409
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.384522408
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.645233708
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.478517829
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.129998800
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 3.566295773
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.026885627
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 4.916940662
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 5.229782984
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.794417961
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 4.991093676
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.990299529
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.829256396
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.491142976
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.102417001
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.280985342
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.475057161
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.268254790
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.856840477
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.565847666
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.658210159
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.368981529
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.825052333
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.505587010
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.594482767
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.892855926
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.131650817
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.400325999
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.273324466
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.356335322
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.654663109
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.661063070
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.975594701
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.878589149
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.747402020
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.538767220
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.528949952
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.163185930
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.599980576
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.368425557
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.431548544
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.770678179
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.124369360
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.802326087
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.126787603
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.877089208
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.286220195
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.966764389
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.683725860
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.538822102
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.946180626
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.105582177
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.736962540
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.910761450
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.621096601

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.285356051
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.204597630
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.588339420
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.618606487
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.470674689
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.075841527
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.862506634
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.930562578
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.080120435
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.249254676
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.246116356
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.918065897
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.459457841
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 3.431296689
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.734751192
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.832703218
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.504174761
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.630933609
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.542690994
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.692157598
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.511686678
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.074203035
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.631419226
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.147224477
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.028001158
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.230051102
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.151841183
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.282191049
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.761891821
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.725597527
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.466347815
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.195421732
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.970447806
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.480056093
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.137356917
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.058890518
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.565905077
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.186338636
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.700011622
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.929446207
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.337235956
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 2.436042291
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.945286601
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 3.144819128
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.174844060
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.066521152
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.672347706
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.279825368
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.159968009
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.772783219
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.048186744
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.982190881
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.321969756
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.337829208
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.978063455
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.174934752
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.342671843
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.228764456
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.021540160
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.550370980
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.131851311
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.785433655
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.621302191
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.500745888
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.841697555
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.827455404
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.008080957
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.095192915
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.141922916
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.769203193
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.085604098
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.246005164
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 3.230001666
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.996751224
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.617536870
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.021624586
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.370164981
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.700099440
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 3.793453868
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.357067164
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.460972511
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.287796932

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]      [,5]       [,6]
    ##   [1,] 0.3309860 0.36871267 0.3286265 1.77221893 0.4839888 0.81779296
    ##   [2,] 0.5417923 0.43105340 0.4491164 0.59060704 0.5936454 0.76978994
    ##   [3,] 0.3180260 0.67531333 0.5794845 2.54460326 0.3644867 0.40104812
    ##   [4,] 0.6389001 1.78352171 0.5208528 0.50609091 0.2878926 0.47956241
    ##   [5,] 0.2783415 1.29721134 0.2527295 1.66167661 0.2599931 2.02966608
    ##   [6,] 0.3520173 2.51869732 0.8611706 0.96488357 0.4103851 0.55820058
    ##   [7,] 0.5003594 0.41224723 0.3778828 1.01018719 0.6344736 0.44274298
    ##   [8,] 0.2759751 1.65702835 0.2712433 0.50078364 0.5364043 1.54750255
    ##   [9,] 0.4373831 0.27966016 0.6333787 1.26620704 0.4562961 4.92234498
    ##  [10,] 0.4001172 0.63827393 0.5630468 0.82561979 0.2534115 3.54843441
    ##  [11,] 0.6027141 1.14091187 0.2456178 0.60411687 0.4183740 1.89299264
    ##  [12,] 0.1299172 0.90030598 0.4916989 1.14795918 0.5204941 1.00225131
    ##  [13,] 0.4603011 0.63083512 0.5183610 0.93927040 0.5230449 1.01666262
    ##  [14,] 0.3823488 0.91347539 0.4872549 0.73859235 0.3465039 1.11939798
    ##  [15,] 0.4084936 0.89605170 0.3718431 1.14610672 0.5330509 1.76690980
    ##  [16,] 0.3660333 2.89782641 0.3016071 1.41322773 0.3754784 0.23091270
    ##  [17,] 0.5901340 1.66540006 0.2858125 1.45692297 0.3657672 0.26385995
    ##  [18,] 0.4833130 1.22694691 0.5937737 0.12154507 0.4619844 1.20586280
    ##  [19,] 0.7494671 0.50039708 0.4734420 0.27147033 0.3833751 1.65104975
    ##  [20,] 0.4172808 0.60874177 0.3124185 0.73561316 0.6280316 0.34579330
    ##  [21,] 0.4279267 2.45056701 0.3153709 0.38208470 0.4435824 0.92914349
    ##  [22,] 0.4153556 1.81589538 0.3188035 1.36103666 0.3287168 0.63865741
    ##  [23,] 0.3783907 1.51678491 0.4797668 0.67919749 0.5170946 0.55631218
    ##  [24,] 0.2829476 1.59703404 0.4317135 2.89768613 0.4562292 0.76088216
    ##  [25,] 0.6392852 0.92697511 0.7982952 0.17504316 0.3765695 0.54355031
    ##  [26,] 0.4174469 0.35116045 0.3625946 0.84229308 0.4564987 2.24507194
    ##  [27,] 1.1509370 0.75464531 0.3337077 1.47947972 0.5102423 0.82267298
    ##  [28,] 0.5787450 1.96074683 0.5501785 0.68737140 0.7335882 1.62697335
    ##  [29,] 0.5759540 1.34933364 0.3603773 0.87195880 0.4598825 2.59058997
    ##  [30,] 0.7833079 0.66370858 0.3634805 2.04789062 0.3645819 0.53873840
    ##  [31,] 0.4763340 1.07146046 0.6143758 0.75812365 0.5001480 1.26768446
    ##  [32,] 0.6880493 0.58318650 0.2223464 0.66356533 0.2350100 2.79809687
    ##  [33,] 0.2544476 0.69563670 0.6462135 0.07099083 0.3127771 1.41123125
    ##  [34,] 0.3668335 2.69514113 0.4338915 0.69343354 0.6359377 0.56600646
    ##  [35,] 0.2661321 0.68304910 0.1878332 1.05122878 0.4228308 1.11309851
    ##  [36,] 0.5193470 1.54802039 0.4699815 0.67881799 0.4796870 0.21275237
    ##  [37,] 0.3832535 0.25364599 0.4963992 1.92586859 1.1543671 0.27756272
    ##  [38,] 0.3989689 0.40263645 0.5101899 1.31708130 0.5850915 1.12972349
    ##  [39,] 0.1523589 0.28153217 0.7272261 0.78163951 0.2086329 0.58730566
    ##  [40,] 0.2600381 0.72991532 0.3009617 0.69991553 0.4569852 0.26046815
    ##  [41,] 0.3946721 0.59180535 0.4971170 0.48381101 0.2057889 0.22698080
    ##  [42,] 0.5920618 1.43383149 0.3153662 3.59392221 0.4453073 1.27008367
    ##  [43,] 0.6638118 0.23807158 0.5826163 2.58019141 0.3264728 0.13809298
    ##  [44,] 0.7409214 0.63350204 0.4933488 0.31935831 0.6196514 0.35656464
    ##  [45,] 0.5724782 0.17101645 0.5466640 0.50183725 0.5341562 0.67797789
    ##  [46,] 0.7628568 0.62586708 0.3831736 1.07421362 0.3387952 0.22721381
    ##  [47,] 0.5241238 0.58133719 0.6079204 2.91064844 0.3717402 0.38702129
    ##  [48,] 0.2880093 2.35557194 0.5121427 0.59109522 0.6126497 0.55255965
    ##  [49,] 0.6386547 0.06151706 0.1292024 0.92195640 0.6692181 1.31528175
    ##  [50,] 0.4281226 0.36117060 0.6956234 2.86894744 0.4322578 0.49645319
    ##  [51,] 0.7629873 0.78471583 0.6809079 0.67707814 0.2545885 0.40554894
    ##  [52,] 0.3533321 1.28878574 0.3477595 1.49950786 0.7559493 0.54076585
    ##  [53,] 0.6604704 0.31702318 0.3613008 1.08162195 0.4010793 0.77208520
    ##  [54,] 0.4254588 0.20439627 0.5408443 2.68599469 0.5048974 0.59279062
    ##  [55,] 0.4587809 1.61480207 0.4267723 1.83714206 0.5002962 0.50010922
    ##  [56,] 0.6634470 1.41954424 0.5899997 1.39538404 0.4418278 2.28455629
    ##  [57,] 0.3893018 0.32158645 0.2559896 0.20372406 0.5558887 0.97329657
    ##  [58,] 0.3374760 0.89343144 0.5082102 0.29819732 0.4806130 0.69325805
    ##  [59,] 0.4602809 0.15607988 0.3366930 1.52191789 0.2369152 0.88646369
    ##  [60,] 0.4391972 0.05045558 0.6003846 0.33832674 0.3742408 0.81324649
    ##  [61,] 0.2454453 0.97081743 0.7895867 0.43456332 0.3747736 0.22165505
    ##  [62,] 0.3282067 0.34847423 0.7746003 0.71953417 0.3739238 0.91668848
    ##  [63,] 0.4030704 4.75669778 0.4350567 1.48276856 0.2128130 1.03359082
    ##  [64,] 0.5114381 0.69553179 0.2922127 0.78089817 0.4275004 0.52347352
    ##  [65,] 0.5979380 1.22033160 0.3647006 0.11020067 0.8307085 0.55254947
    ##  [66,] 0.2949812 0.36755019 0.5080832 0.56874473 0.5105264 0.40547677
    ##  [67,] 0.7149595 1.19313159 0.3242062 0.63636996 0.4935673 2.09649015
    ##  [68,] 0.5878810 0.04259335 0.8128447 0.57125066 0.1585383 0.96205512
    ##  [69,] 0.4185058 0.39468292 0.5347372 0.17596586 0.8280867 0.38883909
    ##  [70,] 0.5200139 1.42353317 0.5609595 0.95306251 0.4926250 0.09595807
    ##  [71,] 0.6219015 0.65491400 1.2703102 1.86432616 0.5669241 0.29940188
    ##  [72,] 0.2776065 1.33987854 0.4106643 2.72905754 0.5360549 0.25114360
    ##  [73,] 0.4625546 0.13959559 0.4099054 2.47417690 0.4305524 2.36178675
    ##  [74,] 0.3632622 0.96480683 0.4898356 0.71033577 0.4744824 0.55464756
    ##  [75,] 0.5889269 0.42233326 0.5985280 1.17808096 0.4198014 1.34530597
    ##  [76,] 0.4238811 0.40347957 0.6341760 0.67840742 0.2568397 1.94043138
    ##  [77,] 0.3784550 0.59208278 0.1788012 0.10457125 0.4245360 1.15395016
    ##  [78,] 0.3095467 1.19402896 0.6159449 0.78186146 0.2502550 1.46981306
    ##  [79,] 0.5660733 0.44445614 0.1912224 1.19857318 0.5884619 0.66684508
    ##  [80,] 0.3986334 0.56192652 0.4653369 0.57480208 0.8435730 0.77429219
    ##  [81,] 0.4365876 0.86585559 0.3007887 1.21660920 0.5235590 0.70865892
    ##  [82,] 0.2852707 1.00508465 0.5326472 0.60890124 0.5341337 2.79972783
    ##  [83,] 0.2696151 0.91840270 0.5854505 1.20141112 0.6066526 0.31008027
    ##  [84,] 0.2048052 0.60767613 0.2799439 2.19009418 0.3558002 0.65924483
    ##  [85,] 0.3057001 2.47047956 0.5131436 2.47023494 0.3149375 0.68492322
    ##  [86,] 0.5459381 0.50940938 0.3134648 3.29201289 0.2454252 1.08396131
    ##  [87,] 0.2816071 1.22721605 0.3824379 0.49624386 0.4157007 0.35486810
    ##  [88,] 0.5127894 0.19913880 0.5864441 0.91728768 0.4383966 1.84936512
    ##  [89,] 0.4063148 1.71958240 0.8416296 0.92565054 0.4744361 2.53838299
    ##  [90,] 0.5350446 0.67677149 0.4741913 0.45324227 0.4217204 0.93251525
    ##  [91,] 0.6025941 1.57512256 0.4366908 1.54999551 0.7377846 0.22336851
    ##  [92,] 0.2774563 0.26508947 0.5581950 2.04934461 0.3924168 1.52000302
    ##  [93,] 0.2851438 0.79953955 0.2669490 0.14951901 0.4399710 0.69335540
    ##  [94,] 0.4058925 1.75345319 0.3594838 1.11892637 0.4426640 0.38141441
    ##  [95,] 0.3491053 0.41598870 0.3297692 0.24328023 0.7142321 0.88189597
    ##  [96,] 0.2526489 0.30249600 0.3951672 1.62416769 0.3114941 1.77891695
    ##  [97,] 0.2933505 1.43702459 0.2575180 0.61608029 0.4010370 1.51377678
    ##  [98,] 0.3964632 0.29810454 0.4898390 0.23813729 0.1759602 0.72588321
    ##  [99,] 0.8188641 0.93382944 0.1971624 0.10143086 0.4679677 0.77266260
    ## [100,] 0.5258516 0.23686856 0.6182036 1.20726442 0.7863476 0.34074924
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
    ## 1  LTBI screening cost                                      chance 1.000000000   0.2322053
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   0.4228853
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   0.9487369
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.9678338
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   3.2230948
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   3.2603152
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   4.0408200
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.6339459
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   4.7841131
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   6.4461083
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   6.9586330
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500  11.9741251
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  13.0210536
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625  18.2978858
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   2.0330464
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   3.8229570
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   2.9539094
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   3.1652627
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   4.2773277
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   5.1806017
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   5.2646514
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   5.2965010
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   8.5238808
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   9.7029851
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625  11.6904156
    ## 26  ¦   °--No Screening                                    logical 0.062500000   0.6597539
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   0.8610559
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   0.9203335
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.6885723
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   1.3067759
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   3.3407964
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   7.5434023
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   4.2232417
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   4.6080372
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   5.3091883
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   6.6793776
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   5.4903513
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   5.8517443
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   5.7328352
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   6.0491436
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.7398384
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.7455699
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.8695880
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   2.7185368
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.7881969
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   4.2704883
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   5.7839597
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   4.9740904
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   5.6505386
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   6.6429824
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   8.2387100
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   7.2724443
    ## 53  ¦   °--No Screening                                    logical 0.062500000   1.8958367
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   3.4244653
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   2.8888584
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.5139795
    ## 57      ¦--Screening                                       logical 0.062500000   1.3003271
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   3.4472226
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   8.4002423
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   3.8614418
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   4.2100561
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.2031928
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   4.2829196
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   4.6116816
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   5.3119973
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   5.2729952
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   5.7235246
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.7042174
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   2.2988219
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   2.3071344
    ## 71      ¦       °--GP registered                            chance 0.006250000   4.7867463
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   6.7078585
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   7.0121749
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000   9.5324017
    ## 75      ¦               °--Test Positive                    chance 0.002625000   7.6711318
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   9.3122992
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   8.2264874
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   8.7363880
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   8.4570610
    ## 80      °--No Screening                                    logical 0.062500000   0.8547288
    ## 81          ¦--LTBI                                       terminal 0.025000000   1.4613843
    ## 82          °--non-LTBI                                   terminal 0.037500000   1.0182071

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
