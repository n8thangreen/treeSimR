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
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 1.438212275
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 1.247919769
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.489413881
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.682068660
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.481956161
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.229342807
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.073133203
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.253634544
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.739111675
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.121040005
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.656127736
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.383402173
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.742012329
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.076886652
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.076978708
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.089023283
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.915698334
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.626775819
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.260810472
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.823952843
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.142864275
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.333369548
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.202043514
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.708568953
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.518901716
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.062203765
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.623775134
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.489811169
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 1.215079910
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 1.170650576
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.545258520
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.281507226
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.040036931
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.221423193
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.626930615
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 3.232428238
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.785906216
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.223168559
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.627207398
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.789903547
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.519820666
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.630945231
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.611710137
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.884715160
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.216913683
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.146791422
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.005642871
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.677347988
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.832450001
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.347308527
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.072809972
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.609807134
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.482902901
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.208393630
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.305765331
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.776613379
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 1.478410822
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.278006804
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.474299957
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.059255237
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.258565194
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.265026634
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.501935598
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 3.438728793
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.235301345
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.513001621
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.664521332
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.674642627
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.744085472
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.153520720
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.031108889
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.475150377
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.278349923
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.356614601
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.710144000
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.706755326
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.399483365
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.521928872
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.164539372
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.268892533
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.690568103
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.996761233

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.242966878
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.368848452
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.331997054
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.772328414
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.481956161
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.448864874
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.073133203
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.341641587
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.739111675
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.606090592
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.656127736
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.364174236
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.742012329
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.076886652
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.555659804
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.089023283
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.300126227
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.626775819
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.540101225
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.823952843
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.376191765
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.333369548
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.920603002
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.708568953
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.518901716
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.143396755
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.623775134
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.489811169
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.306816501
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.560449355
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.325147671
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.281507226
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 3.031361952
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 2.221423193
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.830846727
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 3.232428238
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.811638516
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.223168559
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.482293159
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.789903547
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.519820666
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.916649748
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.611710137
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.679914232
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.216913683
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.916276704
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.005642871
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.303323849
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.832450001
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.511962829
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.072809972
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.609807134
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.666816651
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.208393630
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.305765331
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.296202557
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.310526249
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.486780395
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.474299957
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.742651031
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.258565194
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.979186524
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.501935598
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.896902294
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.235301345
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.754372969
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.664521332
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.674642627
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.755324599
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.153520720
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.734790779
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.475150377
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.416167588
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.356614601
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.666481953
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.706755326
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.514851183
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.521928872
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.164539372
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.874283981
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 0.690568103
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.996761233

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc.expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.37721049
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.42925142
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.25483131
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.26069666
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.28565940
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.36608224
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.15075363
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.45938344
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.28831929
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.36794278
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.38094924
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.84552668
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.72364142
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.40372749
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.75862856
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.64861189
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.24795952
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.11260505
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.96732749
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.83708426
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.97338358
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.29086941
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.95374252
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.46743947
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.80421722
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.46217439
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.15434135
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.66739641
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.40342283
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.31551157
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.51590137
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.23266292
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.05709051
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.12271496
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.63910256
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.25560547
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.65739820
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.43429408
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.75703325
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.67248323
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.67022776
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.74614490
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.36980597
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.49555628
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.82593455
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.66665924
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.63602653
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.31634382
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.21468592
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.83979349
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.52916366
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.59056099
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.29817974
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.53420392
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.80749694
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.67616770
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.39504713
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.71820013
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.96470853
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.83079179
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.11136211
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.27329088
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.99276748
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.82621948
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.27189001
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.48217494
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 3.04912947
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.26043711
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.86198841
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.76723034
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.38774068
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.48122052
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.83168060
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.76272367
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.42539148
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.02172132
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.39625027
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.91719619
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.94447083
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 2.30962365
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 2.87070861
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.93556700

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo.expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]      [,5]      [,6]
    ##   [1,] 0.6525697 0.38242945 0.4325969 0.75211974 0.2878153 0.3667157
    ##   [2,] 0.4908816 0.47727081 0.2818920 1.79296537 0.4899303 0.8030240
    ##   [3,] 0.4828136 0.96630181 0.5511549 0.56120520 0.3606188 0.6718566
    ##   [4,] 0.4443935 0.03345866 0.8044013 0.18781541 0.4412486 2.3025326
    ##   [5,] 0.6325982 0.82439359 0.5917539 0.95547918 0.4442551 2.1496552
    ##   [6,] 0.3328564 1.08147253 0.5619533 1.28721464 0.3929387 0.5256920
    ##   [7,] 0.3814345 0.41222923 0.3094905 1.02935617 0.6364011 1.4952978
    ##   [8,] 0.2097475 1.38771563 0.1887902 0.91683171 0.2996616 0.9634025
    ##   [9,] 0.4158534 0.40027527 0.2207790 1.13027129 0.3182382 0.5718682
    ##  [10,] 0.5784703 2.29669114 0.2487891 3.20993064 0.4086328 0.7577397
    ##  [11,] 0.4437004 1.21162005 0.2997410 0.73668984 0.5362256 0.6591989
    ##  [12,] 0.3162437 0.96724881 0.2837401 0.56780505 0.5618908 0.4392871
    ##  [13,] 0.5409811 1.23488190 0.2347970 1.46890145 0.3990814 0.8375598
    ##  [14,] 0.5555895 2.12667042 0.5236972 1.44595226 0.2311449 0.2268494
    ##  [15,] 0.6106736 1.45124410 0.6319184 0.01095086 0.2650240 1.2123428
    ##  [16,] 0.3467403 0.45621512 0.6393560 0.58443466 0.6089123 1.7111286
    ##  [17,] 0.3473107 1.85837666 0.3734991 1.21165982 0.4001442 0.8027384
    ##  [18,] 0.1508115 0.87205077 0.5586747 0.55339048 0.5992109 0.9723730
    ##  [19,] 0.8278383 1.19488940 0.5444570 1.18734892 0.2531189 0.5826897
    ##  [20,] 0.2721503 1.69725125 0.8039005 0.59426105 0.4242638 0.6445375
    ##  [21,] 0.2998982 0.51251328 0.4827159 0.56696111 0.5677856 0.9152619
    ##  [22,] 0.9179438 0.53677651 0.5809427 1.36784346 0.4366354 0.6430519
    ##  [23,] 0.5112185 0.58552605 0.2816385 2.37932217 0.4205316 0.3110026
    ##  [24,] 0.4712182 0.41613896 0.6881502 0.89360676 0.4323267 0.2377089
    ##  [25,] 0.3143520 0.50798624 0.3980891 0.59872631 0.3840562 0.6557489
    ##  [26,] 0.5284236 0.30474708 0.2518777 1.36415656 0.6004138 0.3927847
    ##  [27,] 0.2582256 1.78652470 0.7040387 0.19168443 0.4884666 1.3620048
    ##  [28,] 0.2852369 2.13943856 0.6028250 0.30836600 0.5867556 0.5997754
    ##  [29,] 0.3657103 1.08070258 0.2744823 1.40885156 0.4921550 1.2775237
    ##  [30,] 0.5651602 0.87958068 0.2465847 3.05378568 0.4665816 0.9116252
    ##  [31,] 0.5180318 0.95877739 0.4477102 1.57300268 0.3744657 0.8692228
    ##  [32,] 0.3023539 0.63486192 0.3299984 0.79684056 0.6298587 0.6092031
    ##  [33,] 0.4640585 0.19729591 0.5751184 1.57594864 0.5589642 0.5952908
    ##  [34,] 0.3430256 0.92262297 0.3412622 1.00878149 0.5619034 0.2458516
    ##  [35,] 0.2093243 0.95534386 0.2784750 0.37106150 0.9012874 0.5832636
    ##  [36,] 0.2558048 1.71009941 0.4458545 1.74172171 0.4336871 2.9467617
    ##  [37,] 0.3477694 0.95990774 0.3002508 0.49092358 0.2528072 0.7448156
    ##  [38,] 0.6528087 0.47480971 0.2994397 0.80257174 0.2434422 0.2967551
    ##  [39,] 0.5215448 1.47499048 0.8150708 1.59024145 0.4906705 0.7991901
    ##  [40,] 0.3778689 0.07420711 0.5061456 1.00976821 0.2034682 0.5666263
    ##  [41,] 0.6125544 0.29543745 0.7596774 1.73536377 0.5903057 0.6712282
    ##  [42,] 0.4651901 1.17684865 0.3543185 2.08596578 0.5304797 1.5932283
    ##  [43,] 0.5363406 1.89672424 0.4333276 0.42274474 0.2616173 0.1405603
    ##  [44,] 0.3189014 0.85855053 0.4000145 0.48954426 0.7143958 0.5843227
    ##  [45,] 0.1938620 1.52351387 0.3885232 2.61404875 0.3039077 0.8636615
    ##  [46,] 0.6008169 0.97282809 0.8505000 1.11479445 0.3333773 1.0142301
    ##  [47,] 0.2865286 0.80192622 0.4556391 0.62197868 0.2150015 0.6869823
    ##  [48,] 0.4108942 0.73104582 0.4485808 0.67209617 0.3527102 3.9738966
    ##  [49,] 0.8303524 4.50646917 0.1972620 1.44694140 0.2898040 0.6350808
    ##  [50,] 0.6649242 0.47115070 0.2597948 0.62744231 0.4391161 0.3737729
    ##  [51,] 0.3117955 1.53486527 0.4604857 0.85499425 0.9218014 0.5618079
    ##  [52,] 0.3310074 0.41259201 0.5380660 1.14856405 0.3457679 0.9343701
    ##  [53,] 0.3438801 1.08665476 0.4124418 2.24783787 0.3093640 0.1645513
    ##  [54,] 0.3732511 0.98028028 0.3494821 0.94231809 0.4139885 1.5667858
    ##  [55,] 0.2528647 0.09504634 0.3782943 0.23122778 0.6146687 0.2057746
    ##  [56,] 0.7224444 1.13074581 0.2665315 1.40866098 0.7576389 0.5254727
    ##  [57,] 0.4973374 1.43045090 0.4473000 0.12101040 0.4908533 1.7381837
    ##  [58,] 0.2817981 0.83850441 0.5400017 1.12365250 0.9586424 2.0526704
    ##  [59,] 0.6423219 0.39963353 0.5025478 1.74259259 0.7660998 2.2476030
    ##  [60,] 0.5293830 0.27435931 0.3676617 1.05600718 0.4154280 0.8239671
    ##  [61,] 0.5170350 0.98886808 0.8273540 0.45457716 0.6015835 0.9376331
    ##  [62,] 0.5903876 0.39098993 0.5249282 1.75653505 0.5689248 1.7451231
    ##  [63,] 0.3029004 1.18015189 0.3282014 0.09260131 0.4656082 3.1848361
    ##  [64,] 0.3288478 1.11575885 0.2767638 0.50611277 0.2842136 1.6484978
    ##  [65,] 0.7352288 2.34364644 0.1606899 1.12398809 0.4144578 0.7861546
    ##  [66,] 0.4203043 0.66272799 0.4485402 0.27578536 0.7543560 1.7736189
    ##  [67,] 0.2616391 1.01661963 0.3246163 0.87993925 0.6019593 0.5529853
    ##  [68,] 0.4476640 0.74296583 0.7713632 0.56031987 0.5188095 0.3728364
    ##  [69,] 0.5636409 0.28149235 0.3481340 0.96302368 0.3676437 2.2730910
    ##  [70,] 0.4787562 0.63181792 0.9527959 0.40463644 0.3802531 1.6492056
    ##  [71,] 0.4603001 0.41151958 0.5539747 0.26106232 0.2923730 1.3277372
    ##  [72,] 0.6139865 3.98673842 0.4300813 0.17342386 0.6871384 0.5476798
    ##  [73,] 0.7804861 0.67067748 0.5466858 0.87299911 0.2422993 1.9684895
    ##  [74,] 0.5001613 0.24196897 0.2697273 0.83067401 0.5851269 0.7079920
    ##  [75,] 0.5969461 1.80473740 0.3750929 0.20073168 0.3921014 2.4380543
    ##  [76,] 0.5927666 0.18682787 0.3686401 1.23185732 0.2556563 0.6950983
    ##  [77,] 0.3282245 0.47807675 0.4764842 1.80658456 0.6027039 4.2174937
    ##  [78,] 0.5470152 3.47658449 0.2673918 0.32697534 0.6222199 1.1147683
    ##  [79,] 0.5041295 2.15187220 0.4414914 0.66931616 0.4124545 1.5532928
    ##  [80,] 0.3482267 0.48535807 0.2961933 0.25001252 0.4162144 1.8851909
    ##  [81,] 0.6948618 0.43021468 0.4850350 0.48904315 0.2474393 0.5295208
    ##  [82,] 0.5628867 0.31693117 0.5040598 0.54385853 0.4477901 0.2089490
    ##  [83,] 0.4933243 1.22216733 0.5158885 0.14610303 0.7231181 0.1524620
    ##  [84,] 0.3919220 2.66475722 0.4274485 2.82104497 0.5706044 0.5203545
    ##  [85,] 0.5677956 0.10261909 0.3618632 0.62353817 0.5022898 1.2148582
    ##  [86,] 0.5174656 0.68382861 0.4433304 0.50164400 0.3952285 1.7995725
    ##  [87,] 0.6514707 0.22060337 0.7558115 1.10404184 0.3543430 0.1777215
    ##  [88,] 0.4238805 0.93481953 0.5137063 1.40464708 0.4108845 1.1668078
    ##  [89,] 0.4161815 0.07495260 0.1766041 1.75969300 0.1797270 0.9774002
    ##  [90,] 0.2214637 0.92084287 0.7593786 0.38022410 0.3560091 2.0336677
    ##  [91,] 0.3001250 2.29879417 0.4698295 1.57523973 0.3885128 0.9024901
    ##  [92,] 0.3943428 1.59649025 0.4145992 1.07761544 0.4426566 1.3037311
    ##  [93,] 0.5409515 0.48090377 0.2118147 0.86733865 0.5094280 0.8470721
    ##  [94,] 0.1915219 0.09376651 0.5290424 0.97645306 0.8257523 0.5179631
    ##  [95,] 0.5414657 2.54933663 0.3529240 0.47301884 0.2187522 2.0044344
    ##  [96,] 0.4959751 1.22323359 0.4334801 0.40584219 0.2851052 1.0610862
    ##  [97,] 0.4303070 2.66208279 0.4553667 0.91166656 0.2885600 0.1679200
    ##  [98,] 0.5330906 0.90536355 0.3353224 0.81748844 0.4103651 0.4493375
    ##  [99,] 0.4202827 0.91559030 0.5202458 2.02660346 0.7968471 0.6365321
    ## [100,] 0.8448930 1.32946618 0.2327913 0.52237572 0.7546476 0.6305920
    ## 
    ## $`node names`
    ## [1] "LTBI screening cost/under 40k cob incidence/Screening"    "LTBI screening cost/under 40k cob incidence/No Screening" "LTBI screening cost/40-150k cob incidence/Screening"      "LTBI screening cost/40-150k cob incidence/No Screening"   "LTBI screening cost/over 150k cob incidence/Screening"    "LTBI screening cost/over 150k cob incidence/No Screening"

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
