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

    ##                                                 levelName     type    p distn mean sd       payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.0979947400
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.4436539609
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.3064663942
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.7867335563
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.0552688242
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.0419963181
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.8093219546
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.1371638817
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.0610378248
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.6879668898
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.1019785271
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.4169702348
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.6153157004
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.1208258212
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.0237688135
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.0006705895
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.2096582939
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.7165955387
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.1144873041
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.5539044846
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.1407787373
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.0942294792
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.0041761819
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.7117697887
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.8189543940
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.6237724232
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.9676459859
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 3.0411705583
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 1.2573362729
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.1724786962
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 4.7043578239
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.8788345531
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.4601609901
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.4443866356
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.0689054423
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.2002077833
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.1045130011
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.0412280539
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.7827867582
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.5528382177
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.6331002261
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.3622843565
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.4128134741
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.1027900880
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.1780863483
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.6173265025
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.0415625056
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.0667036430
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.0931825635
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.1645647834
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.4884304208
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.3087067065
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.7477189161
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.3000146429
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.0357944505
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.4122696779
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 1.6957512689
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.8206489115
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.1467789624
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.9000039555
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.2961293531
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.1845337225
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.4965312596
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.1531228813
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.3450812397
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.7566838740
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.7929056774
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.0093544870
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.4121349115
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.6095737392
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 4.2949967269
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.2791242652
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.3245987466
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.8942226261
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.3360523230
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.1314909382
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.1577657963
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.3239711704
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 5.5280984261
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.3864662773
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.9938042446
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.8815990561

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd       payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.2848466629
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.6198828498
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.2677706697
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.7053650206
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.0552688242
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.7081437274
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.8093219546
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.0375842577
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.0610378248
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.4212254005
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.1019785271
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.3021061412
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.6153157004
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.1208258212
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.3657176583
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.0006705895
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.9136235563
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.7165955387
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.8061103886
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.5539044846
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.5976817849
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.0942294792
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.8980431370
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.7117697887
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.8189543940
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.2117607293
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.9676459859
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 3.0411705583
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.0998709248
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.2580011718
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.7067278885
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.8788345531
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.8879851681
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.4443866356
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.0355886446
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.2002077833
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.2792045660
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.0412280539
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.8894538329
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.5528382177
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.6331002261
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.3252767988
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.4128134741
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.4003785229
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.1780863483
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.4892111898
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.0415625056
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.6573106227
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.0931825635
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.0978528455
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.4884304208
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.3087067065
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.1414825275
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.3000146429
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.0357944505
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.4196328769
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.3520503761
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.7193174100
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.1467789624
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.6515145627
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.2961293531
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.4563949180
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.4965312596
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.5840329089
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.3450812397
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.6016951233
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.7929056774
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.0093544870
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.6888840945
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.6095737392
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.1126364972
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.2791242652
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.5752698968
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.8942226261
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.3561629407
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.1314909382
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 4.3890521974
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.3239711704
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 5.5280984261
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.3264811315
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.9938042446
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.8815990561

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.326812313
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.666792797
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.507325540
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.449100675
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.905996727
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.716754961
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.341077962
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.186846973
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.081588924
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.613906752
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.267068341
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.779287499
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.215341499
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.157041833
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.580201483
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.315667186
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.134836522
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.040723853
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.184003684
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.141646050
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.121216356
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.019835477
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.384219044
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.340918280
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.171373779
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.159845649
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.113997525
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 3.523744398
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.404595201
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.370322234
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.361522981
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.143043332
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.760764121
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.758117728
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.509822473
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.447493920
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.280823899
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.173760483
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.762319179
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.377027263
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.639398310
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.119765956
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.774659134
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.024755757
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.435331426
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.939261502
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.733324195
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 2.037049380
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 4.572603014
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.217561586
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.271204750
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.685544032
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.248058568
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.071191796
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.032636416
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.235861256
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.433002478
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.983992693
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.714414137
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.745567595
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.481599231
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.761013428
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.308084922
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.779077118
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.277109129
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.319814597
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.091034215
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.002051914
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.748017220
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.761051629
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.108991421
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.001933640
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.846385395
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.672883700
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.964809721
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.082495509
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.133536895
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.956728252
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.554654275
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.510442546
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.136338566
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.093178532

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]      [,5]      [,6]
    ##   [1,] 0.1902698 0.54539791 0.8076147 0.62978149 0.4964413 0.4932601
    ##   [2,] 0.5508861 0.09904720 0.5144401 0.54943736 0.4947563 2.2911250
    ##   [3,] 0.1774935 0.74562499 0.6560828 0.06296515 0.5897778 0.5101792
    ##   [4,] 0.3881870 0.54612607 0.6166286 0.98942396 0.7098401 0.4906473
    ##   [5,] 0.3437598 0.45747211 0.3314508 0.25840076 0.6397482 0.5210466
    ##   [6,] 0.4467104 0.07992455 0.4710781 0.72252944 0.7418495 1.5680122
    ##   [7,] 0.6414347 0.98454555 0.2444861 0.37014314 0.3063493 0.3331201
    ##   [8,] 0.1670518 2.26305811 0.2878043 0.84220201 0.4234078 0.9041708
    ##   [9,] 0.2917747 0.31613576 0.4256605 1.57769325 0.2668249 1.5676628
    ##  [10,] 0.3279133 0.64283417 0.5626059 0.24607588 0.6756113 0.2645204
    ##  [11,] 0.5126738 0.43537839 0.3325704 0.37508507 0.6019197 1.8373820
    ##  [12,] 0.8066033 1.81606045 0.8381735 1.74442515 0.2269274 0.5723199
    ##  [13,] 0.6225933 0.36860837 0.4312599 0.20760698 0.3893994 1.3618184
    ##  [14,] 0.3142322 0.31293788 0.3005996 0.43927081 0.5673557 0.5409560
    ##  [15,] 0.3909519 2.25225055 0.2956871 0.97329234 0.2959182 1.7559351
    ##  [16,] 0.2800618 0.70721306 0.3401513 0.18136433 0.2387106 1.7701726
    ##  [17,] 0.3152991 0.57321831 0.4364563 0.70323990 0.8872773 0.5397765
    ##  [18,] 0.3940788 0.26240370 0.4893934 0.97513107 0.4154175 0.5822760
    ##  [19,] 0.7195691 1.22751429 0.3364026 1.68318255 0.3267233 1.1758365
    ##  [20,] 0.4170334 0.48901247 0.9988983 1.09606998 0.4604509 1.2567627
    ##  [21,] 0.3949241 1.32169150 0.5152608 2.53725913 0.7812906 2.1045924
    ##  [22,] 0.3651577 1.59240694 0.6002177 1.03095914 0.4140065 0.7645965
    ##  [23,] 0.5712695 0.55408817 0.6772324 1.61888103 0.6943194 0.1894765
    ##  [24,] 0.2361076 0.95524344 0.2743247 1.14280933 0.7042738 1.3976630
    ##  [25,] 0.4541880 0.18718877 0.4671006 0.33268806 0.5288546 0.4926868
    ##  [26,] 0.2507033 1.01781758 0.4389493 0.45332054 0.3534887 0.5250581
    ##  [27,] 0.5759180 2.23811923 0.5151370 0.04014775 0.4422571 0.4754126
    ##  [28,] 0.3493301 1.94017637 0.3386742 0.47032205 0.4593543 0.4364634
    ##  [29,] 0.5221441 0.32009659 0.5191204 0.52538096 0.4321526 0.9333201
    ##  [30,] 0.5518543 0.23000886 0.2926587 1.43085743 0.9565557 0.4545718
    ##  [31,] 0.3249091 0.14092900 0.4359330 1.80357774 0.3345042 1.1740807
    ##  [32,] 0.7123451 0.44755764 0.3319045 0.88022121 0.5708299 1.3830443
    ##  [33,] 0.3975712 0.98477696 0.3423463 1.23681214 0.4532236 0.4591795
    ##  [34,] 0.3581841 2.45857075 0.5915367 1.02435886 0.4109266 0.6849419
    ##  [35,] 0.5243083 0.60050932 0.3208739 0.13406093 0.5118773 1.2558707
    ##  [36,] 0.6203170 0.43686582 0.2281797 0.88704743 0.5211199 0.5288887
    ##  [37,] 0.2138720 0.92095121 0.4463590 0.50855604 0.4595117 0.9294224
    ##  [38,] 0.3136167 0.67861729 0.6803235 0.85726772 0.3174837 0.3613618
    ##  [39,] 0.5224662 0.14035695 0.5045701 1.02758484 0.3548080 1.2967309
    ##  [40,] 0.3984287 0.69172579 0.5535538 0.52412278 0.3334340 1.3618444
    ##  [41,] 0.3877176 1.38557926 0.9280977 1.88873516 0.4503381 2.1029769
    ##  [42,] 0.4893289 1.11770081 0.3838990 0.90563551 0.6413828 1.5425252
    ##  [43,] 0.4107314 0.82350709 0.2163326 0.87246541 0.5081268 2.4749562
    ##  [44,] 0.2972060 0.27750291 0.5271464 3.07144621 0.9006787 0.3367350
    ##  [45,] 0.2568590 2.60042850 0.4303080 0.44025711 0.8368128 0.4850252
    ##  [46,] 0.3624226 0.40430602 0.4411867 0.46864426 0.2153417 1.9386368
    ##  [47,] 0.3701838 1.38747562 0.3259748 0.51728698 0.4016644 0.7956342
    ##  [48,] 0.3128722 4.39250483 0.2909371 0.10878833 0.3574770 0.8944392
    ##  [49,] 0.3485571 0.55802804 0.3618029 0.81887838 0.2212708 2.2350197
    ##  [50,] 0.4154938 3.13308955 0.4638515 1.76133824 0.4484948 0.6690995
    ##  [51,] 0.5538236 0.64520060 0.3375824 0.45381270 0.3016881 1.2186867
    ##  [52,] 0.4148202 0.22742663 0.4250878 1.58726029 0.3547565 1.2902488
    ##  [53,] 0.5892970 0.87206948 0.8069200 0.93170012 0.5627229 0.9780117
    ##  [54,] 0.2248249 1.74047292 0.3745021 1.34903158 0.6589209 1.0443594
    ##  [55,] 0.4562528 1.06649938 0.2464614 0.96082399 0.4689143 2.6688483
    ##  [56,] 0.7908065 1.09597063 0.5947990 0.30543068 0.2392015 0.9144655
    ##  [57,] 0.3373541 0.68183776 0.3939420 0.69725143 0.3551840 0.8302775
    ##  [58,] 0.4663872 0.94622469 0.8504172 0.60148951 0.4326617 1.6224104
    ##  [59,] 0.2949443 0.45948081 0.3176022 0.83260237 1.0012524 2.4263755
    ##  [60,] 0.2391506 1.97193564 0.3983118 0.07637824 0.3111623 0.9624643
    ##  [61,] 0.5183299 2.20790729 0.6699245 3.26262578 0.5509173 0.5683302
    ##  [62,] 0.1734250 0.41698779 0.5378356 1.21331508 0.5073829 2.5401656
    ##  [63,] 0.3322158 0.53158470 0.5694929 1.62539790 0.4693023 0.2797995
    ##  [64,] 0.4424614 1.57419488 0.5385578 0.12304075 0.4351016 0.1760536
    ##  [65,] 0.3735259 0.51132313 0.3764670 2.59701375 0.4524603 0.5951844
    ##  [66,] 0.3870656 0.40906913 0.8981403 2.26462719 0.4803198 1.0329249
    ##  [67,] 0.4168754 1.02125986 0.7682009 0.42957978 0.3036644 0.7903846
    ##  [68,] 0.5035225 1.75676378 0.4568751 0.59308458 0.3556960 0.2222163
    ##  [69,] 0.5475273 0.10851096 0.2748819 0.50726415 0.4172293 0.7989618
    ##  [70,] 0.4038044 0.46790281 0.6067404 1.23516163 0.7818566 0.9833420
    ##  [71,] 0.7258166 1.45859583 0.4196678 0.76548607 0.4381016 1.2495265
    ##  [72,] 0.4499520 2.01477730 0.2612398 1.04893867 0.6611592 1.1218486
    ##  [73,] 0.4477794 0.52415853 0.4990741 0.36570214 0.2799951 1.1032674
    ##  [74,] 0.3396232 1.91837663 0.2562588 1.21894356 0.2939558 2.7101363
    ##  [75,] 0.4222404 0.38922798 0.3761490 0.44397326 0.4755107 0.5467055
    ##  [76,] 0.2404686 2.50295373 0.8161128 1.78086268 0.5932274 0.2802221
    ##  [77,] 0.4846827 0.41537126 0.8130623 2.07670318 0.2862006 1.4917666
    ##  [78,] 0.6176542 0.88842025 0.3537817 0.57030574 0.7831638 0.4981882
    ##  [79,] 0.3757508 1.57752156 0.6870052 0.48247821 0.4220777 0.6550629
    ##  [80,] 0.4501460 1.05381023 0.5316479 0.38763944 0.3888945 1.4845176
    ##  [81,] 0.4439987 0.31394715 0.2615185 0.52019675 0.4331192 0.2276230
    ##  [82,] 0.5676741 0.74228900 0.5019955 0.51041430 0.2553109 0.6179016
    ##  [83,] 0.1669860 1.22555657 0.2931179 0.62031853 0.3637290 0.2614345
    ##  [84,] 0.6020488 1.60682085 0.2911979 0.61844613 0.3700486 1.2886522
    ##  [85,] 0.4935549 0.51689035 0.5507867 1.66764885 0.3786623 1.0525706
    ##  [86,] 0.3001556 2.02995129 0.5651470 1.20797944 0.4502105 0.6460695
    ##  [87,] 0.3828366 2.77220404 0.4367724 1.44089925 0.3132067 2.0264635
    ##  [88,] 0.3009140 1.72090504 0.3960961 1.14310773 0.2814535 0.4483164
    ##  [89,] 0.4984206 1.07274697 0.5620309 1.88223351 0.6160621 1.1610588
    ##  [90,] 0.2829532 1.38961181 0.8595586 0.06598049 0.3632142 0.9726529
    ##  [91,] 0.7339649 0.46290417 0.4010345 1.26600848 0.3178758 0.5429261
    ##  [92,] 0.4034418 0.36469383 0.4346715 1.41365437 0.5055009 1.5057565
    ##  [93,] 0.6477426 1.78101135 0.6618689 0.16465884 0.6109854 2.4578997
    ##  [94,] 0.2866405 2.01609867 0.2727030 0.44271231 0.2057254 0.6786159
    ##  [95,] 0.6000083 0.63849910 0.1611786 1.14662486 0.6538005 2.2627382
    ##  [96,] 0.2809386 0.65182387 0.5431800 2.94745482 0.2601694 1.8680157
    ##  [97,] 0.4293711 0.73529833 0.5980903 2.33433014 0.3956705 2.5610198
    ##  [98,] 0.3412736 0.45669237 0.5814788 1.55194490 0.6005230 0.2319517
    ##  [99,] 0.3417176 0.39773474 0.3961953 2.49943824 0.3570702 2.2392838
    ## [100,] 0.3469376 0.19347078 0.2214318 0.86666621 0.7235547 0.3652803
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
