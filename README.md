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
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.20452881
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 1.45281254
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.14019542
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.36038724
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.16103483
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.60182538
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.01259665
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.95328041
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.04473310
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 3.85766788
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.40485030
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.06076004
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.77195134
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.30998969
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.02979384
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.76114861
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.38771998
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.64297597
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.35252082
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.09438751
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.48218108
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.38122974
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.11263451
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.16612182
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.40423310
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.26611241
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 3.79816650
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.91557131
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.47207511
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.93225372
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.08879733
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.04296462
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.86329037
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.38494849
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.43100538
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.23868588
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.30695087
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.54220918
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.47674324
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.33333409
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.91545447
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.22054490
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.52971334
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.23752626
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.93262117
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.33182073
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.63132715
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.23002553
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.61999683
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.74208100
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.75162624
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.81572648
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.52370825
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.14609406
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.03956663
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.08340493
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.01067342
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.96102181
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.84176772
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.35354681
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.86447955
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.41406332
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.04960855
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.86238335
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.10724412
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.44056266
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.27688799
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.75525359
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.17500997
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.59225139
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.67014629
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.43496785
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.01381681
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.31081740
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.10883885
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.81068316
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.57652515
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.41228535
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.49330528
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.43783883
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.19007523
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.64960127

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.39092471
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.92260599
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.42181457
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.69185411
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.16103483
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.56860046
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.01259665
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.60173745
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.04473310
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.81489182
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.40485030
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.31145577
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.77195134
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.30998969
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.99540417
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.76114861
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.72736182
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.64297597
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.23596040
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.09438751
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.24269878
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.38122974
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.42776618
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.16612182
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.40423310
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 3.26860939
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 3.79816650
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.91557131
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.25052411
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.51991885
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.07360427
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.04296462
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.64104604
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.38494849
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.35012825
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.23868588
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.11864018
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.54220918
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 3.18659142
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.33333409
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.91545447
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.00607115
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.52971334
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.98546454
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.93262117
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.37648639
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.63132715
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.76365341
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.61999683
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.92551454
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.75162624
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.81572648
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.48217760
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.14609406
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.03956663
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.39056874
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.49648410
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.93293647
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.84176772
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.49057346
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.86447955
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.61980955
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.04960855
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.26440509
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.10724412
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.77410618
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.27688799
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.75525359
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.05299992
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.59225139
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.04024841
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.43496785
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.96544617
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.31081740
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.49696284
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.81068316
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.17919297
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.41228535
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.49330528
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.06579086
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.19007523
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.64960127

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.25655631
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.22026577
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.24160433
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.64205333
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.03631820
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.56881512
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.82100921
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.79368266
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.98333078
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.57907303
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.09378351
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.83645991
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.06487222
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 2.38374100
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.32436399
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.58049626
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.23041371
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.17587152
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.20815133
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.17408591
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.12327314
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.03484293
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.37606754
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.23996277
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.26146062
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.63945875
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.10311247
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.33035627
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.29603992
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.55880938
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.51921837
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.49233693
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.80570900
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.57333008
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.76951826
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.86122273
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.23808907
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.25702907
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.53660115
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.30561176
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.40985644
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.71601917
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.85485952
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.43518839
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.40998799
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.64865933
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.78369264
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.14296354
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.04320296
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.43334219
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.18960504
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.38818454
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.62535028
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.55814196
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.67015582
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.50991957
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.38171646
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.67429336
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.05209484
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.63363855
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.05323287
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.00283138
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.67259142
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.76002483
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.06880024
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.46461587
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.46124318
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.49157798
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.85257247
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.68136384
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.45006735
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.15478761
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.59532464
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.72557783
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.12488594
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.19916631
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.21712017
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.19412694
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.09536661
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.65796181
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.14502204
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 2.66658833

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]      [,5]       [,6]
    ##   [1,] 0.5550343 1.47350608 0.4084557 1.38051374 0.2423660 2.57480755
    ##   [2,] 0.3893466 1.25656999 0.6012169 1.76249517 0.5685509 1.30583272
    ##   [3,] 0.6271616 0.37572510 0.6448934 0.76792079 0.6903469 0.76048133
    ##   [4,] 0.4980649 0.38456957 0.3839793 0.71589851 0.3276499 0.37335381
    ##   [5,] 0.4169249 0.78033626 0.8417163 0.80970794 0.2367188 0.77345424
    ##   [6,] 0.5353649 0.83427650 0.1970253 0.13760200 0.4614753 1.12633322
    ##   [7,] 0.3508992 1.00747259 0.5727156 0.85807181 0.4526967 0.77995819
    ##   [8,] 0.8094486 1.16481820 0.4790065 1.13616654 0.8906177 0.82028007
    ##   [9,] 0.6833432 0.18025665 0.2546406 3.41253168 0.3140171 1.04042407
    ##  [10,] 0.5070484 1.00325770 0.8027311 0.32109891 0.2392018 0.77516861
    ##  [11,] 0.2156965 0.52392356 0.4517180 2.01132993 0.3658811 0.16371396
    ##  [12,] 0.2925481 0.50057856 0.4373904 2.07223905 0.6762658 1.69716844
    ##  [13,] 0.4991300 1.08941091 0.3144533 1.09044937 0.5403566 1.29701673
    ##  [14,] 0.2716956 1.20754080 0.2705217 0.58261024 0.4918066 2.20766467
    ##  [15,] 0.4635173 0.88604167 0.3814836 0.25906377 0.5418367 0.94625953
    ##  [16,] 0.6406557 0.96997033 0.3424419 0.35490258 0.5206768 1.76475026
    ##  [17,] 0.3401429 2.58746599 0.3702789 0.57643131 0.4258297 0.17190425
    ##  [18,] 0.4585627 0.97661703 0.3977925 1.87254337 0.5691373 1.04283697
    ##  [19,] 0.5483728 0.68617054 0.8903441 1.18249228 0.5021819 0.53724134
    ##  [20,] 0.2462623 0.91865028 0.3500681 0.17285038 0.5325503 2.07565100
    ##  [21,] 0.2051127 0.72735993 0.5772080 1.68254328 1.0719615 1.17858752
    ##  [22,] 0.6239530 0.87932079 0.2608636 2.15802751 0.3540363 0.23154392
    ##  [23,] 0.4820615 0.41542063 0.5057690 0.92534710 0.3716860 0.64440217
    ##  [24,] 0.7116893 1.42674126 0.2770031 0.02930953 0.3611963 0.49644532
    ##  [25,] 0.6891013 0.41100641 0.3267313 0.48333954 0.6211333 0.72522458
    ##  [26,] 0.1719006 0.15411519 0.5220736 1.03274609 0.3299438 0.18628386
    ##  [27,] 0.6396087 1.08862613 0.6235602 1.24016290 0.5158589 1.97060698
    ##  [28,] 0.2716950 1.20645719 0.3287452 0.49798350 0.3903339 0.74040485
    ##  [29,] 0.6014640 1.35918770 0.2954262 0.14661460 0.5670568 0.68014537
    ##  [30,] 0.3284461 0.84388697 0.4754898 1.44270901 0.6073185 2.47716215
    ##  [31,] 0.5944070 0.07702712 0.5675052 1.16867835 0.2802507 0.52688903
    ##  [32,] 0.2800901 1.65278332 0.4393813 1.78822258 0.4849662 1.06986816
    ##  [33,] 0.6240702 2.40311936 0.3743772 0.90005317 0.3356242 1.04585376
    ##  [34,] 0.5808852 2.35559818 0.4804332 2.41273698 0.4629959 1.73792790
    ##  [35,] 0.5410726 0.76326666 0.8875688 0.24585563 0.2837750 0.87662985
    ##  [36,] 0.7309910 0.31413866 0.6133093 1.22717228 0.7112071 0.75263760
    ##  [37,] 0.4357898 0.74072509 0.4797542 2.73900842 0.4340302 1.39412342
    ##  [38,] 0.6743494 0.70024647 0.5519557 1.39765426 0.4736023 1.34531090
    ##  [39,] 0.3956844 1.18579151 0.3880369 0.38214684 0.5140528 3.68125204
    ##  [40,] 0.6322496 0.28617080 0.3219761 1.04570573 0.3205075 0.44060383
    ##  [41,] 0.6240116 0.64838355 0.4413518 1.10166547 0.3745310 0.02238332
    ##  [42,] 0.7064539 0.12861256 0.3471116 1.75146264 0.7505135 1.00115510
    ##  [43,] 0.4853569 0.53928808 0.5655016 0.40573076 0.5529260 1.04123248
    ##  [44,] 0.6578731 0.15835476 0.6493480 0.94251152 0.3895281 1.75459054
    ##  [45,] 0.8094495 0.14002382 0.2236483 0.64304452 0.2719269 1.59313271
    ##  [46,] 0.3301647 1.22106756 0.2513393 1.17190182 0.1688362 0.29897070
    ##  [47,] 0.2464046 0.84349206 1.0069170 1.25438241 0.8460398 1.20686342
    ##  [48,] 0.2595907 4.28250638 0.8098800 2.17298054 0.3191955 0.48881114
    ##  [49,] 0.5601830 0.40172342 0.3265533 1.84458048 0.2987450 0.38192845
    ##  [50,] 0.6000831 0.58321435 0.3525604 1.68780576 0.5706969 0.68913174
    ##  [51,] 0.3316094 1.56614815 0.8663186 0.39795914 0.4372565 2.54214238
    ##  [52,] 0.4290716 0.26858370 0.5317882 2.39164703 0.4990838 0.32647422
    ##  [53,] 0.5852332 1.11339732 0.3686470 0.99981384 0.5079047 2.02129433
    ##  [54,] 0.5737763 0.67752221 0.6396311 0.77097099 0.6243107 0.11335097
    ##  [55,] 0.4842645 0.91514816 0.4576371 1.35402277 0.2543221 0.14291244
    ##  [56,] 0.4018045 4.21209711 0.5353719 0.63818770 0.5394746 2.85889432
    ##  [57,] 0.5472246 1.21243652 0.5069924 0.52482121 0.3204851 0.28952774
    ##  [58,] 0.4357473 1.76281498 0.2244285 0.88936326 0.3899635 1.88224726
    ##  [59,] 0.2608219 0.96922570 0.3479800 0.37139189 0.5071674 0.61968448
    ##  [60,] 0.3785269 1.79797595 0.5539644 0.77498685 0.5449932 1.45432362
    ##  [61,] 0.5989844 1.36752900 0.3313860 0.33769537 0.5721192 0.33492688
    ##  [62,] 0.2866434 0.73264595 0.9431533 0.88270738 0.8043598 1.41912168
    ##  [63,] 0.4108844 2.12048473 0.3638844 0.81301658 0.5581168 1.04499849
    ##  [64,] 0.6952320 0.86346052 0.6460899 0.80288943 0.4165204 0.93463027
    ##  [65,] 0.3082690 0.48270600 0.2905764 0.52838128 0.5907371 0.39855273
    ##  [66,] 0.5580995 1.10409482 0.7616490 0.31480032 0.3050750 3.10879060
    ##  [67,] 0.6533885 0.54914135 0.3243514 2.39574879 0.5262158 0.57587529
    ##  [68,] 0.4125993 0.42010641 0.5944583 0.42435666 0.5124796 2.03017644
    ##  [69,] 0.2496136 2.10871402 0.6696967 1.32904451 0.6090005 0.55635576
    ##  [70,] 0.3099870 0.80085057 0.3213720 0.61178910 0.5209719 0.60891395
    ##  [71,] 0.4617675 0.19712572 0.4372785 2.05987215 0.7452645 0.69438593
    ##  [72,] 0.3171135 0.45740388 0.3281494 0.20981808 0.4806958 1.28438111
    ##  [73,] 0.6171011 1.03634797 0.4848209 0.50912873 0.5798646 0.43525820
    ##  [74,] 0.7845014 0.07900409 0.5217311 0.18620298 0.5159708 0.50588195
    ##  [75,] 0.4969884 0.49388663 0.9874945 0.54508252 0.2847356 0.84964513
    ##  [76,] 0.5490790 0.21399029 0.3758509 0.84228739 0.4843224 0.78043161
    ##  [77,] 0.5575060 0.80945883 0.4194851 0.69020360 0.5027123 0.27834903
    ##  [78,] 0.5084178 3.22453232 0.2087277 0.98128477 0.3660684 0.38771191
    ##  [79,] 0.2665276 1.53962687 0.2523962 0.89466153 0.4677405 0.81611340
    ##  [80,] 0.4051933 0.21351344 0.3757818 1.22346039 0.6747249 1.16420911
    ##  [81,] 0.3999495 1.26184811 0.9846468 1.77005493 0.1880502 0.99424473
    ##  [82,] 0.5139265 1.20618202 0.4279140 1.72538461 0.2644046 2.56341035
    ##  [83,] 0.7503328 1.14677000 0.3529503 1.04105472 0.3086592 1.48809188
    ##  [84,] 0.1886279 1.06991253 0.3707277 1.47837641 0.3532211 0.94086184
    ##  [85,] 0.3369497 2.21601891 0.5386510 0.53080049 0.7185882 1.62226510
    ##  [86,] 0.4047489 1.07236758 0.4134829 1.52731913 0.6077384 0.61935115
    ##  [87,] 0.8544003 0.78302365 0.4176697 0.51714371 0.5999406 1.06548806
    ##  [88,] 0.3176079 0.65447921 0.5061241 0.59678592 0.5069205 1.14064471
    ##  [89,] 0.4925181 1.66429279 0.6636150 0.86518533 0.2575760 0.44037512
    ##  [90,] 0.1949722 1.53599409 0.6480992 0.23695965 0.8171368 2.42416903
    ##  [91,] 0.4352389 0.06646100 0.5555194 0.32503219 0.4556506 1.74903525
    ##  [92,] 0.3609916 0.17921023 0.6875402 0.88983046 0.4925911 0.51236056
    ##  [93,] 1.0321087 0.11650981 0.3604845 0.34578820 0.3684960 0.45860142
    ##  [94,] 0.8976327 1.18712569 0.6390442 0.81196034 0.6148562 0.28864022
    ##  [95,] 0.4042438 0.36611877 0.4740532 0.78392390 0.5257726 0.62432561
    ##  [96,] 0.3932810 0.74881741 0.2676519 1.65013947 0.6463048 1.17038158
    ##  [97,] 0.6685101 0.95205963 0.5025657 0.06896274 0.2660597 0.25010906
    ##  [98,] 0.1888124 0.36696467 0.2242987 0.57457704 0.3940203 2.23082817
    ##  [99,] 0.3076373 1.49663636 0.3475544 1.16936292 0.5066158 0.86790013
    ## [100,] 0.1636996 5.75701101 0.3400363 0.70304119 0.5579662 0.67472114
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
    ## 1  LTBI screening cost                                      chance 1.000000000   0.5122797
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   1.9924574
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   2.1561570
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   2.4193980
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   2.5342702
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.9626284
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.0198366
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   3.8108042
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   4.4797915
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   4.3534965
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   5.5217429
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   4.9942247
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   5.1155132
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.7272406
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   2.5477144
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   2.8075005
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   3.2668218
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   3.8542868
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   3.8778691
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   4.3030079
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   4.3256550
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   5.0815478
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   5.0623820
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   5.3051098
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   5.8019568
    ## 26  ¦   °--No Screening                                    logical 0.062500000   7.7494684
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   8.6639511
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000  16.7348316
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.7730491
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   1.1130854
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   2.1492034
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   3.5055032
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   3.3831985
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   4.4399016
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.3831539
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   5.4013896
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   4.7934261
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   5.2173323
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   5.7370937
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   6.3239777
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   6.4084333
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.4371126
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.4807861
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   2.2035070
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.8132101
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   2.8711278
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   2.9971130
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   3.6988868
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   4.8306362
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   5.3263338
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   7.3762180
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   5.4463789
    ## 53  ¦   °--No Screening                                    logical 0.062500000   1.4760903
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   1.9846620
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   2.3087778
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.8204516
    ## 57      ¦--Screening                                       logical 0.062500000   1.3784178
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   1.9203677
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   2.2882533
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   2.9073568
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.2780991
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.1815965
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   5.8068361
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   4.3766991
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   4.8459016
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   4.5578388
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   4.6504710
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   4.7067260
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   3.0683327
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   4.3882191
    ## 71      ¦       °--GP registered                            chance 0.006250000   5.9732335
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   8.4160083
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   8.3719602
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000  11.3644085
    ## 75      ¦               °--Test Positive                    chance 0.002625000   8.8062644
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   9.6409686
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   9.4192406
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   9.8329956
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   9.8227873
    ## 80      °--No Screening                                    logical 0.062500000   1.4951727
    ## 81          ¦--LTBI                                       terminal 0.025000000   1.5132335
    ## 82          °--non-LTBI                                   terminal 0.037500000   2.6076674

    plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
               osNode$Get('path_prob', filterFun = isLeaf)), type="h",
         xlab="payoff", ylab="probability")

![](README_files/figure-markdown_strict/unnamed-chunk-12-1.png)

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
