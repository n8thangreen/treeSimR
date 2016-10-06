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

    path_dtree <- system.file("raw data/LTBI_dtree-cost-distns.yaml", package = "treeSimR")
    osList <- yaml.load_file(path_dtree)

The raw decision tree file is a tab-spaced file such as the following:


        name: LTBI screening cost
        distn: gamma
        mean: 1
        sd: 1
        type: chance
        under 40k cob incidence:
          distn: gamma
          mean: 1
          sd: 1
          p: 0.25
          type: chance
          Screening:
            distn: gamma
            mean: 1
            sd: 1
            p: 0.25
            type: logical
            LTBI:
              p: 0.25
              distn: gamma
              mean: 1
              sd: 1
              type: chance
              Not GP registered:
                p: 0.4
                distn: gamma
                mean: 1
                sd: 1
                type: terminal
              GP registered:
                p: 0.4
                distn: gamma
                mean: 1
                sd: 1
                type: chance
                Not Agree to Screen:
                  p: 0.6
                  distn: gamma
                  mean: 1
                  sd: 1
                  type: terminal
                Agree to Screen:
                  p: 0.6
                  distn: gamma
                  mean: 1
                  sd: 1
                  type: chance
                  Test Negative:
                    p: 0.7
                    distn: gamma
                    mean: 1
                    sd: 1
                    type: terminal
                  Test Positive:
                    p: 0.7
                    distn: gamma
                    mean: 1
                    sd: 1
                    type: chance
                    Not Start Treatment:
                      p: 0.3
                      distn: gamma
                      mean: 1
                      sd: 1
                      type: terminal
                    Start Treatment:
                      p: 0.3
                      distn: gamma
                      mean: 1
                      sd: 1
                      type: chance
                      Complete Treatment:
                        p: 0.75
                        distn: gamma
                        mean: 1
                        sd: 1
                        type: terminal
                      Not Complete Treatment:
                        p: 0.75
                        distn: gamma
                        mean: 1
                        sd: 1
                        type: terminal
            non-LTBI:
              p: 0.25
              distn: gamma
              mean: 1
              sd: 1
              type: chance
              Not GP registered:
                p: 0.4
                distn: gamma
                mean: 1
                sd: 1
                type: terminal
              GP registered:
                p: 0.4
                distn: gamma
                mean: 1
                sd: 1
                type: chance
                Not Agree to Screen:
                  p: 0.6
                  distn: gamma
                  mean: 1
                  sd: 1
                  type: terminal
                Agree to Screen:
                  p: 0.6
                  distn: gamma
                  mean: 1
                  sd: 1
                  type: chance
                  Test Negative:
                    p: 0.7
                    distn: gamma
                    mean: 1
                    sd: 1
                    type: terminal
                  Test Positive:
                    p: 0.7
                    distn: gamma
                    mean: 1
                    sd: 1
                    type: chance
                    Not Start Treatment:
                      p: 0.3
                      distn: gamma
                      mean: 1
                      sd: 1
                      type: terminal
                    Start Treatment:
                      p: 0.3
                      distn: gamma
                      mean: 1
                      sd: 1
                      type: chance
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
            type: logical
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
        40-150k cob incidence:
          p: 0.25
          distn: gamma
          mean: 1
          sd: 1
          type: chance
          Screening:
            p: 0.25
            distn: gamma
            mean: 1
            sd: 1
            type: logical
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
                  distn: gamma
                  mean: 1
                  sd: 1
                  type: terminal
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
          No Screening:
            p: 0.25
            distn: gamma
            mean: 1
            sd: 1
            type: logical
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
        over 150k cob incidence:
          p: 0.25
          distn: gamma
          mean: 1
          sd: 1
          type: chance
          Screening:
            distn: gamma
            mean: 1
            sd: 1
            type: logical
            p: 0.25
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
          No Screening:
            p: 0.25
            distn: gamma
            mean: 1
            sd: 1
            type: logical
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
        

We save this to a .yaml text file and then give it as a yaml file to a
data.tree object using the yaml and data.tree packages. This is then
represented as a list in R.

    # osList <- yaml.load(yaml)
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
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.714256799
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.033112991
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.220110154
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.115983861
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.621630728
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.116947913
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.064853434
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.267372424
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.660302619
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.777502310
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.524951737
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.083119842
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.360630122
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 2.449446148
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.670484565
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.018358054
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.929563884
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.190643236
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.100769991
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.757259113
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.098511532
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.417848202
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.005016758
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.553580787
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.355722886
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.679824441
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.066762712
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.754432462
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.989942307
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.280991191
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.197020176
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.305553980
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.017170130
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.715421050
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.564984934
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.245202104
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 4.103101472
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.570477014
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 5.582097063
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.122785917
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.987441941
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.451276858
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.194458250
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.210840433
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.162830955
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.064970868
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.372942922
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.280941534
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.605135660
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 5.578408160
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 5.980042184
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.781770260
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.091852895
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.019144921
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.013889409
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.870763370
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.361550434
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.357961265
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.955605814
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.060686483
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.116477662
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.318551050
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.349242685
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.416705764
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.855734782
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.884156699
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.455074131
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.372756916
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.337123141
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.278974133
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.813555523
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.607431699
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.000527254
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.173563615
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.367387196
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.204922984
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.034829404
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.035195265
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.074190285
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.473604113
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.248790643
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.352515405

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.31997242
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.40940206
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.35824369
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.54562641
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.62163073
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.74243529
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.06485343
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.17253871
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.66030262
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.01475268
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.52495174
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.85755720
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.36063012
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 2.44944615
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.88734836
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.01835805
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 2.20001284
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.19064324
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.47604483
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 2.75725911
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.77994779
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.41784820
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.18197776
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.55358079
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.35572289
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.27936456
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.06676271
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.75443246
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.60446339
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.40186193
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.57383525
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.30555398
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.12903415
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.71542105
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.16630253
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.24520210
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.42094437
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.57047701
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.83267089
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.12278592
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.98744194
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.03361249
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.19445825
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.38957297
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.16283095
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.15312399
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.37294292
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.70294850
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.60513566
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 5.07135933
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 5.98004218
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.78177026
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 2.01599161
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.01914492
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 2.01388941
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.26602423
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.35307141
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.54329078
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.95560581
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.40262114
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.11647766
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.55455757
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.34924269
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.44298242
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.85573478
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.62087328
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.45507413
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.37275692
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.86899484
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.27897413
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.89351297
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.60743170
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.88175658
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.17356362
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.08608864
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.20492298
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.08203916
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.03519527
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.07419028
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.71102550
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.24879064
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.35251540

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc_expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd     payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.27020171
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.21633145
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.25388795
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.75093075
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.26337365
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.61395323
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.43489103
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.58836436
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.48331637
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.35720414
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.06318673
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.12749375
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.48304431
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.02028068
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.26462106
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.20524263
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.45631001
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.08017265
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.68034405
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.00590477
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.96601530
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.31128234
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.90876864
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.78948501
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.75553984
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.61143783
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.40925842
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.07955744
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.19306478
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.40525936
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.69025087
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.12219617
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.60343099
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.30358884
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.70212947
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.03366928
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.96937283
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.71247804
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.51876472
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.15357377
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 3.20477919
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.93078658
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.73063107
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.59633539
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.29674768
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.69714464
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.18011789
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.81580302
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.19916165
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.52018175
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.51526153
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.51164747
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.36699975
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.76350577
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.10266240
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.67141061
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.33534199
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.93094056
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.34744903
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.97990237
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.33156144
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.30160917
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.44316211
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.41627956
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.55014088
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.83745766
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.93828312
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.17832710
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.41042741
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.42212081
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.60394772
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.05214691
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.95443262
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.68156060
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.68191457
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.01305167
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 2.25999691
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.88396841
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.12936080
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 2.35030045
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 4.08713064
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.19241365

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo_expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]       [,4]      [,5]       [,6]
    ##   [1,] 0.5595925 1.93296026 0.2158398 0.76116247 0.3355382 1.07970104
    ##   [2,] 0.2009181 1.32354849 0.4808536 2.04095497 0.6475657 1.01297582
    ##   [3,] 0.3658672 1.99971604 0.4965314 0.70812260 0.8906227 0.54276615
    ##   [4,] 0.6463198 2.09550897 0.2021997 0.82912346 0.4864312 0.11048441
    ##   [5,] 0.3995551 2.92272931 0.5144694 1.60661778 0.3719300 2.52945161
    ##   [6,] 0.8809799 1.46895028 1.1608629 0.40588271 0.4051374 1.81746299
    ##   [7,] 0.4068895 0.38262309 0.4438119 1.01840133 0.4072192 0.78136066
    ##   [8,] 0.2554747 0.02257361 0.3760076 3.31586086 0.3822564 0.90450017
    ##   [9,] 0.4347859 1.50702443 0.3181242 0.42906842 0.3684721 2.15945945
    ##  [10,] 0.3443210 1.41672892 0.6754654 0.95573041 0.8136127 0.66182518
    ##  [11,] 0.4570718 0.90233165 0.1514534 0.72931937 0.4957240 0.79760397
    ##  [12,] 0.7813437 1.16089680 0.5786574 0.52671835 0.5974223 1.45987495
    ##  [13,] 0.2891393 0.94377368 0.6653568 0.77516235 0.2200783 0.53640622
    ##  [14,] 0.2974298 0.51407134 0.4341166 0.61744846 0.4636429 2.61390623
    ##  [15,] 0.7900472 0.55745434 0.4464694 3.04865631 0.3642928 2.67366074
    ##  [16,] 0.4185329 1.44004567 0.4710605 1.02897111 0.4060514 0.87935682
    ##  [17,] 0.3067264 1.52283204 0.6306741 2.36419143 0.3239545 0.46609980
    ##  [18,] 0.4339959 0.96278885 0.2922768 1.87470920 0.3851256 1.07980557
    ##  [19,] 0.4589240 0.56251160 0.7372039 1.62548529 0.4610636 0.63260201
    ##  [20,] 0.5233238 0.21107857 0.4917535 0.65863448 0.9059837 1.45326302
    ##  [21,] 0.8407984 0.93202779 0.5928977 0.70236819 0.1701334 0.79815729
    ##  [22,] 0.6713355 0.39716453 0.4052463 0.45081231 0.6041946 0.49666681
    ##  [23,] 0.5375463 1.39150980 0.3579303 1.22460480 0.3244391 2.26220228
    ##  [24,] 0.2066696 0.42595007 0.7425001 1.38117378 0.6990932 0.07488439
    ##  [25,] 0.3119508 0.73411473 0.8576446 0.99821001 0.4858236 0.21903039
    ##  [26,] 0.8636443 2.08969160 0.5442503 0.25082541 0.4240309 0.90917807
    ##  [27,] 0.4921412 1.22282549 0.4368769 0.62004053 0.3658420 0.11053109
    ##  [28,] 1.0018597 1.12732367 0.5495367 0.60089839 0.2318588 0.45585428
    ##  [29,] 0.3801105 1.31255314 0.5310434 0.35193492 0.2721279 0.40479777
    ##  [30,] 0.5843798 1.07854248 0.2615068 1.08419362 0.3036924 0.75167105
    ##  [31,] 0.4232452 0.93922847 0.4285441 1.42456554 0.5177530 2.22267788
    ##  [32,] 0.3467481 1.96910212 0.5106671 1.33150418 0.4733986 1.34777984
    ##  [33,] 0.2846393 1.08517347 0.6615833 0.61627809 0.3202406 0.65972613
    ##  [34,] 0.5118444 0.04041807 0.6637532 0.65849896 0.5842270 1.12956356
    ##  [35,] 0.3900372 0.28316864 0.2175545 0.74383202 0.2150334 0.87243062
    ##  [36,] 0.2865463 1.00238969 0.3589918 0.62319508 0.3975529 1.52132812
    ##  [37,] 0.5979896 1.41304182 0.3421819 0.63625082 0.4696084 0.86008374
    ##  [38,] 0.4506002 1.32827128 0.4887027 1.06213506 0.3910643 0.69033400
    ##  [39,] 0.4134360 1.56428127 0.4530499 0.11645217 0.3819889 0.92065152
    ##  [40,] 0.4459350 0.27872845 0.6348170 0.23507407 0.8431098 1.79996969
    ##  [41,] 0.4095807 1.89795794 0.4502049 0.98992707 0.3383109 0.44706546
    ##  [42,] 0.5625095 0.80634009 0.3930235 0.49150425 0.4137199 0.20768499
    ##  [43,] 0.3914451 0.67448501 0.5243886 0.23233495 0.2289307 0.38834956
    ##  [44,] 0.4582689 0.66411544 0.2215363 0.88958440 0.3956789 1.39043695
    ##  [45,] 0.5009501 0.78302457 0.1142386 0.78246868 0.6201607 0.26847713
    ##  [46,] 0.3353557 0.99606977 0.6221122 0.08531382 0.2856673 2.86856254
    ##  [47,] 0.4255218 0.63521470 1.3286181 2.54696227 0.5221568 0.46202232
    ##  [48,] 0.1735224 1.62764254 0.5443062 0.95058912 0.6129148 0.45540181
    ##  [49,] 0.3897249 0.64689753 0.6402094 0.96006463 0.5936587 1.68217784
    ##  [50,] 0.2520361 0.75454140 0.3593456 0.05801278 0.2833047 1.02869459
    ##  [51,] 0.3026276 1.54656371 0.7703640 1.14546207 0.3728005 1.43438586
    ##  [52,] 0.2400810 2.39788640 0.5483195 1.33411958 0.1715592 0.44208596
    ##  [53,] 0.5969765 0.47328292 0.4948660 1.05493157 0.5806593 1.70094693
    ##  [54,] 0.1554310 0.86363036 0.4870862 0.04477669 0.8125900 0.41204453
    ##  [55,] 0.3561175 0.44934838 0.8466322 1.85911241 0.3779758 0.87193987
    ##  [56,] 0.3979780 0.57837162 0.4944603 0.77803065 0.4592778 0.64568733
    ##  [57,] 0.7019640 0.75679720 0.6578008 0.86947775 0.4506375 0.91525195
    ##  [58,] 0.5226182 0.86380097 0.8374740 0.45840830 0.1965987 1.39941465
    ##  [59,] 0.6122096 1.87659562 0.6859427 0.82637125 0.4665041 0.79170390
    ##  [60,] 0.4636093 0.11483117 0.6418328 0.61823538 0.5906410 0.78509071
    ##  [61,] 0.7232908 0.65331719 0.6467562 0.27693290 0.2812273 0.78702993
    ##  [62,] 0.4004301 0.22181053 0.3846897 1.08501385 0.4059925 0.68932044
    ##  [63,] 0.4609300 0.94790095 0.3591640 0.36400956 0.3131456 0.35429385
    ##  [64,] 0.2130378 0.76460590 0.3218429 1.11881765 0.3043378 1.44982461
    ##  [65,] 0.6749569 0.09521298 0.3667197 0.42175608 0.6036675 0.97729616
    ##  [66,] 0.4190284 0.03606395 0.5023756 0.60965095 0.5124378 1.48761909
    ##  [67,] 0.5243991 0.62364501 0.4975633 0.91043781 0.4466992 0.60908886
    ##  [68,] 0.6447311 0.24836680 0.5681714 2.19073915 0.5084857 0.75499087
    ##  [69,] 0.3888923 0.84593605 0.2414858 0.22268253 0.8284761 0.37335758
    ##  [70,] 0.3783763 1.16194440 0.3779429 0.17471989 0.4150712 0.16251654
    ##  [71,] 0.4517414 0.36268988 0.3703569 0.33511691 0.4513698 1.82266685
    ##  [72,] 0.3494396 0.23353166 0.3015989 1.01612564 0.3271455 0.32208546
    ##  [73,] 0.4468894 0.52228968 0.3434584 0.40155281 0.6510794 1.47686869
    ##  [74,] 0.4582816 0.08972536 0.2534621 1.96039452 0.3813778 0.14311679
    ##  [75,] 0.2958539 2.36425699 0.3615567 1.15536897 0.6011080 1.24763949
    ##  [76,] 0.1745869 0.64234359 0.2497169 1.72908696 0.4702931 3.10255668
    ##  [77,] 0.3982354 0.89086368 0.2132571 0.88678487 0.6513056 1.57325930
    ##  [78,] 0.4678819 0.37210187 1.0030318 0.85588252 0.3227899 1.63335554
    ##  [79,] 0.2960130 0.70671577 0.5903573 0.59566330 0.3072292 2.50875507
    ##  [80,] 0.3075398 0.23797050 0.2828574 0.65247123 0.7285957 1.22249037
    ##  [81,] 0.6721561 0.48402222 0.6048641 1.16601348 0.6507327 0.88633938
    ##  [82,] 0.6920664 1.18003146 0.7657742 1.74907116 0.4881147 0.58799371
    ##  [83,] 0.6619577 1.88858603 0.5831450 1.39244131 0.3901833 2.29727406
    ##  [84,] 0.3322153 0.37687314 0.2996267 1.50557148 0.6240236 1.55324181
    ##  [85,] 0.3399474 0.96255011 0.1504468 0.29787877 0.4413745 0.89465607
    ##  [86,] 0.3326661 0.89472132 0.3236052 0.60592797 0.7745537 0.79440446
    ##  [87,] 0.2754497 1.02879095 0.7627315 0.83066815 0.2969566 1.09990089
    ##  [88,] 0.2969642 1.00935502 0.6165034 2.98626013 0.3667441 1.60407069
    ##  [89,] 0.3556240 0.85877503 0.4572782 1.09181676 0.5582016 1.14270154
    ##  [90,] 0.2609477 0.60621573 0.3370349 0.55849367 0.7383289 0.21997889
    ##  [91,] 0.3450086 1.98289512 0.3392299 0.18799835 0.6316722 0.20879541
    ##  [92,] 0.3629807 5.95989150 0.5430701 0.71310757 0.2010357 1.87033638
    ##  [93,] 0.2845081 0.31171627 0.3584848 0.51529729 0.6660407 0.68193335
    ##  [94,] 0.3872967 1.10001548 0.6648151 1.26516725 0.6440296 0.08115339
    ##  [95,] 0.6333528 0.35536899 0.2826008 0.11104888 0.5384537 1.10502165
    ##  [96,] 0.3222254 0.40159415 0.4085567 0.91590859 0.3758717 0.19843656
    ##  [97,] 0.1691107 1.88774780 0.2974910 0.44445516 0.3641381 0.34098825
    ##  [98,] 0.3914009 0.64195724 0.8271142 1.50250237 0.3232287 2.49879165
    ##  [99,] 0.3031477 2.36644731 0.8861989 0.85162872 0.5135308 0.66989122
    ## [100,] 0.7851889 1.98291642 0.3866684 0.28947422 0.3521927 2.60203063
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
    ## [1,] 0.02331 0.02315 0.02261 0.02232 0.02287 0.02262 0.02270 0.02347 0.02302 0.02230
    ## [2,] 0.01339 0.01400 0.01344 0.01374 0.01424 0.01347 0.01422 0.01325 0.01356 0.01372
    ## [3,] 0.00973 0.00969 0.00907 0.00928 0.00974 0.00966 0.00964 0.00934 0.00980 0.00968
    ## [4,] 0.00289 0.00280 0.00311 0.00263 0.00287 0.00303 0.00312 0.00286 0.00309 0.00302
    ## [5,] 0.00257 0.00223 0.00238 0.00199 0.00189 0.00210 0.00227 0.00236 0.00196 0.00234
    ## [6,] 0.00189 0.00217 0.00188 0.00225 0.00208 0.00205 0.00237 0.00191 0.00202 0.00213

    apply(sample.mat, 2, function(x) aggregate(x, by=list(healthstatus), FUN=sum))

    ## [[1]]
    ##   Group.1       x
    ## 1    LTBI 0.98651
    ## 2 nonLTBI 0.01349
    ## 
    ## [[2]]
    ##   Group.1       x
    ## 1    LTBI 0.98744
    ## 2 nonLTBI 0.01256
    ## 
    ## [[3]]
    ##   Group.1       x
    ## 1    LTBI 0.98714
    ## 2 nonLTBI 0.01286
    ## 
    ## [[4]]
    ##   Group.1       x
    ## 1    LTBI 0.98745
    ## 2 nonLTBI 0.01255
    ## 
    ## [[5]]
    ##   Group.1       x
    ## 1    LTBI 0.98765
    ## 2 nonLTBI 0.01235
    ## 
    ## [[6]]
    ##   Group.1       x
    ## 1    LTBI 0.98707
    ## 2 nonLTBI 0.01293
    ## 
    ## [[7]]
    ##   Group.1       x
    ## 1    LTBI 0.98758
    ## 2 nonLTBI 0.01242
    ## 
    ## [[8]]
    ##   Group.1       x
    ## 1    LTBI 0.98696
    ## 2 nonLTBI 0.01304
    ## 
    ## [[9]]
    ##   Group.1       x
    ## 1    LTBI 0.98755
    ## 2 nonLTBI 0.01245
    ## 
    ## [[10]]
    ##   Group.1       x
    ## 1    LTBI 0.98668
    ## 2 nonLTBI 0.01332

The function to do this is

    get_start_state_proportions(terminal_states$path_probs, healthstatus, samplesize, numsamples)

Risk Profile
------------

Further, the pathway probabilities can be used to give the distribution
of the terminal state values e.g. cost or time. This is called the risk
profile of the decision tree.

    osNode <- calc_riskprofile(osNode)
    print(osNode, "type", "path_prob", "path_payoff")

    ##                                                 levelName     type   path_prob path_payoff
    ## 1  LTBI screening cost                                      chance 1.000000000   0.3999045
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   1.0919308
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   1.8771197
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   3.2322764
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   5.4850107
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   4.3674339
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   5.1143746
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   5.5124222
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   6.1839437
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   6.4765983
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   7.8917413
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   8.2753757
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  10.2935960
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   8.6555253
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   3.6627186
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   7.1781320
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   4.6113027
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   5.7131056
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   5.0904732
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   5.1502298
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   5.7152458
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   5.7476873
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   7.7653800
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   9.7372672
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   8.5270048
    ## 26  ¦   °--No Screening                                    logical 0.062500000   3.0748472
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   4.9533267
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   5.1273882
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.5689401
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   0.9556085
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   2.1424811
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   2.5879801
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   4.6641636
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   5.8448379
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   7.6862934
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   9.3851087
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000  10.3048063
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500  15.5004413
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500  13.8375479
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625  14.7380017
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625  17.6474164
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.3154096
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.7166394
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   1.8136823
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.1005019
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   2.3573173
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   3.0396523
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   2.4516037
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   2.6171599
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   2.6003356
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   2.7918671
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   2.6071132
    ## 53  ¦   °--No Screening                                    logical 0.062500000   0.8584143
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   1.1626573
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   1.1380427
    ## 56  °--over 150k cob incidence                              chance 0.250000000   1.1384603
    ## 57      ¦--Screening                                       logical 0.062500000   1.4906530
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   2.3569050
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   3.0024024
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   3.8770374
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.9505435
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   6.3370854
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   8.3848313
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   7.8036938
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500  12.0297030
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   8.4663794
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   8.7069320
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   9.1094075
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   2.0331720
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   2.3418769
    ## 71      ¦       °--GP registered                            chance 0.006250000   3.0807646
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   3.7752579
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   4.1322588
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000   4.8089436
    ## 75      ¦               °--Test Positive                    chance 0.002625000   4.9577087
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   5.1030599
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   7.5638571
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   9.8359684
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   8.7666105
    ## 80      °--No Screening                                    logical 0.062500000   3.7404909
    ## 81          ¦--LTBI                                       terminal 0.025000000   5.5840357
    ## 82          °--non-LTBI                                   terminal 0.037500000   6.8481788

    plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
               osNode$Get('path_prob', filterFun = isLeaf)), type="h",
         xlab="payoff", ylab="probability")

![](README_files/figure-markdown_strict/unnamed-chunk-17-1.png)

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
