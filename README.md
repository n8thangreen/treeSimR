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

The package leans heavily on the `data.tree` package, (introduction
[here](https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html)
and examples
[here](https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html)
).

Read-in trees
-------------

    library(yaml)

    ## Warning: package 'yaml' was built under R version 3.3.1

    library(data.tree)

    ## Warning: package 'data.tree' was built under R version 3.3.1

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

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 1.184989202
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 1.022370456
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 1.350430961
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 2.111264550
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.103728648
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 3.182956536
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.913578572
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.059539990
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.426259239
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.795489983
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.610985554
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.113169596
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.798766588
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.028053074
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.196333258
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.739523318
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.099790871
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.065556765
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.079057976
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.417202433
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 6.265767248
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.245967544
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.317109031
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.051096852
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.465630272
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.421519896
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.726378489
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.571043359
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.063841962
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.397915464
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.324642812
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.311638484
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.050810704
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.273939055
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.198404768
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.120107038
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.250526760
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.229975600
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.882980361
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.901682202
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.410266449
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.031998378
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.338218322
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.166053719
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.229932958
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.099691922
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.675858314
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.400557832
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.836615815
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.346486486
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.659557123
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.013279109
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.883368955
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.150329160
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.553301948
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 1.822946169
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.768388259
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.025887611
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.223653400
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.513898534
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.764787130
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.777380539
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.682264087
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.104759432
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.234074620
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.649561647
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.116742502
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.368219681
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.396729911
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.059931652
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.041444242
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.641262407
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.375120160
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.206586260
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.486764886
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.105844615
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.855761677
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.008745379
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.698615683
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.101900241
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.886284017
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.119661199

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.213143178
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.390092561
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.327192833
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.895209324
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.103728648
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.134294661
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.913578572
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.976912531
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.426259239
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.969330090
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.610985554
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.620114747
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.798766588
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.028053074
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.413562009
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.739523318
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.294381705
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.065556765
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.425079410
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.417202433
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.190053866
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.245967544
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.387545343
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.051096852
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.465630272
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.233177411
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.726378489
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.571043359
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.183751662
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.342893815
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.999961178
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.311638484
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.188264462
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.273939055
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.706501715
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.120107038
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.889181126
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.229975600
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.733961488
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.901682202
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.410266449
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.371614082
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.338218322
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.590816883
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.229932958
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.754761847
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.675858314
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.402372896
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.836615815
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.504627174
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.659557123
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.013279109
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.392112833
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.150329160
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.553301948
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.278728489
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.288603629
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.543759569
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.223653400
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.135745523
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.764787130
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.128122075
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.682264087
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.929338877
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.234074620
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.863721637
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.116742502
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.368219681
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.610654947
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.059931652
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.466705715
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.641262407
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.803247119
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.206586260
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.940909624
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.105844615
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.030520797
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.008745379
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.698615683
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.826310326
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.886284017
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.119661199

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.35550319
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.38319064
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.76654651
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.55588605
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.09124163
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.79847348
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.39039798
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.27372449
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.58956275
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.23004366
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.46501621
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.63512933
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.20605304
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.30745274
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.51029998
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.11122100
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.66452895
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.77990197
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.99431294
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.50230139
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.91814567
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.64703033
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.41345523
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.76073687
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.45720344
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.76621605
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.46437710
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.96744202
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.46446152
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.48988315
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.40683988
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 3.19205681
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.32504290
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.03153682
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.51020134
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.06228183
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.66657722
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.47722590
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.74469816
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.89989384
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.42637037
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.55269272
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.58128563
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.80044617
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.68715596
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.64692099
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.35168291
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.57248993
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.80699405
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.10130572
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.13281925
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.33558837
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.36796295
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.34488927
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.05001207
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.57436058
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.26863624
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.64329170
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.59439658
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.01383267
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.42099443
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.26872668
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.27412397
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.53834272
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.65254036
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.14193536
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.16356164
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.35901884
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.43125328
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.02055277
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.05758043
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.30333996
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.45929410
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.94187672
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.14282914
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.49675555
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.31267490
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.49807364
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.58549289
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 2.02880609
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.24336069
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 2.55243636

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]      [,2]      [,3]       [,4]      [,5]       [,6]
    ##   [1,] 0.3549229 2.1086894 0.5900702 0.59905867 0.6461181 1.10360595
    ##   [2,] 0.3847138 0.3790326 0.2923957 0.28089325 0.3239520 0.60071856
    ##   [3,] 0.1954834 0.6227763 0.3671127 0.85014530 0.5951450 1.23230851
    ##   [4,] 0.6800870 0.3407017 0.4600140 0.67653840 0.5210030 0.56630226
    ##   [5,] 0.4575913 1.5112331 0.2262998 1.01611609 0.5428594 0.98536735
    ##   [6,] 0.2509969 0.1369688 0.2350230 2.78487966 0.8138485 1.48059936
    ##   [7,] 0.3647300 1.2297284 0.2609889 0.56580561 0.6935820 0.84047268
    ##   [8,] 0.5693592 0.9714530 0.5238918 0.31728724 0.6984079 1.23805920
    ##   [9,] 0.4525393 0.8683962 0.4484573 2.53135119 0.7528161 0.88453251
    ##  [10,] 0.6441179 2.7070767 0.3963492 2.02465681 0.2030186 1.62411135
    ##  [11,] 0.5637605 0.5172733 0.3962122 1.94056752 0.5174880 0.87192752
    ##  [12,] 0.3043297 1.2002897 0.1652906 0.17633069 0.3819246 2.60065412
    ##  [13,] 0.5419091 1.2350333 0.2552902 1.15897420 0.4420023 0.53128103
    ##  [14,] 0.4417372 0.8075828 0.4095619 0.44818152 0.3805758 0.59442314
    ##  [15,] 0.2466480 1.1934338 0.4437592 0.32150714 0.5072804 0.48782866
    ##  [16,] 0.3166620 0.9011632 0.3364251 1.67293866 0.4098109 0.42904298
    ##  [17,] 0.2702883 0.9420242 0.4247832 0.11450384 0.4604598 1.97220964
    ##  [18,] 0.2998862 0.3110659 0.3826486 0.75439413 0.2870951 0.61685353
    ##  [19,] 0.5385340 0.9617751 0.2704157 1.30637730 0.5439551 0.19983592
    ##  [20,] 0.3378090 2.2574831 0.6899142 1.60355686 0.5871177 0.01371859
    ##  [21,] 0.3960093 1.6402500 0.1320293 0.71914154 0.5931711 0.78689971
    ##  [22,] 0.2016505 1.0564093 0.2086457 0.44222198 0.2910933 0.72897590
    ##  [23,] 0.5138122 3.1790933 0.2955830 1.08688958 0.6166695 0.91279731
    ##  [24,] 0.3884418 0.6317488 0.8626143 0.16293704 0.4073700 1.46327615
    ##  [25,] 0.6912912 2.8454769 0.3741560 1.74894304 0.6273008 1.22752202
    ##  [26,] 0.6170002 0.5384913 0.8606172 0.76011291 0.2845425 2.00285544
    ##  [27,] 0.5772130 0.5019785 0.2703644 2.28718271 0.2427221 1.04513477
    ##  [28,] 0.3046968 0.7031099 0.3194046 0.85195130 0.2840740 1.92585560
    ##  [29,] 0.3224040 3.1331927 0.3067808 0.45853383 0.3753990 1.03733357
    ##  [30,] 0.7727808 0.6846790 0.2250677 1.60974723 0.4346713 0.24899041
    ##  [31,] 0.1953591 2.8251616 0.4747791 1.00150552 0.5899082 3.01494073
    ##  [32,] 0.3737702 0.6111153 0.3467999 0.18121973 0.4726427 0.79602461
    ##  [33,] 0.1710798 0.8837487 0.5740399 1.47730118 0.3527292 0.58769173
    ##  [34,] 0.4976267 1.0803381 0.5027420 0.23864917 0.3632103 0.34619636
    ##  [35,] 0.4524086 1.5869604 0.4892400 0.08455416 0.6754847 1.19841183
    ##  [36,] 0.4819774 1.3724905 0.3074935 1.76988726 0.3001444 0.79495560
    ##  [37,] 0.6074621 1.9450358 0.4271862 0.66063753 0.2887594 1.11308729
    ##  [38,] 0.4492860 2.2130928 0.2642824 1.40268940 0.4256713 1.54627474
    ##  [39,] 0.9442009 0.2645958 0.2585814 0.85866212 0.2023232 0.54279713
    ##  [40,] 0.5688799 0.8553439 0.2085256 0.19184725 0.2781470 1.50588252
    ##  [41,] 0.6254379 0.3694697 0.4442986 0.87522035 0.1905061 0.45858415
    ##  [42,] 0.2612800 0.1432260 0.9974183 0.36450278 0.1915323 0.26700125
    ##  [43,] 0.3780337 0.7655930 0.7530937 0.43354214 0.6213862 0.32604698
    ##  [44,] 0.5608752 1.9919064 0.6376062 1.51879338 0.4884199 0.71847748
    ##  [45,] 0.3572406 0.4142949 0.8030191 0.32251000 0.4703827 0.79416128
    ##  [46,] 0.1428563 0.3304053 0.3973085 1.00692294 0.7346010 1.61835937
    ##  [47,] 0.2830114 0.7801307 0.2007823 0.12577729 0.3474652 1.32495360
    ##  [48,] 0.4701722 0.9011333 0.5425795 0.17925871 0.5139380 1.26011156
    ##  [49,] 0.7293794 0.8761318 0.4536133 1.21307148 0.8115896 0.87929624
    ##  [50,] 0.2549036 0.7268310 0.4064374 1.73824856 0.5319327 0.19801538
    ##  [51,] 0.3552312 1.2542891 0.5231084 0.13980460 0.2616602 2.27963057
    ##  [52,] 0.9066772 2.2011334 0.3486260 0.24825823 0.3436395 0.36466241
    ##  [53,] 0.3847486 2.3183051 0.4122117 0.83503818 0.3447585 0.54880582
    ##  [54,] 0.2751009 1.2111374 0.4962364 0.41893226 0.3086327 0.42007437
    ##  [55,] 0.6727320 0.8583860 0.4779383 0.55205371 0.8025349 0.56277955
    ##  [56,] 0.4007786 0.5490223 0.5817721 1.36812049 0.4762655 0.86853870
    ##  [57,] 0.5508569 0.6597760 0.8440533 1.07673783 0.4497937 0.35548965
    ##  [58,] 0.2278557 0.4795309 0.1924388 0.91742813 0.2965153 0.92819344
    ##  [59,] 0.7072283 0.7161152 0.1147163 0.17171428 0.3333010 1.81385903
    ##  [60,] 0.5764983 0.9358176 0.3735570 0.65592615 0.3703967 1.42238050
    ##  [61,] 0.4127103 1.3908058 0.9424058 3.18945911 0.6505729 1.45038905
    ##  [62,] 0.3126362 0.3455025 0.5385286 0.39136695 0.3373635 1.42491735
    ##  [63,] 0.2715022 1.7848633 0.5883800 0.16065456 0.3139603 0.82295438
    ##  [64,] 0.4031941 1.5528095 0.3233162 0.07668662 0.6630273 0.37722120
    ##  [65,] 0.2697335 0.2567635 0.4121238 1.29122736 0.3469008 0.66264688
    ##  [66,] 0.4970384 0.2997408 0.7837423 2.35627532 0.4505553 2.52475650
    ##  [67,] 0.8101820 1.7097804 0.7189951 1.37703555 0.4926280 0.89610348
    ##  [68,] 0.4916245 0.3876210 0.5858738 0.74989938 0.4625792 0.83427112
    ##  [69,] 0.3778828 0.7433019 0.3257893 0.34898996 0.5768219 0.33151848
    ##  [70,] 0.3598507 0.3566418 0.4004992 1.11546292 0.5700864 0.74305052
    ##  [71,] 0.5098297 0.5446457 0.3243588 0.97591594 0.2885509 2.86533857
    ##  [72,] 0.4952482 1.2172792 0.7015610 1.06118825 0.1418394 0.70152761
    ##  [73,] 0.4332344 0.1412452 0.2889528 2.16557520 0.4249605 0.75713413
    ##  [74,] 0.7614143 1.1419938 0.5877471 0.58900424 0.4266708 0.32345336
    ##  [75,] 0.2626998 0.8766864 0.5005300 0.26779469 0.3383343 0.03766083
    ##  [76,] 0.7540503 0.3148206 0.5068277 1.89020636 0.3679778 0.35545679
    ##  [77,] 0.3720208 0.3888627 0.4341794 1.72231806 0.5379842 0.98908234
    ##  [78,] 0.4788644 1.1617218 0.2997064 0.65490699 0.4810231 2.29191058
    ##  [79,] 0.4539168 0.6403923 0.9838046 1.14702133 0.3340383 1.71596640
    ##  [80,] 0.5085216 0.9938683 0.4481209 1.74124568 0.4724655 2.12973345
    ##  [81,] 0.5019581 0.3939269 0.2785931 0.78258128 0.3679282 0.34765704
    ##  [82,] 0.4237376 2.9641124 0.4065286 2.27619380 0.3920109 0.66142357
    ##  [83,] 0.2990798 0.8082544 0.5339419 2.49243157 0.2699406 0.91440581
    ##  [84,] 0.5636600 0.8871290 0.3089284 0.77630911 0.2493585 1.75482437
    ##  [85,] 0.9124241 0.1741634 0.3479956 1.56325782 0.4071568 1.62263803
    ##  [86,] 0.6077807 0.6678184 0.4418413 0.81201446 0.4970087 1.03250192
    ##  [87,] 0.8263078 0.1401129 0.5407395 1.29888165 0.3861067 1.48036970
    ##  [88,] 0.4375568 0.5038350 0.8623632 0.84228043 0.6675379 0.13410458
    ##  [89,] 0.3561700 1.1418729 0.6290089 2.59240788 0.4042244 0.47049233
    ##  [90,] 0.2301274 1.2085503 0.3452541 1.18971025 0.4742009 0.40619398
    ##  [91,] 0.5256268 0.7102722 0.3206566 1.58789639 0.2862110 0.66506550
    ##  [92,] 0.5786709 0.5500802 0.4932428 0.48088271 0.4358033 1.65142809
    ##  [93,] 0.5131686 2.4897844 0.4224619 2.09469568 0.3445412 1.44831748
    ##  [94,] 0.6183612 0.3572106 0.2538045 0.59958311 0.4529826 0.91751565
    ##  [95,] 0.3996436 0.8809325 0.3362303 1.67765530 0.4265285 0.95215169
    ##  [96,] 0.5765427 0.8784717 0.3938684 2.06119000 0.5143087 1.25171698
    ##  [97,] 0.4817557 0.8518602 0.4370014 0.93096046 0.4920555 2.84752700
    ##  [98,] 0.4271404 1.2558626 0.7863103 1.96197936 0.2209192 1.10006465
    ##  [99,] 0.3705033 1.1879345 0.4875757 0.70561103 0.3645391 2.25714737
    ## [100,] 0.4177068 0.2431512 0.3011605 0.80586605 0.6650006 0.77589909
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
the the tree.

    path_probs <- calc.pathway_probs(osNode)
    osNode$Set(path_probs = path_probs)
    print(osNode, "type", "p", "path_probs")

    ##                                                 levelName     type    p  path_probs
    ## 1  LTBI screening cost                                      chance   NA 1.000000000
    ## 2   ¦--under 40k cob incidence                              chance 0.25 0.250000000
    ## 3   ¦   ¦--Screening                                       logical 0.25 0.062500000
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 0.015625000
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 0.006250000
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 0.006250000
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 0.003750000
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 0.003750000
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 0.002625000
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 0.002625000
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 0.000787500
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 0.000787500
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 0.000590625
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 0.000590625
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 0.015625000
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 0.006250000
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 0.006250000
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 0.003750000
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 0.003750000
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 0.002625000
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 0.002625000
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 0.000787500
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 0.000787500
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 0.000590625
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 0.000590625
    ## 26  ¦   °--No Screening                                    logical 0.25 0.062500000
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 0.025000000
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 0.037500000
    ## 29  ¦--40-150k cob incidence                                chance 0.25 0.250000000
    ## 30  ¦   ¦--Screening                                       logical 0.25 0.062500000
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 0.015625000
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 0.006250000
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 0.006250000
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 0.003750000
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 0.003750000
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 0.002625000
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 0.002625000
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 0.000787500
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 0.000787500
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 0.000590625
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 0.000590625
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 0.015625000
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 0.006250000
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 0.006250000
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 0.003750000
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 0.003750000
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 0.002625000
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 0.002625000
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 0.000787500
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 0.000787500
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 0.000590625
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 0.000590625
    ## 53  ¦   °--No Screening                                    logical 0.25 0.062500000
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 0.025000000
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 0.037500000
    ## 56  °--over 150k cob incidence                              chance 0.25 0.250000000
    ## 57      ¦--Screening                                       logical 0.25 0.062500000
    ## 58      ¦   ¦--LTBI                                         chance 0.25 0.015625000
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 0.006250000
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 0.006250000
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 0.003750000
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 0.003750000
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 0.002625000
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 0.002625000
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 0.000787500
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 0.000787500
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 0.000590625
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 0.000590625
    ## 69      ¦   °--non-LTBI                                     chance 0.25 0.015625000
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 0.006250000
    ## 71      ¦       °--GP registered                            chance 0.40 0.006250000
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 0.003750000
    ## 73      ¦           °--Agree to Screen                      chance 0.60 0.003750000
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 0.002625000
    ## 75      ¦               °--Test Positive                    chance 0.70 0.002625000
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 0.000787500
    ## 77      ¦                   °--Start Treatment              chance 0.30 0.000787500
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 0.000590625
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 0.000590625
    ## 80      °--No Screening                                    logical 0.25 0.062500000
    ## 81          ¦--LTBI                                       terminal 0.40 0.025000000
    ## 82          °--non-LTBI                                   terminal 0.60 0.037500000

Optimal decisions
-----------------

We can get the software to calculate the optimal decision for us, rather
than returning the expections to compare.

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
