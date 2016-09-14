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

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 1.36075847
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 1.47221564
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 4.32303977
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.81247623
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.26673777
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.67488627
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.32868696
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.29471568
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.25801868
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 2.35813425
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 3.01970927
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.43058276
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.54508962
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.37707122
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.04255154
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.14626515
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.39887588
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.52102108
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.01756880
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.33984028
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.34041955
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.63167257
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.44947245
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.68485907
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.58722611
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.29822321
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.64781326
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.15375546
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 2.58264170
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.41290221
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.96585456
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.92868619
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.02089701
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.34181022
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.36328543
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.46113139
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 2.05962646
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.32447957
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.55738002
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.59373962
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.01531722
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.57613828
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.03956903
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.92048832
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.26865697
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.49841353
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 3.02412532
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.62240237
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.32702464
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.39151642
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.39112990
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.07314465
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.38708485
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.46537700
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.61413463
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.79984283
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.41180041
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.62438154
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.06936742
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.35402182
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.42661836
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.27991321
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.07234708
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.58632117
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.20224066
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.22735481
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.68699309
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.52282187
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.99852851
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.97268763
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.40469673
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.02415414
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.93483217
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.69910384
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.05302856
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.32658391
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.01653900
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.04624541
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.20650236
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.99059053
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 2.76174543
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.58308750

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.28072001
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.34146612
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.61448589
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.49377814
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.26673777
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.46770759
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.32868696
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.11749236
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.25801868
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.33839897
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 3.01970927
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.44162063
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.54508962
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.37707122
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.96416540
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.14626515
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.26414836
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.52102108
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.58589285
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.33984028
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.92572094
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.63167257
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.45406388
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.68485907
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.58722611
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.75137858
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.64781326
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.15375546
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.30607946
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.66968627
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.36595512
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.92868619
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.48620161
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.34181022
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.80185914
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.46113139
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.68438166
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.32447957
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.95679263
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.59373962
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.01531722
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.31278996
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.03956903
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.24240587
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.26865697
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.46868614
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 3.02412532
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.50256917
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.32702464
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.34820592
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.39112990
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.07314465
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.55463158
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.46537700
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.61413463
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.47533447
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.44678720
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.87501362
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.06936742
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.11816662
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.42661836
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.10365935
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 2.07234708
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.93288056
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.20224066
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.90736122
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.68699309
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.52282187
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.91213518
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.97268763
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 1.30765033
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.02415414
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.15526308
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.69910384
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.37984342
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.32658391
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.93956082
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.04624541
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.20650236
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.45455067
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 2.76174543
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.58308750

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc_expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.42189555
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.43388562
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.55455250
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.24952125
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.12495403
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.99884909
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 3.80957350
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.18850832
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.82041567
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.87745336
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.68827663
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.23656791
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.34962466
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.29913256
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.96868874
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.41708214
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.00463970
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.28764088
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.38675862
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.25044055
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.73064319
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.06078608
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.37469123
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.97728255
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.18897243
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.18098997
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.15296596
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 1.19967264
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.54555958
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.42323642
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.41618138
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.16288765
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.87756579
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.15606499
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.30654466
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.26051502
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.60597735
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.39181094
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.62811355
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.38383227
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.78698580
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.27676431
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.16067116
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.03123963
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.20433123
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.51440148
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.68146834
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.48196235
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.59912858
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.00741258
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.81658164
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.52663513
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.75900189
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.35122160
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.69752208
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.70813701
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.54865066
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.48283922
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.97096917
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.73612887
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.39621862
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.49732949
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.72538418
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.41365796
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.23341733
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.14544252
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.16270662
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.36455007
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.71176344
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.23174083
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.54766776
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.31673207
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.59604752
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.17486776
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.67662871
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.19404565
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.06138338
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.27839848
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.13677936
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 2.28389738
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.70316014
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 2.67105554

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo_expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]      [,4]      [,5]       [,6]
    ##   [1,] 0.2373834 3.02380419 0.4275018 1.1298708 0.4336800 1.34301654
    ##   [2,] 0.5888465 0.60372060 0.4268774 0.4516364 0.3366315 1.50709921
    ##   [3,] 0.6507495 0.75818231 0.7208260 0.4054240 0.3481947 0.91053388
    ##   [4,] 0.7734434 1.60035367 0.4261217 1.3485388 0.4262002 0.33856365
    ##   [5,] 0.5421978 0.93427181 0.3777443 1.7164798 0.5420576 0.47674264
    ##   [6,] 0.3212036 1.06657581 0.4426994 0.5999689 0.4394283 1.04803300
    ##   [7,] 0.3808940 0.54330048 0.3409916 0.7031802 0.3934579 0.28109180
    ##   [8,] 0.4742285 2.49511139 0.5524501 0.1615924 0.3653570 0.89410922
    ##   [9,] 0.3794881 1.26974360 0.3850418 0.4484954 0.3661135 0.19882443
    ##  [10,] 0.6322724 0.59483284 0.3327860 0.8678394 0.5687306 1.44369139
    ##  [11,] 0.5293314 1.39317739 0.3175887 0.5344301 0.4425091 1.60891873
    ##  [12,] 0.3502178 2.10733493 0.2603719 0.6151895 0.5606227 0.48807553
    ##  [13,] 0.7270072 0.23498251 0.1966876 0.9495866 0.6518809 0.63110736
    ##  [14,] 0.7078983 0.11713251 0.8401708 0.5115398 0.3299718 2.34517446
    ##  [15,] 0.3704984 0.72053210 0.6162605 1.1594161 0.6744466 0.95369406
    ##  [16,] 0.4831452 0.25766480 0.3647799 0.4010678 0.3469720 0.57327869
    ##  [17,] 0.3703307 0.50128272 0.4636588 0.1706638 0.3111261 1.37853579
    ##  [18,] 0.3188559 0.61341256 0.4215649 0.6547930 0.5050805 0.59244173
    ##  [19,] 0.3847912 0.55243353 0.3510992 0.5879708 0.6047680 1.93743598
    ##  [20,] 0.4586164 0.25369519 0.5010593 0.9420281 0.4423127 1.59085531
    ##  [21,] 0.7052805 1.25030526 0.2896192 0.5127659 0.3037505 0.19620333
    ##  [22,] 0.3784931 1.60129777 0.4872511 0.1820145 0.2776936 0.30163325
    ##  [23,] 0.4396834 2.26734598 0.2549068 0.6517722 0.3508985 0.54840319
    ##  [24,] 0.5766765 1.21467816 0.4711698 0.8756422 0.6065841 0.25764317
    ##  [25,] 0.4987050 0.86365215 0.5698913 0.9371490 0.4983880 0.27512115
    ##  [26,] 0.4256296 1.92372684 0.4663534 0.4026700 0.3992077 0.38369754
    ##  [27,] 0.9058908 0.99604460 0.4190008 3.1524748 0.4427414 0.67200776
    ##  [28,] 0.2713395 0.29518650 0.2557620 0.6669853 0.4604131 0.36351807
    ##  [29,] 0.2717469 1.45924771 0.7121846 0.5436739 0.8186959 1.41089981
    ##  [30,] 0.3439518 0.56782555 0.5535826 2.4610177 0.4456984 0.80904646
    ##  [31,] 0.2288753 1.72192079 0.3138774 0.8275747 0.2637110 1.58551439
    ##  [32,] 0.4361153 0.72893715 0.2313925 0.9625492 0.5835069 0.51524203
    ##  [33,] 0.5024763 1.53804044 0.2743971 2.4330406 0.4122991 0.45803513
    ##  [34,] 0.3074166 0.21359167 0.3190976 0.6790765 0.3496804 1.19621393
    ##  [35,] 0.6969262 2.11876772 0.4041889 1.4617067 0.3654363 0.48062734
    ##  [36,] 0.1920332 0.05476291 0.5025560 1.1006532 0.4508428 0.48491355
    ##  [37,] 0.4133227 1.49417354 0.5239019 0.9562585 0.2690228 4.21198666
    ##  [38,] 0.2577172 1.05754153 0.4769979 0.6934493 0.5238650 1.87112726
    ##  [39,] 0.2033839 1.07703875 0.7980350 0.9416896 0.2894330 0.90138139
    ##  [40,] 0.7915870 0.19628420 0.4647589 0.7470120 0.3424399 0.76624113
    ##  [41,] 0.4818143 0.75674504 0.3338581 0.6508024 0.4644033 0.93937228
    ##  [42,] 0.5797326 0.38233195 0.3108469 1.2717133 0.4364363 0.46751662
    ##  [43,] 0.7006461 1.18062995 0.4918163 0.3357309 0.4463896 1.16825265
    ##  [44,] 0.7132297 0.09793575 0.4122818 1.5592301 0.6635642 1.28923253
    ##  [45,] 0.4384652 1.02630464 0.5205332 1.6651791 0.1925415 1.09383139
    ##  [46,] 0.5303780 2.47036083 0.5230652 1.7770989 0.4209342 0.20285559
    ##  [47,] 0.6719646 0.78698007 0.5537589 0.5473768 0.8143275 0.39630000
    ##  [48,] 0.3674795 2.18824349 0.4065167 1.2457002 0.4449739 0.84765430
    ##  [49,] 0.4245796 0.30627650 0.3383723 0.6570098 0.4927761 1.10590976
    ##  [50,] 0.8914706 0.78785194 0.7373651 0.1187332 0.3195715 1.45123696
    ##  [51,] 0.5075700 0.85826267 0.6268927 0.2443318 0.9262114 0.50394816
    ##  [52,] 0.4689378 1.02132983 0.2611523 0.8778252 0.6674264 0.61126383
    ##  [53,] 0.6705711 0.93792179 0.5550212 0.3651713 0.3962729 0.68870772
    ##  [54,] 0.2354918 0.90119462 0.4754378 1.7442476 0.2194996 0.46600560
    ##  [55,] 0.4962897 0.57656059 0.6373683 0.6063523 0.4760427 0.22115853
    ##  [56,] 0.3413757 0.42206568 0.6340612 0.5676277 0.5125034 0.52136413
    ##  [57,] 0.7664841 0.23311858 0.3896005 1.5772659 0.4349436 1.60528439
    ##  [58,] 0.3925008 0.33853875 0.8015863 0.4669342 0.3055436 0.28149665
    ##  [59,] 0.3712534 5.37732003 0.6309513 0.4718464 0.4195357 0.09842250
    ##  [60,] 0.3903762 1.23894047 0.8540137 0.1748702 0.4702565 1.00601339
    ##  [61,] 0.5770716 1.93228329 0.2638419 0.7706372 0.4481885 0.37682815
    ##  [62,] 0.5637568 1.52709501 0.4083075 0.5867842 0.3794634 0.46904755
    ##  [63,] 0.3951274 0.18242120 0.4664382 0.2587796 0.5862418 1.16979219
    ##  [64,] 0.6465068 2.57174650 0.3144387 0.9176804 0.4551284 1.51256778
    ##  [65,] 0.4216025 0.19266125 0.9045487 1.0455080 0.4581397 2.12050646
    ##  [66,] 0.5519922 2.57536829 0.7010492 0.4306106 0.2754946 0.94969177
    ##  [67,] 0.4354977 3.71672610 0.3765711 1.0171162 0.5315384 0.79052350
    ##  [68,] 0.3594820 2.60089326 0.4764731 2.0293096 0.6922745 0.99636641
    ##  [69,] 0.7180742 3.03119577 0.3479142 1.2977343 0.3424349 2.24323717
    ##  [70,] 0.4960439 1.34243593 0.6396795 0.6300067 0.4610830 0.72875385
    ##  [71,] 0.4631165 0.34097408 0.7850001 0.6606291 0.5277067 1.19442866
    ##  [72,] 0.4645613 0.57498749 0.2691764 0.5695814 0.6726994 0.42963089
    ##  [73,] 0.4243720 1.73858727 0.3725412 1.9782065 0.1933515 1.82596257
    ##  [74,] 0.8136722 0.41477170 0.8523980 1.1231429 0.3314984 0.78325854
    ##  [75,] 0.3082458 0.50157792 0.4578761 0.3423748 0.3702321 0.48045581
    ##  [76,] 0.4934088 1.29343476 0.5064608 0.1286417 0.4279400 0.55163622
    ##  [77,] 0.9670457 1.64024847 0.3262190 1.0001116 0.4474366 0.24636510
    ##  [78,] 0.5218064 1.96571884 0.3132514 0.5377561 0.2690519 0.59138740
    ##  [79,] 0.5627124 1.86739256 0.6885725 0.9431118 0.3292253 0.89493503
    ##  [80,] 0.6519693 0.49415305 0.5780160 0.8334769 0.3432168 1.55712590
    ##  [81,] 0.4253590 0.62124615 0.2099359 0.8336729 0.1931230 0.36706958
    ##  [82,] 0.3831772 1.01072676 0.3186417 0.9130986 0.5142420 0.22390640
    ##  [83,] 0.4123263 1.07560358 0.5068932 0.3517031 0.3820587 1.05857293
    ##  [84,] 0.4091457 0.21247742 0.5602132 0.6137617 0.5793022 0.73189968
    ##  [85,] 0.5730858 0.92401203 0.1485580 0.3120203 0.6480762 0.51833436
    ##  [86,] 0.9170382 0.35565699 0.6382814 0.3913260 0.3083373 0.58687126
    ##  [87,] 0.6545656 0.72832353 0.4523790 0.8717952 0.3600578 2.07882003
    ##  [88,] 0.8142477 0.03327172 0.7103498 0.7111655 0.3124707 1.14595410
    ##  [89,] 0.4757350 0.57495305 0.1822696 0.8314030 0.2806597 1.79915255
    ##  [90,] 0.4986807 1.68783544 0.5298338 1.8031994 0.2428800 1.46252461
    ##  [91,] 0.3850179 0.98771202 0.5397372 0.4421745 0.3097425 0.39871485
    ##  [92,] 0.4285032 0.08230054 0.2510273 0.7923520 0.5420797 0.27730844
    ##  [93,] 0.8483969 0.89520720 0.3048929 0.4201255 0.3481348 1.18569602
    ##  [94,] 0.8460314 0.03244967 0.4534241 0.7911587 0.4905034 1.94209747
    ##  [95,] 0.3936566 2.07139175 0.4752492 0.6311874 0.4974064 0.57911886
    ##  [96,] 0.5556639 0.91631762 0.6372065 0.3248574 0.3282978 0.77312557
    ##  [97,] 0.2281764 1.15350971 0.7506772 0.5272482 0.4608739 0.27282217
    ##  [98,] 0.6135287 0.03509457 0.4261077 1.2576574 0.3893748 2.67117652
    ##  [99,] 0.6464661 0.23865546 0.6345784 0.5848085 0.5648262 0.84725892
    ## [100,] 0.5950291 1.67294848 0.5442409 0.4881306 0.4939844 0.06526256
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
sum over these in an ad-hoc way:

    startstate_prob <- matrix(NA, nrow = 3, ncol = 2,
                              dimnames = list(c("<40k","40-150k",">150k"), c("LTBI","nonLTBI")))

    startstate.nonLTBI <- grepl("/Complete Treatment", x = terminal_states$pathname) | grepl("nonLTBI", x = terminal_states$pathname)
    startstate.LTBI <- !startstate.nonLTBI

    startstate_prob["<40k","nonLTBI"] <- sum(terminal_states$path_probs[grepl("under 40k cob incidence", x = terminal_states$pathname) &
                                                                      startstate.nonLTBI])

    startstate_prob["<40k","LTBI"] <- sum(terminal_states$path_probs[grepl("under 40k cob incidence", x = terminal_states$pathname) &
                                                                   startstate.LTBI])

    startstate_prob["40-150k","nonLTBI"] <- sum(terminal_states$path_probs[grepl("40-150k cob incidence", x = terminal_states$pathname) &
                                                                         startstate.nonLTBI])

    startstate_prob["40-150k","LTBI"] <- sum(terminal_states$path_probs[grepl("40-150k cob incidence", x = terminal_states$pathname) &
                                                                      startstate.LTBI])

    startstate_prob[">150k","nonLTBI"] <- sum(terminal_states$path_probs[grepl("over 150k cob incidence", x = terminal_states$pathname) &
                                                                       startstate.nonLTBI])

    startstate_prob[">150k","LTBI"] <- sum(terminal_states$path_probs[grepl("over 150k cob incidence", x = terminal_states$pathname) &
                                                                      startstate.LTBI])

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
<td align="right">0.3290389</td>
<td align="right">0.0042945</td>
</tr>
<tr class="even">
<td align="left">40-150k</td>
<td align="right">0.3290389</td>
<td align="right">0.0042945</td>
</tr>
<tr class="odd">
<td align="left">&gt;150k</td>
<td align="right">0.3290389</td>
<td align="right">0.0042945</td>
</tr>
</tbody>
</table>

    terminal_states$'healthstatus' <- "nonLTBI"
    terminal_states$'healthstatus'[startstate.LTBI] <- "LTBI"

    terminal_states$'incidence' <- NA
    terminal_states$'incidence'[grepl("under 40k cob incidence", x = terminal_states$pathname)] <- '<40'
    terminal_states$'incidence'[grepl("40-150k cob incidence", x = terminal_states$pathname)] <- '40-150k'
    terminal_states$'incidence'[grepl("over 150k cob incidence", x = terminal_states$pathname)] <- '>150k'

Further, we can sample from the terminal state probabilities to give a
sample of compartmental model start state proportions. This can capture
the variability due to the cohort size.

    SAMPLE <- sample(x = 1:nrow(terminal_states), size = 100000, prob = terminal_states$path_probs, replace = TRUE)
    knitr::kable(table(terminal_states$incidence[SAMPLE], terminal_states$healthstatus[SAMPLE])/100000)

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
<td align="left">&lt;40</td>
<td align="right">0.33030</td>
<td align="right">0.00429</td>
</tr>
<tr class="even">
<td align="left">&gt;150k</td>
<td align="right">0.32556</td>
<td align="right">0.00436</td>
</tr>
<tr class="odd">
<td align="left">40-150k</td>
<td align="right">0.33101</td>
<td align="right">0.00448</td>
</tr>
</tbody>
</table>

Risk Profile
------------

Further, the pathway probabilities can be used to give the distribution
of the terminal state values e.g. cost or time. This is called the risk
profile of the decision tree.

    osNode <- calc_riskprofile(osNode)
    print(osNode, "type", "path_prob", "path_payoff")

    ##                                                 levelName     type   path_prob path_payoff
    ## 1  LTBI screening cost                                      chance 1.000000000   0.2412248
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   0.8082191
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   1.4032482
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   3.1190696
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   6.1350281
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   4.3926647
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   5.2341127
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   5.6738752
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   7.0587431
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   6.1193080
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   6.4331979
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   7.2901940
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   7.4543964
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   8.6871729
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   2.0675432
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   2.3261429
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   3.4696809
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   4.3787245
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   4.8975335
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   5.4269898
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   6.4078667
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   7.8338717
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500  10.0163056
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625  11.9883782
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625  12.8554848
    ## 26  ¦   °--No Screening                                    logical 0.062500000   2.4811676
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   5.5920391
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   3.1955008
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.4993176
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   1.0435585
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   2.8929060
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   6.7394879
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   3.6696930
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.7682132
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.8658176
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   5.3414673
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   6.0989174
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   7.6249627
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   8.6832048
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  11.4014470
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   9.4106793
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.3711745
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.5448224
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   2.0165668
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.1203881
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   2.9883993
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   4.0359983
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   3.3291323
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   3.9096097
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   3.8844317
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   4.5554986
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   3.9537640
    ## 53  ¦   °--No Screening                                    logical 0.062500000   0.9874482
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   1.5310278
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   1.4386128
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.3810365
    ## 57      ¦--Screening                                       logical 0.062500000   0.8750209
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   1.7845317
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   3.3604394
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   2.4824012
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.2821634
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   2.8457549
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   3.2100063
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   3.0005800
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   3.0216239
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   3.4956198
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   4.1015213
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   3.5497714
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   1.9414476
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   3.1138894
    ## 71      ¦       °--GP registered                            chance 0.006250000   3.4350726
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   5.3104423
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   4.0490780
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000   4.5968790
    ## 75      ¦               °--Test Positive                    chance 0.002625000   4.3784274
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   4.4516261
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   5.4030603
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   6.3093575
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   5.8629401
    ## 80      °--No Screening                                    logical 0.062500000   0.4462991
    ## 81          ¦--LTBI                                       terminal 0.025000000   0.4685585
    ## 82          °--non-LTBI                                   terminal 0.037500000   0.5402304

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
