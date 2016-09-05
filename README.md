treeSimR
========

An R package for easy forward simulating probability decision trees,
calculating cost-effectiveness and PSA.

Currently contains functions to:

-   read-in and check tree object
-   simulate final expected outcomes
-   Monte-Carlo simulate multiple simulations

TODO

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

Simulate a scenario
-------------------

We can now sample values for each branch, given the distributions
defined for each. This could be the cost or health detriment.

    rpayoff <- osNode$Get(sampleNode)
    osNode$Set(payoff = rpayoff)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.03152967
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.37631579
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.90471147
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.70662785
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.20070882
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.16279813
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.14140171
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.53041869
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.32114996
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.04969968
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.44621816
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.02610984
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.97204887
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 6.28483340
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.46010021
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.80250385
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.79308653
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.49296741
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.02336464
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.23729874
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.49550075
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.20727370
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.02511293
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.03390394
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.64286808
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.13468740
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.13747427
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.09776045
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 3.59996426
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 1.10382929
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 3.60132194
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.53645041
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.60885394
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.30724232
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.01436504
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.12176803
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.55827675
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.81332155
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.65312472
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.74754680
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.57441500
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.80999246
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.15697329
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.84390822
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.17351338
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.77798645
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.25088790
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.04539587
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.05699067
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.33181462
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.23835046
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.87684132
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.51583924
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.48000445
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.06968081
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.57351212
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.58026000
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.63848810
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.19788936
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.57306420
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.25777801
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.22871280
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.35390286
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.08045403
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.05041026
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.47704649
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.39635298
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.00536449
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.61145017
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.93634944
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.08220796
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 4.30439273
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 3.49131059
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.16787256
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.04966436
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.04146261
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.45520857
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.22761664
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.04023579
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.33601657
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.30620445
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.05650837

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.17211115
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.24798532
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.47829529
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.01157268
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.20070882
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.32822288
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.14140171
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.73896975
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.32114996
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 2.59166396
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.44621816
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 6.19266171
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.97204887
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 6.28483340
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.90160848
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.80250385
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.45151736
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.49296741
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.92622819
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.23729874
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.51445581
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.20727370
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.50757901
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.03390394
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.64286808
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.51364597
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.13747427
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.09776045
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.24249914
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.33618630
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.75313691
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.53645041
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.34639187
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.30724232
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.93674413
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.12176803
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.21643787
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.81332155
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 3.24147135
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.74754680
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.57441500
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.59160827
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.15697329
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.32204739
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.17351338
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.36323227
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.25088790
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.26801535
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.05699067
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.83639384
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.23835046
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.87684132
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.63381027
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.48000445
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.06968081
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.19796013
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.63545373
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.25600374
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.19788936
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.44212000
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.25777801
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.47908866
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.35390286
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.33050951
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.05041026
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.05128810
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.39635298
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.00536449
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 2.28581116
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.93634944
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.77817845
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 4.30439273
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.32590470
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.16787256
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.29770558
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.04146261
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.95088932
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.22761664
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.04023579
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.15638680
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.30620445
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.05650837

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.254274422
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.194757795
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.394375528
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.270488643
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.352591317
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.823630289
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.175041638
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.864342178
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.650679116
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.584095424
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.427815630
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.519169116
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.781307304
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.244251517
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.307013467
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.059581368
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.707952301
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.474129604
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.705790897
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.655586635
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.352686076
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.782213045
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.393407208
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.093483595
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.431059349
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.384655652
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.527285640
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.289568993
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.475932726
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.576889099
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.827493453
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.090054488
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.978679145
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.826539571
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.804592337
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.005391937
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.144025687
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.722932798
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 3.090486160
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.679255512
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.441392702
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.480062943
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.057086265
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.643071091
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.209373513
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.529078306
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.734837793
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.449559787
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.392023787
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.439842168
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 4.073828220
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.512628004
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.326841803
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.594506330
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.481732119
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.346407167
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.434644881
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.008481880
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.316446649
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.204758050
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.982900639
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.025029444
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.495175048
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.969152730
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.271503895
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.959005205
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.184131193
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.761209081
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.730097645
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.912119720
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.913124392
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.560686869
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.961187118
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.044587871
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.328536583
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 3.191889551
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.236565725
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.399272112
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.249482187
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.950983785
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 2.306412867
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.047364398

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]      [,5]      [,6]
    ##   [1,] 0.4922272 2.68538170 0.6188623 0.69633775 0.4362238 2.5732340
    ##   [2,] 0.5815880 0.89318690 0.5731116 0.80532054 0.4912797 1.2566718
    ##   [3,] 0.5088407 2.07359293 0.3293149 0.11667473 0.8064124 1.0000954
    ##   [4,] 0.2769310 1.33544237 0.5303744 0.52490120 0.5196681 2.0290781
    ##   [5,] 0.2032872 0.84968330 0.2862443 0.83384203 0.8911904 0.3417936
    ##   [6,] 0.4549065 0.33517521 0.5838815 0.52920490 0.5119464 1.4111497
    ##   [7,] 0.3751033 2.63997795 0.5006606 0.46517510 0.2910747 0.8545488
    ##   [8,] 0.3533739 0.49158694 0.4184330 0.48248184 0.4073445 1.6830859
    ##   [9,] 0.5039780 0.85601578 0.5929100 1.17095850 0.4592240 0.1924374
    ##  [10,] 0.5084658 1.00900155 0.4043132 0.17484616 0.3967929 1.8590414
    ##  [11,] 1.0261415 0.81934146 0.5354944 0.58853339 0.2585077 2.2024022
    ##  [12,] 0.7637707 0.61770142 0.5303382 1.78271408 0.2521970 0.3585485
    ##  [13,] 0.6501193 0.83485828 0.5907452 1.05222158 0.5554292 0.8333709
    ##  [14,] 0.5868011 1.93157064 0.7031634 1.49328723 0.7038347 0.7504556
    ##  [15,] 0.4838618 0.68352846 0.2754942 0.62602815 0.3689327 1.8175191
    ##  [16,] 0.6286081 1.68337452 0.4528579 1.94500171 0.3859453 0.5130226
    ##  [17,] 0.4737009 0.95251623 0.3045508 0.06317087 0.3630557 0.4072602
    ##  [18,] 0.2841418 0.57970938 0.8188425 0.65054106 0.7092211 0.7579818
    ##  [19,] 0.4689955 1.48603243 0.3375120 0.57839707 0.6086016 1.8506035
    ##  [20,] 0.6635430 0.51360315 0.2856820 0.86894627 0.2808739 0.6637577
    ##  [21,] 0.5195778 0.63825130 0.4190451 0.29301285 0.5328738 1.0633305
    ##  [22,] 0.8355236 0.96684208 0.5253671 1.61211518 0.3125024 0.3828874
    ##  [23,] 0.3148799 0.07033609 0.4868747 0.29129481 0.1813744 0.5489622
    ##  [24,] 0.3292674 1.42046685 0.3126016 1.89219997 0.8563871 0.5673645
    ##  [25,] 0.5902279 0.99131173 0.3296485 0.47241759 0.5122763 0.2233013
    ##  [26,] 0.4734982 0.27310921 0.3612898 1.78475646 0.3918302 0.2902540
    ##  [27,] 0.1713489 1.96752261 0.5117396 0.52291243 0.3379055 1.0164581
    ##  [28,] 0.7367208 0.09853364 0.3666031 0.65449090 0.3063679 1.1286861
    ##  [29,] 0.3874422 2.30292843 0.3291476 0.31232769 0.6560595 0.5672219
    ##  [30,] 0.3147955 0.18159775 0.4149386 0.76938079 0.2803458 0.2565573
    ##  [31,] 0.6850949 1.64808542 0.6539329 0.57233409 0.5911332 2.2526317
    ##  [32,] 0.5013226 1.11245416 0.4941082 0.32368169 1.0049187 0.3626500
    ##  [33,] 0.4166904 0.36134115 0.7595294 0.37393573 0.3072063 0.3365738
    ##  [34,] 0.5313408 0.35849891 0.6673498 0.56365609 0.4382306 0.1512143
    ##  [35,] 0.5286527 1.45379176 0.4829628 0.47422169 0.4262232 0.4460704
    ##  [36,] 0.6091029 0.50589202 0.3676306 0.50702464 0.4772788 0.8072551
    ##  [37,] 0.6771488 0.77761313 0.5831288 0.28936204 0.5332314 2.0377695
    ##  [38,] 0.6264554 1.92694190 0.2041123 0.68510431 0.5054615 1.5261529
    ##  [39,] 0.3288963 0.68271239 0.2607515 1.05194873 0.5044334 0.6629995
    ##  [40,] 0.8152381 0.44193786 0.3979567 0.54973900 0.2999341 1.2352884
    ##  [41,] 0.7614984 1.64782988 0.3277079 1.57488604 0.3754955 0.1636546
    ##  [42,] 0.4712215 0.50590702 0.4856864 1.55877617 0.4669802 0.3028487
    ##  [43,] 0.4045976 0.35373461 0.3412215 0.23830267 0.3248775 0.2262100
    ##  [44,] 0.6532573 0.50057962 0.3400902 0.64087313 0.2934870 0.3055948
    ##  [45,] 0.4480326 0.37496372 0.4859608 0.47325031 0.6561574 1.5455609
    ##  [46,] 0.8529040 3.17577161 0.4340375 3.20470798 0.5568605 0.8968793
    ##  [47,] 0.2395640 0.59162212 0.7908959 1.98617492 0.5289343 0.6362244
    ##  [48,] 0.5181668 1.55776035 0.5094553 0.11279171 0.6963574 0.6369728
    ##  [49,] 0.2644998 1.93050938 0.5427391 2.96449392 0.3810693 0.2168712
    ##  [50,] 0.2243666 0.42362995 0.5564745 1.34603083 0.3608164 0.6150549
    ##  [51,] 0.4394764 0.47133285 0.6896791 0.65563437 0.4228586 1.6625092
    ##  [52,] 0.4099466 0.05831137 0.2894471 0.87072206 0.6136347 1.7175727
    ##  [53,] 0.3610210 1.79717195 0.9285944 1.00086909 0.3565593 0.8563013
    ##  [54,] 0.6511799 0.75058187 0.4756423 1.43170131 0.2797566 0.5391562
    ##  [55,] 0.3565869 0.21085777 0.2992580 0.93515944 0.2456878 0.4548140
    ##  [56,] 0.7467258 1.63056831 0.3449187 0.79828854 0.5914295 0.5947545
    ##  [57,] 0.5046483 0.13976626 0.7990417 1.43980195 0.4794611 0.8310693
    ##  [58,] 0.2913171 1.03479466 0.3909687 0.53208883 0.3088626 1.2483595
    ##  [59,] 0.2805155 1.38171159 0.3713790 0.42616622 0.4505354 0.6359667
    ##  [60,] 0.6827491 1.73894916 0.7665552 1.22101902 0.7265291 0.9113926
    ##  [61,] 0.4526594 0.49460688 0.6981830 1.88314153 0.2451375 0.1058607
    ##  [62,] 0.3932502 1.29289525 0.5115793 0.27210830 0.3823540 0.8878228
    ##  [63,] 0.3130202 0.20722718 0.5597254 1.85529796 0.3170503 0.2082780
    ##  [64,] 0.3105941 0.82080672 0.4554131 0.98541910 0.4078494 0.2275884
    ##  [65,] 0.2843480 0.21236726 0.1834007 0.38491696 0.5603372 0.7919588
    ##  [66,] 0.4046834 1.37113627 0.7891728 2.71853369 0.8354760 0.6455952
    ##  [67,] 0.5307424 0.36774098 0.1114898 0.81009562 0.2078483 0.5917506
    ##  [68,] 0.2229712 1.74971287 0.4642907 0.83690846 1.3145017 0.1781924
    ##  [69,] 0.5128896 0.52312567 0.6299906 1.40401373 0.3328664 1.5745764
    ##  [70,] 0.6450788 1.09538854 0.2686310 0.44026895 0.2648921 0.4585336
    ##  [71,] 0.3331482 0.99620696 0.4780323 0.91836438 0.3446602 0.8445993
    ##  [72,] 0.2883800 1.70810143 0.5249784 1.16868283 0.3335532 0.4244961
    ##  [73,] 0.1987106 0.33181234 0.2619714 0.56296930 0.5894529 0.4009462
    ##  [74,] 0.4586476 1.13890943 0.4256322 1.92405618 0.3078951 1.4197941
    ##  [75,] 0.4997141 1.03134619 0.3309206 0.41621520 0.2282744 1.7879319
    ##  [76,] 0.4529169 0.47584590 0.2592206 1.69031334 0.4685694 0.5103879
    ##  [77,] 0.5206975 1.06215771 0.4372292 0.44481960 0.8313662 1.1020544
    ##  [78,] 0.6734055 0.18941269 0.8636282 1.36409875 0.4996555 0.6900954
    ##  [79,] 0.6822681 2.16965933 0.2667727 1.65398216 0.5052993 1.1128015
    ##  [80,] 0.5568964 1.52945978 0.3028714 0.44658448 0.7700581 0.1110669
    ##  [81,] 0.4243622 0.58085090 0.4063621 0.15570944 0.3607631 0.5531962
    ##  [82,] 0.3672122 1.61279223 0.5811615 2.02120029 0.2512688 0.8698384
    ##  [83,] 0.4381467 1.92240570 0.3390897 0.41492607 0.3334197 0.5746801
    ##  [84,] 0.3415596 1.52848706 0.2132666 2.09047803 0.5463063 2.1502235
    ##  [85,] 0.5128963 0.29807603 0.3784194 1.65485622 0.6817265 0.6569377
    ##  [86,] 0.4582151 0.47862207 0.3477559 0.43852805 0.7942574 0.3307335
    ##  [87,] 0.2727940 1.85001732 0.5913916 1.71985106 0.8415704 1.3567643
    ##  [88,] 0.4909364 1.69393290 0.4270479 0.39483404 0.8340464 0.4205634
    ##  [89,] 0.8587672 1.48502305 0.4421671 0.88424135 0.9058848 1.7402318
    ##  [90,] 0.3327483 2.15440343 0.3293239 0.28511211 0.3295102 0.4479490
    ##  [91,] 0.3855843 1.03261471 0.3420145 0.27017766 0.4421578 0.8132169
    ##  [92,] 0.4887880 2.08596446 0.6866031 0.33659438 0.3389633 1.1708520
    ##  [93,] 0.2340642 0.99174373 0.3531240 0.34774279 0.7350956 1.2224079
    ##  [94,] 0.4218593 1.85445401 0.2235787 0.46020036 0.4899541 0.7193021
    ##  [95,] 0.3093352 1.41530940 0.4191734 0.98783648 0.3544063 0.6209747
    ##  [96,] 0.1708203 0.26032734 0.6530825 0.71485523 0.4587478 0.3763992
    ##  [97,] 0.4531759 1.70105066 0.4420513 0.15562986 0.6342534 0.1693586
    ##  [98,] 0.4794257 0.58388929 0.4158810 1.77448654 0.3951714 4.6960599
    ##  [99,] 0.4068465 0.89177467 1.0095915 1.38841888 0.4807707 1.8856725
    ## [100,] 0.4554992 3.04755333 0.4978789 0.66299356 0.6432687 0.7301521
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

    data.frame(pathname = osNode$Get('pathString', filterFun = isLeaf),
               path_probs = osNode$Get('path_probs', filterFun = isLeaf))

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

Risk Profile
------------

Further, the pathway probabilities can be used to give the distribution
of the terminal state values e.g. cost or time. This is called the risk
profile of the decision tree.

    osNode <- calc.riskprofile(osNode)
    print(osNode, "type", "path_prob", "path_payoff")

    ##                                                 levelName     type   path_prob path_payoff
    ## 1  LTBI screening cost                                      chance 1.000000000   0.3773341
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   1.2530973
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   1.7085965
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   2.9439955
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   4.3451783
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   4.6313104
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   5.8547883
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   6.2200240
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   8.0530897
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   6.6565492
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   7.4889695
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   7.2792128
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   7.9249493
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   7.4636945
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   2.2951944
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   2.6647204
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   3.3921631
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   4.5448196
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   4.0677877
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   4.4357750
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   4.6649785
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   6.0418852
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   5.2787078
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   5.4837571
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   5.8919641
    ## 26  ¦   °--No Screening                                    logical 0.062500000   4.3006506
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   6.8648468
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   7.6704420
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.6675522
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   1.1654311
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   2.6708844
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   5.5013627
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   3.6040393
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.8192251
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.9441116
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   5.9785831
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   5.8240291
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   6.1068214
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   8.4742949
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  10.7406028
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   9.7416749
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.6514936
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   2.3338931
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   2.1842500
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.4060848
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   2.8503426
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   3.4013028
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   3.2509432
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   3.3092326
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   4.5279892
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   5.6604710
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   5.0982356
    ## 53  ¦   °--No Screening                                    logical 0.062500000   1.3305458
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   1.4400918
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   2.3625044
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.7206893
    ## 57      ¦--Screening                                       logical 0.062500000   1.3639580
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   2.8419286
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   4.9970464
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   4.3817372
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   6.2599605
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   5.0698617
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   5.1063908
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   6.0163674
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   6.9245236
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   8.2632306
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  10.8343227
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   8.6879560
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   2.4590620
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   3.5080475
    ## 71      ¦       °--GP registered                            chance 0.006250000   4.1478367
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   6.8208294
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   4.2894686
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000   4.3004344
    ## 75      ¦               °--Test Positive                    chance 0.002625000   4.4808340
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   4.5230122
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   5.0765405
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   5.2151859
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   5.7321704
    ## 80      °--No Screening                                    logical 0.062500000   1.4508414
    ## 81          ¦--LTBI                                       terminal 0.025000000   2.9920830
    ## 82          °--non-LTBI                                   terminal 0.037500000   1.6402672

    plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
               osNode$Get('path_prob', filterFun = isLeaf)), type="h",
         xlab="payoff", ylab="probability")

![](README_files/figure-markdown_strict/unnamed-chunk-10-1.png)

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
