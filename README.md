treeSimR
========

An R package for easy forward simulating probability decision trees,
calculating cost-effectiveness and PSA.

Currently contains functions to:

-   read-in and check tree object
-   simulate final outcomes
-   Monte-Carlo simulate multiple simulations

TODO

-   optimal decision function
-   plotting functions: C-E plane, C-E curve (others)

Read-in trees
-------------

    library(yaml)
    library(data.tree)
    devtools::load_all(".")

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

Better still, use the package function to do this, checking for tree
integrity and defining an additional costeffectiveness.tree class.

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
defined for each. This could be the cost or health detrminent.

    rpayoff <- osNode$Get(sampleNode)
    osNode$Set(payoff = rpayoff)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.82019736
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.38080785
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 1.74460970
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.04067417
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.38680176
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.53353334
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.18931035
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.52112361
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.68606771
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 2.62054993
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.79198136
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.10367548
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.98573206
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.95048157
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.46766027
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.11392417
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.08833898
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.70500315
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.19814880
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.09694015
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.61902762
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.37917998
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.66521626
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.78032955
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.41692745
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.82151884
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.92523402
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.51971309
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.87364106
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.62592528
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.01192190
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.62129651
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.26055670
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.09760245
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.01201039
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.75184540
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.27293986
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.17523101
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.08689138
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.14469446
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.49520999
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.40434654
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.98963483
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.94738515
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.70294457
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.55035916
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.52778056
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.51810406
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.15167912
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.34388262
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.16835572
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.38347310
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.10752717
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.23844250
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.71725563
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.10385520
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.55986668
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.69489501
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.24835113
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.04005879
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.45517985
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.69340230
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.62395884
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.32497614
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.10325034
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.73598757
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.36895014
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.07714208
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.11826024
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.65563558
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.08011226
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.98582019
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.10748663
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.68846032
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.64003819
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.26091124
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.37109050
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.08882555
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.44591659
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.05794306
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.97136113
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.57086912

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each not from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.27979014
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.42281428
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.20933566
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.46631930
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.38680176
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.77899649
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.18931035
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.10901713
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.68606771
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.89824247
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.79198136
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.20216022
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.98573206
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.95048157
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.37102336
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.11392417
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.81363422
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.70500315
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.65105388
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.09694015
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.83313682
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.37917998
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.39794276
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.78032955
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.41692745
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.48192147
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.92523402
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.51971309
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.26379539
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.52945119
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.16727325
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.62129651
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.29688661
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.09760245
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.06387524
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.75184540
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.19654780
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.17523101
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.47992833
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.14469446
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.49520999
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.95053152
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.98963483
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.38669397
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.70294457
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.60821204
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.52778056
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.76966522
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.15167912
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.41387162
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.16835572
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.38347310
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.52573038
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.23844250
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.71725563
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.43255088
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.39913760
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.57907480
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.24835113
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.19933588
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.45517985
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.54371328
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.62395884
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.58134585
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.10325034
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.83456916
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.36895014
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.07714208
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.01747559
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.65563558
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.88805339
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.98582019
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.16093547
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.68846032
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.39859035
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.26091124
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.40105661
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.08882555
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.44591659
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.33106593
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.97136113
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.57086912

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.30332602
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.20075886
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.46024165
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.17731794
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.74323580
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.20005905
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.67132831
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.99543677
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.73598519
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 2.11463877
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.75207527
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 4.29672064
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.53316934
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 2.19579152
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.66364868
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.18825429
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.47086740
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.27329988
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.17814579
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.86075818
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.82230723
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.39148413
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.34953998
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.71684641
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.41587356
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.34279380
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.49314158
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.24256194
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.57642123
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.40197071
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.80658285
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.35758332
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.65887380
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.50406945
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.26072022
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.28011990
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.52090899
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.69349143
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.04287186
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.61350233
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.77699348
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.80130000
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.86402547
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.13922452
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.37295289
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.52575464
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.91214234
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.26750715
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.22332045
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.00170337
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.74718640
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.25508476
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.90371423
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.60344979
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.10389052
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.43612398
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.24139634
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.46594592
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.11870750
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.04615731
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.89563530
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.84796021
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.85771641
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.35365532
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.79060616
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.38824491
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.34726924
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.17039064
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.49963945
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.26001320
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.98908541
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.07621439
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.57226130
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.27742976
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.96865780
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 5.67346838
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.88872429
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.16649747
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.01846825
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.50309958
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.12167046
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.75738566

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisation for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]       [,5]       [,6]
    ##   [1,] 0.2305792 0.33340770 0.5198195 1.79114111 0.57818631 0.94478524
    ##   [2,] 0.3584413 1.37083291 0.3095722 1.02640438 0.34550337 1.10196463
    ##   [3,] 0.2993599 0.37748783 0.5162063 0.70928778 0.60513284 0.43963943
    ##   [4,] 0.3986020 0.78146985 0.3973478 0.97442454 0.32607433 1.16765749
    ##   [5,] 0.6208113 0.70203809 0.6386587 0.58974678 0.35088377 0.21959280
    ##   [6,] 0.6620302 0.34973123 0.3675732 3.60802309 0.53846468 0.93069104
    ##   [7,] 0.3315650 0.82393694 0.2299921 1.23264904 0.71159855 0.15975008
    ##   [8,] 0.4036854 0.05674091 0.3593760 1.46004930 0.50107782 2.85726636
    ##   [9,] 0.2171778 1.01664668 0.3123177 1.36135091 0.52714989 0.17947347
    ##  [10,] 0.3928303 0.67298271 0.2546877 0.43916861 0.42114770 0.29785323
    ##  [11,] 1.0174348 1.07192275 0.3631355 1.21440310 0.57409574 0.06501868
    ##  [12,] 0.3491342 0.76473089 0.3222415 0.57067459 0.39549739 0.17880485
    ##  [13,] 0.3597752 1.22678097 0.3421334 1.88280146 0.41133829 1.46767345
    ##  [14,] 0.3281760 1.24717139 0.4872960 0.75020654 0.54824858 1.03464719
    ##  [15,] 0.6876201 0.65437780 0.5905332 1.96625442 0.59347857 0.72890426
    ##  [16,] 0.4618111 2.88322007 0.3286115 2.32286256 0.28684908 0.59554887
    ##  [17,] 0.6940652 1.07315076 0.2959901 0.28062652 0.53566690 1.32370187
    ##  [18,] 0.3793169 0.66573035 0.4901263 0.16650522 0.32505809 1.46263555
    ##  [19,] 0.5298286 0.52964966 0.4610943 0.14667861 0.53398952 2.29111785
    ##  [20,] 0.2600675 1.24783159 0.7192319 0.86233650 0.77360348 0.18059718
    ##  [21,] 0.4601851 0.30529206 0.3459502 1.84548016 0.30580887 0.25243547
    ##  [22,] 0.6888359 0.51643202 0.4921530 0.72122882 0.29085845 1.37101666
    ##  [23,] 0.5240788 0.74882712 0.4686377 0.37234914 0.21082045 0.67435095
    ##  [24,] 0.3107091 1.01249137 0.4791786 2.73822304 0.43264692 1.67346942
    ##  [25,] 0.4615935 0.75413375 0.5974913 0.67304434 0.53511254 0.47494911
    ##  [26,] 0.5210160 0.94917244 0.4094736 0.67076823 0.62106938 0.95934591
    ##  [27,] 0.4395235 0.52259682 0.4776404 0.98089018 0.37807138 1.20743469
    ##  [28,] 0.3280185 0.96098618 0.3512462 0.66617121 0.45488923 0.38241540
    ##  [29,] 0.5614695 1.08552409 0.5971054 1.96982477 0.37641430 0.75629002
    ##  [30,] 0.1692334 0.47520767 0.5473278 0.27780795 0.37417977 0.81476887
    ##  [31,] 0.6660380 0.73421372 0.2715891 0.93071859 0.58076171 0.32250801
    ##  [32,] 0.4657251 1.03632552 0.2945899 0.50202727 0.44445089 2.16396075
    ##  [33,] 0.3657796 2.59474613 0.7077596 0.40173383 0.83998117 0.29301654
    ##  [34,] 0.4771392 0.50187164 0.3480651 0.93285801 0.57788198 0.71134535
    ##  [35,] 0.8122444 0.31941765 0.5166745 0.10300109 0.35778965 2.77905756
    ##  [36,] 0.5792520 2.94004400 0.5842297 0.56920937 0.39049241 0.77732402
    ##  [37,] 0.6732463 1.79727704 0.4599917 0.87394106 0.35140442 1.94162547
    ##  [38,] 0.3803147 0.40015732 0.6049668 0.60862713 0.49298851 0.56246341
    ##  [39,] 0.1818363 0.87003244 0.1933197 1.73289107 0.49151299 0.29509604
    ##  [40,] 0.2931017 0.29937107 0.6767887 0.76466109 0.42061698 0.94544011
    ##  [41,] 0.6231221 1.54986550 0.3603379 0.84975023 0.79998273 2.37862895
    ##  [42,] 0.6707190 1.64324380 0.4270688 0.29354202 0.18165226 3.14806379
    ##  [43,] 0.2218548 0.38863430 0.5822044 0.59173865 0.27638399 1.04564154
    ##  [44,] 0.3301503 2.96665563 0.2797657 0.39038729 0.40920359 1.36685161
    ##  [45,] 0.5991307 1.50170721 0.2141838 1.17194221 0.29959347 0.43202003
    ##  [46,] 0.3311010 1.42156791 0.7084017 1.29115945 0.69317544 0.63965597
    ##  [47,] 0.1920742 0.22846036 0.3412126 0.18735062 0.24043098 1.12069135
    ##  [48,] 0.3493986 0.78000007 0.5530911 0.10380087 0.57682063 0.81259233
    ##  [49,] 0.3575175 0.82161818 0.4695622 1.66044500 0.45349387 1.15400609
    ##  [50,] 0.3106777 1.32519180 0.4247381 0.36925530 0.67591513 3.18569777
    ##  [51,] 0.3308854 0.32592734 0.3780550 0.38883609 0.84267981 2.03828708
    ##  [52,] 0.4272423 2.23543919 0.3267432 0.37834841 0.22750700 1.01814474
    ##  [53,] 0.5310072 2.09219589 0.4704639 1.05599008 0.31442549 2.98291088
    ##  [54,] 0.8704226 0.10883053 0.4762194 1.61602992 0.38900385 1.97623429
    ##  [55,] 0.3960560 0.58041838 0.5541645 0.38957679 0.09730931 1.09127451
    ##  [56,] 0.3835983 1.53310227 0.1580085 1.25311834 0.39428941 0.09412331
    ##  [57,] 0.3066237 0.11327006 0.3640435 0.61787837 0.83185189 1.29946560
    ##  [58,] 0.5872963 1.13926167 0.3106855 0.13026500 0.49129916 0.55219160
    ##  [59,] 0.3540460 1.41989331 0.7407435 0.41076453 0.53760398 1.12153256
    ##  [60,] 0.5047358 2.72401382 0.3641992 1.91488589 0.52869333 0.31715568
    ##  [61,] 0.3415916 0.42619653 0.8767736 1.35516945 0.37510008 0.66904201
    ##  [62,] 0.8759408 0.25556733 0.5013819 1.28098600 0.41024426 2.00766763
    ##  [63,] 0.4252948 0.71723125 0.2398519 1.56016548 0.50080778 0.28614425
    ##  [64,] 0.5957296 0.47010018 0.5749048 0.57483892 0.57473340 1.31854453
    ##  [65,] 0.6470271 0.23370998 0.6794442 1.23018944 0.32975523 1.05303050
    ##  [66,] 0.3533383 0.19305902 0.4801226 0.90859765 0.66205503 1.45783922
    ##  [67,] 0.1777400 0.35397696 0.6643179 0.86463957 0.47709506 0.60434152
    ##  [68,] 0.4980443 0.89126517 0.7780035 0.16194740 0.70189301 0.81223634
    ##  [69,] 0.5471317 0.86687300 0.4078122 0.97072209 0.60165329 0.55222295
    ##  [70,] 0.2967350 0.81077629 0.8980344 0.39910642 0.55782701 1.95777290
    ##  [71,] 0.4075197 1.53040229 0.2170135 2.56732168 0.65548194 0.20063636
    ##  [72,] 0.4726145 1.86281365 0.4018938 2.14922012 0.67311544 0.47831671
    ##  [73,] 0.2452011 2.82543287 0.3606711 0.90589078 0.49810963 0.84266889
    ##  [74,] 0.5788764 2.59111267 0.3845286 0.68295610 0.43312380 3.52665417
    ##  [75,] 0.6605805 0.85721454 0.7679099 0.81502211 0.39025007 0.84555939
    ##  [76,] 0.4909179 0.69388520 0.8288076 1.70532673 0.53280158 0.58040810
    ##  [77,] 0.3679965 0.57579526 0.2288707 0.61886748 0.43549371 0.66996132
    ##  [78,] 0.3057609 0.61269499 0.3844894 0.98700227 0.29770246 2.71494857
    ##  [79,] 0.2354515 0.50612890 0.9152078 1.91681926 0.48972728 0.80661428
    ##  [80,] 0.5949235 0.61230466 0.6224363 0.62598357 0.34426614 0.96358728
    ##  [81,] 0.6247782 2.36423401 1.0184911 0.04637506 0.53217414 1.19453754
    ##  [82,] 0.5626857 0.42915693 0.3399051 1.14962891 0.29491379 0.97581138
    ##  [83,] 0.1704350 0.34961238 0.3068447 0.37003220 0.62988546 1.67882441
    ##  [84,] 0.4841448 0.35999127 0.6437234 2.42092833 0.47643292 1.53944023
    ##  [85,] 0.2694150 1.11068252 0.6978201 0.93303294 0.32859362 0.55720892
    ##  [86,] 0.3273773 1.74789085 0.4549441 1.37111759 0.33976526 0.95955578
    ##  [87,] 0.2450320 1.15193751 0.3761741 0.50192397 0.47123120 0.45224187
    ##  [88,] 0.4190007 3.03042008 0.2946885 0.80775327 0.70388837 0.79144497
    ##  [89,] 0.5353271 0.55781080 0.4290865 0.14195397 0.37366589 1.53424267
    ##  [90,] 0.6321819 2.01917954 0.6127675 1.63630106 0.31092823 0.77733648
    ##  [91,] 0.3525002 0.28281847 0.5032175 0.18521771 0.50780829 0.78299978
    ##  [92,] 0.4631830 1.83569176 0.3712277 0.93997342 0.38666673 0.44026335
    ##  [93,] 0.3813119 0.56398818 0.6634231 0.68237356 0.62819216 0.32541155
    ##  [94,] 0.6570128 0.23857989 0.6012310 0.33197220 0.61653972 1.05459158
    ##  [95,] 1.0562662 1.63658974 0.7200890 1.31024482 0.35516178 0.44275939
    ##  [96,] 1.1323714 1.41744866 0.7022261 0.68108873 0.43536766 0.43252822
    ##  [97,] 0.4964660 0.59025574 0.7835828 1.03463721 0.72993306 1.28915154
    ##  [98,] 0.4454725 2.35390790 0.4226265 0.47772295 0.46710938 0.05968219
    ##  [99,] 0.4228120 0.40576496 0.6169047 1.47236587 0.37174715 0.44279037
    ## [100,] 0.2146961 0.31017188 0.3552602 1.44508924 0.46570484 1.42997856
    ## 
    ## $`node names`
    ## [1] "LTBI screening cost/under 40k cob incidence/Screening"    "LTBI screening cost/under 40k cob incidence/No Screening" "LTBI screening cost/40-150k cob incidence/Screening"      "LTBI screening cost/40-150k cob incidence/No Screening"   "LTBI screening cost/over 150k cob incidence/Screening"    "LTBI screening cost/over 150k cob incidence/No Screening"

Optimal decisions
-----------------

We can get the software to calculate the optimal decision for us, rather
than returning the expections to compare

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
