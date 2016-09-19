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

    path_dtree <- system.file("raw data/LTBI_dtree-cost-distns.yaml", package = "treeSimR")
    osList <- yaml.load_file(path_dtree)


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
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.318036566
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.048933859
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.850745032
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.423648082
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.949281144
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.577145271
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.078683749
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.104507781
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.008611053
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.757492397
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.011132112
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.318255569
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.496076269
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.642287923
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.140482554
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.158163197
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.632741503
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.041353315
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.034801198
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.996422713
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.466826556
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.739342365
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.509013827
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.831535942
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.640272808
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.637453604
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.673323300
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.203190313
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.492546266
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.261718584
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.472335465
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.944971791
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.068814494
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.467011741
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.014558033
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 3.212081845
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.080466768
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.569497493
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.639407043
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.215756514
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.452144906
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.686804571
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.197862835
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 0.822692454
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.260397143
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.117563541
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.761130206
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.359358394
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.210225757
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.950061947
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.382460773
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.269897813
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.426928602
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.304826410
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.245235764
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.044903686
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.318738742
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.267334940
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.311502162
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.502556434
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.702458581
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 4.910299393
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 3.440673035
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.991326388
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.326657411
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.096576152
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.103847233
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.045163551
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 2.648410201
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.111841967
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.053475994
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.766817831
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.832052501
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 3.224941549
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.273432505
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.477848699
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.546264157
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.100925499
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.151733126
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 2.006776163
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.004377861
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.663008976

Now given the sampled values, e.g. cost, and the probabilities, we can
calculate the expected values at each node, from leaf to root.

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.249267843
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.315280924
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.469880189
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.582234439
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.949281144
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.506304954
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.078683749
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.765157841
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.008611053
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 1.084471577
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.011132112
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.603773144
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.496076269
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.642287923
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 1.297286316
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 2.158163197
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.085052594
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.041353315
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.767067674
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.996422713
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.527959679
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.739342365
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 3.353856563
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.831535942
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.640272808
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.791243508
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 1.673323300
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.203190313
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.178718974
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.445803872
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.171850631
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.944971791
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 1.984654788
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.467011741
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.840746239
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 3.212081845
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.846127068
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.569497493
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 1.250926065
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.215756514
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.452144906
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.611364856
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.197862835
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.330549304
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.260397143
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 1.957185030
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 1.761130206
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 1.034848409
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 2.210225757
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.239268940
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.382460773
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 1.269897813
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.269072022
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.304826410
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.245235764
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.503071473
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.612729363
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 1.571120135
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.311502162
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.616298176
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.702458581
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 2.658038379
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 3.440673035
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.356524650
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.326657411
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.861758088
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.103847233
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 1.045163551
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.879797317
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.111841967
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 2.087651326
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.766817831
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 2.712601045
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 3.224941549
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.650202800
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.477848699
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.689493969
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.100925499
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 2.151733126
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 1.399556530
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.004377861
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 1.663008976

Similarly to above, we have created a better wrapper function to perform
these steps:

    osNode <- calc_expectedValues(osNode)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                                 levelName     type    p distn mean sd      payoff
    ## 1  LTBI screening cost                                      chance   NA gamma    1  1 0.211870700
    ## 2   ¦--under 40k cob incidence                              chance 0.25 gamma    1  1 0.380116025
    ## 3   ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.395132876
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.845449066
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.404318612
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.709304053
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.398977576
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.783195846
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.911588802
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.207262406
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.007604800
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.683269887
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.058122515
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.852904001
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.735082437
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.831663233
    ## 17  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.006042859
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.023191441
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.653546658
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.457388717
    ## 21  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.476249366
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 1.105256644
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 0.482241245
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.309110885
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.333877442
    ## 26  ¦   °--No Screening                                    logical 0.25 gamma    1  1 1.125331225
    ## 27  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 2.761023814
    ## 28  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.034869499
    ## 29  ¦--40-150k cob incidence                                chance 0.25 gamma    1  1 0.172364323
    ## 30  ¦   ¦--Screening                                       logical 0.25 gamma    1  1 0.277106957
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 0.656289826
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 1.055229965
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 0.585494601
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.419124236
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 0.556700099
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 0.730449244
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.064836612
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.120285139
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 0.095836900
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 0.083194975
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.044587559
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.452138002
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.117673216
    ## 44  ¦   ¦       °--GP registered                            chance 0.40 gamma    1  1 1.012671789
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.971416772
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.716369542
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.553955134
    ## 48  ¦   ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.469429927
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.181412706
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.383353717
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.841422740
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.003048882
    ## 53  ¦   °--No Screening                                    logical 0.25 gamma    1  1 0.412350335
    ## 54  ¦       ¦--LTBI                                       terminal 0.40 gamma    1  1 0.800007131
    ## 55  ¦       °--non-LTBI                                   terminal 0.60 gamma    1  1 0.153912472
    ## 56  °--over 150k cob incidence                              chance 0.25 gamma    1  1 0.295002452
    ## 57      ¦--Screening                                       logical 0.25 gamma    1  1 0.755875456
    ## 58      ¦   ¦--LTBI                                         chance 0.25 gamma    1  1 2.555785859
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma    1  1 4.366654938
    ## 60      ¦   ¦   °--GP registered                            chance 0.40 gamma    1  1 2.022809710
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 1.803381132
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.60 gamma    1  1 1.567968385
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma    1  1 1.557823361
    ## 64      ¦   ¦           °--Test Positive                    chance 0.70 gamma    1  1 0.682131475
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.105271179
    ## 66      ¦   ¦               °--Start Treatment              chance 0.30 gamma    1  1 2.168500403
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma    1  1 2.155211815
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma    1  1 0.736122055
    ## 69      ¦   °--non-LTBI                                     chance 0.25 gamma    1  1 0.467715966
    ## 70      ¦       ¦--Not GP registered                      terminal 0.40 gamma    1  1 0.188364946
    ## 71      ¦       °--GP registered                            chance 0.40 gamma    1  1 0.980924968
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.60 gamma    1  1 0.954341924
    ## 73      ¦           °--Agree to Screen                      chance 0.60 gamma    1  1 0.680533023
    ## 74      ¦               ¦--Test Negative                  terminal 0.70 gamma    1  1 0.365735643
    ## 75      ¦               °--Test Positive                    chance 0.70 gamma    1  1 0.606454391
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.30 gamma    1  1 0.766796490
    ## 77      ¦                   °--Start Treatment              chance 0.30 gamma    1  1 1.254718146
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.75 gamma    1  1 1.101832343
    ## 79      ¦                       °--Not Complete Treatment terminal 0.75 gamma    1  1 0.571125185
    ## 80      °--No Screening                                    logical 0.25 gamma    1  1 0.424134353
    ## 81          ¦--LTBI                                       terminal 0.40 gamma    1  1 1.020385908
    ## 82          °--non-LTBI                                   terminal 0.60 gamma    1  1 0.026633316

Monte Carlo forward simulation
------------------------------

We are now in a position to do a probability sensitivity analysis (PSA)
and calculate multiple realisations for specific nodes e.g. those at
which a decision is to be made.

    MonteCarlo_expectedValues(osNode, n=100)

    ## $`expected values`
    ##             [,1]       [,2]      [,3]      [,4]      [,5]       [,6]
    ##   [1,] 0.2206944 1.48338204 0.3447571 1.5235520 0.5438449 0.96613664
    ##   [2,] 0.3002003 0.44559629 0.6424176 1.2643240 0.3244085 0.94550301
    ##   [3,] 0.4545248 0.35395864 0.3219735 1.0756452 0.4773787 0.25961302
    ##   [4,] 0.2949404 2.90322146 0.4640067 1.5242451 0.3352253 0.69748170
    ##   [5,] 0.4217774 0.46029612 0.3620488 3.2549830 0.5101139 0.12970596
    ##   [6,] 0.2289232 2.51788738 0.6760586 0.9987797 0.2013628 1.06190723
    ##   [7,] 0.5795040 0.86844141 0.4747557 0.2264291 0.4225169 3.18076320
    ##   [8,] 0.3062517 0.48132102 0.7380131 0.5816792 0.2300343 1.15721650
    ##   [9,] 0.3941042 0.82962554 0.6751878 0.4526639 0.5675646 0.68188362
    ##  [10,] 0.2576387 1.13625367 0.7574085 0.4362707 0.5994219 0.19332346
    ##  [11,] 0.5835999 0.29706683 0.5587646 1.4822747 0.3593538 2.40062436
    ##  [12,] 0.4491316 0.52966435 0.4299791 1.1436495 0.4630277 0.82841516
    ##  [13,] 0.6837955 0.79796820 0.8460020 0.3701897 0.6665835 0.76231341
    ##  [14,] 0.2435837 0.58910035 0.2718543 0.8987621 0.5084568 0.31644960
    ##  [15,] 0.3233846 2.19675136 0.6006044 0.2438782 0.4487725 0.69575157
    ##  [16,] 0.3748401 1.20757713 0.2001796 1.3825964 0.4137578 0.63087659
    ##  [17,] 0.7619685 2.44722867 0.3774632 1.6233076 0.3505312 2.32947489
    ##  [18,] 0.2923590 0.83181927 0.6375573 2.0162107 0.4974996 1.56222269
    ##  [19,] 0.4071742 0.71956312 0.4451394 0.2760710 0.5157942 0.79056397
    ##  [20,] 0.1701471 1.21926195 0.5607516 0.3396593 0.5492636 1.86541493
    ##  [21,] 0.2398115 0.59617936 0.3547414 1.3202817 0.4992565 0.47395316
    ##  [22,] 0.4364837 0.79288226 0.3824629 1.2565141 0.4221059 0.04874661
    ##  [23,] 0.3990875 0.51976673 0.2871835 1.6318236 0.2682906 0.76804873
    ##  [24,] 0.4857271 0.50029277 0.3692497 1.9010730 0.3694792 0.88966714
    ##  [25,] 0.4926455 0.83600558 0.3691396 1.0008920 0.4269218 1.35031080
    ##  [26,] 0.8131636 0.64558902 0.4253731 2.5642718 0.3077679 0.92994877
    ##  [27,] 0.5971914 1.29950840 0.5598350 0.8119068 0.4226874 2.62665262
    ##  [28,] 0.4898716 1.90706366 0.8595660 0.3156361 0.3020432 1.48752014
    ##  [29,] 0.2642583 0.13523151 0.5941137 1.0651816 0.2324033 1.57334062
    ##  [30,] 0.5816415 0.55112937 0.6775548 0.7633291 0.6707403 0.38626906
    ##  [31,] 0.3445566 0.85778269 0.3826544 1.5332484 0.4280408 0.56742139
    ##  [32,] 0.8325267 1.13169897 0.6555129 0.4872438 0.2898284 0.47631081
    ##  [33,] 0.2536566 0.82604003 0.6060840 2.1870673 0.7008426 0.32918343
    ##  [34,] 0.4707935 0.21766738 0.3135220 1.0849074 0.4784132 0.74655270
    ##  [35,] 0.2893164 1.62138925 0.6874389 0.1207922 0.4207114 0.98470116
    ##  [36,] 0.7237805 1.64383519 0.6140801 0.5957617 0.2065103 0.47820708
    ##  [37,] 0.2402862 0.50946061 0.4941160 1.3568235 0.5106760 2.40772701
    ##  [38,] 0.4623042 0.39778753 0.3792974 0.7534633 0.3456939 0.28971450
    ##  [39,] 0.2552812 0.35060667 0.4429678 0.8311752 0.4572839 1.71781997
    ##  [40,] 0.5874486 1.00254064 0.3436413 1.3246203 0.5342885 0.46523508
    ##  [41,] 0.7509256 1.30828436 0.3468809 0.6545186 0.3913482 1.23037382
    ##  [42,] 0.3213414 0.26626672 0.4499993 0.4343562 0.3889207 0.78048818
    ##  [43,] 0.6297008 0.53171796 0.3098467 0.7743006 0.4089276 0.92275691
    ##  [44,] 0.5173006 0.80922960 0.7525939 0.2923658 0.6538721 0.19050123
    ##  [45,] 0.5910947 0.63777329 0.2709156 0.5294081 0.3264666 0.24987060
    ##  [46,] 0.2289347 0.12477946 0.4399006 0.8841149 0.6517721 0.93888918
    ##  [47,] 0.1956388 1.52908946 0.3516286 0.4088478 0.3631104 1.16494398
    ##  [48,] 0.3078271 0.97335373 0.2841427 0.9126220 0.3493803 1.60332697
    ##  [49,] 0.5466653 1.03780324 0.3517994 0.6226419 0.6357819 1.22437609
    ##  [50,] 0.5509853 0.30970185 0.3538258 0.5105596 0.8385957 0.27752754
    ##  [51,] 0.3461345 0.09403805 0.3188836 1.3021338 0.5724550 1.37296994
    ##  [52,] 0.5486121 0.80609584 0.6295290 1.3552423 0.4669320 0.98824136
    ##  [53,] 0.5334190 0.23032348 0.4908645 2.3689329 0.2836562 1.20894096
    ##  [54,] 0.5243671 0.26927882 0.3007920 0.3166139 0.4626746 0.32518095
    ##  [55,] 0.4159848 1.08115833 0.1983885 0.5087939 0.4211749 2.93709007
    ##  [56,] 0.3639273 0.93889328 0.2356216 0.2825429 0.6039172 1.28683173
    ##  [57,] 0.9856220 0.38947955 0.4129471 1.5976430 0.3423097 4.37025044
    ##  [58,] 0.2600776 0.31376993 0.4881088 0.5862286 0.6079674 2.87750345
    ##  [59,] 0.6573913 0.29100694 0.4798786 1.1130522 0.2781740 1.67208617
    ##  [60,] 0.2199758 0.60274437 0.5851822 0.5680034 0.5059392 1.50073473
    ##  [61,] 0.2225195 0.96627665 0.6844593 0.6705232 0.3636815 1.05542248
    ##  [62,] 0.4096277 0.66440281 0.4677305 0.5409192 0.5492155 0.89496582
    ##  [63,] 0.2267089 2.90861682 0.4140630 1.1635629 0.4533221 1.82187529
    ##  [64,] 0.3501255 1.00254891 0.2687654 0.4381930 0.3344070 1.41937907
    ##  [65,] 0.1882343 2.08213156 0.3753749 0.7026492 0.6464891 1.15342577
    ##  [66,] 0.2926237 0.07946618 0.1770607 1.8918517 0.2922293 0.98990674
    ##  [67,] 0.2911496 0.13624856 0.2446158 0.7404139 0.4477576 0.99675230
    ##  [68,] 1.1414500 0.18518343 0.4146649 2.5228752 0.3627766 0.97194725
    ##  [69,] 0.2197100 2.28464254 0.4880564 0.1626137 0.5746613 0.73937831
    ##  [70,] 0.4471146 1.45855098 0.1728759 2.4741829 0.6468397 0.80242170
    ##  [71,] 0.7994288 0.14208090 0.8854620 0.7962504 0.5032835 0.25827287
    ##  [72,] 0.5712113 0.95538317 0.6407176 0.1820071 0.9724935 2.77069444
    ##  [73,] 0.2293459 2.17390599 0.5421256 0.8973040 0.2024848 0.75181974
    ##  [74,] 0.2780303 0.69730121 0.3434126 1.1882033 0.5374654 0.57529768
    ##  [75,] 0.6386018 0.61890366 0.4813910 1.8473158 0.3616091 1.00983365
    ##  [76,] 0.4938582 0.98616765 0.3308235 1.0391021 0.2435843 1.75966348
    ##  [77,] 0.5691164 0.22815267 0.3741655 0.5347748 0.3846766 1.23254497
    ##  [78,] 0.5866337 0.45986387 0.5203648 1.5070106 0.5996168 0.53147819
    ##  [79,] 0.2170169 1.12592574 0.4892378 0.3798345 0.4762328 1.50235702
    ##  [80,] 0.5982361 0.53278911 0.8230679 0.9952252 0.3551807 1.29316106
    ##  [81,] 0.2472213 0.48054305 0.5699757 0.7170917 0.3500541 0.34576350
    ##  [82,] 0.5289334 1.32804750 0.3552745 0.3064081 0.2363354 0.37693256
    ##  [83,] 0.4277588 1.01357537 0.8088796 1.9077310 0.3570194 0.68887979
    ##  [84,] 0.5625377 1.76103019 0.7581523 0.4175233 0.5136577 0.18641003
    ##  [85,] 0.4846684 0.64606770 0.5811979 0.8583607 0.2712342 0.93606835
    ##  [86,] 0.2560897 0.90125414 0.3377423 3.0874204 0.4044516 0.94044614
    ##  [87,] 0.5007834 0.89402659 0.2910421 1.3523805 0.4418145 1.56522142
    ##  [88,] 0.5431518 1.56853265 0.2243534 0.8044027 0.4122838 1.35281078
    ##  [89,] 0.4353301 0.65624855 0.8309050 0.3358113 0.5335797 1.02688673
    ##  [90,] 0.4167093 2.36394162 0.4706016 0.8511933 0.4977247 0.84331807
    ##  [91,] 0.3632420 0.76341891 0.2512253 1.7650831 0.6366412 0.31793344
    ##  [92,] 0.2677400 2.14610220 0.2714708 0.4322554 0.3410221 1.00820453
    ##  [93,] 0.3237592 0.27654625 0.3426061 0.2539989 0.3546634 0.39157785
    ##  [94,] 0.4562549 0.09851021 0.7842988 0.3986222 0.3475740 0.30144884
    ##  [95,] 0.4058228 0.70778511 0.5503900 0.8245784 0.5189937 0.43173192
    ##  [96,] 0.2154604 1.30145716 0.7363725 0.9567168 0.3568655 1.09260249
    ##  [97,] 0.6167547 1.11646949 0.4716225 0.2100575 0.6894039 1.23020235
    ##  [98,] 0.6715861 0.13158182 0.2515163 1.4356951 0.2978344 0.93012824
    ##  [99,] 0.3461619 1.00261371 0.4108874 2.2813630 0.4572278 0.03502559
    ## [100,] 0.2265594 0.87988352 0.4515347 1.5165920 0.3700993 0.52741238
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
    ## [1,] 0.02288 0.02252 0.02297 0.02176 0.02354 0.02252 0.02227 0.02262 0.02202 0.02267
    ## [2,] 0.01347 0.01355 0.01389 0.01337 0.01388 0.01357 0.01440 0.01372 0.01307 0.01354
    ## [3,] 0.00967 0.00978 0.00943 0.00940 0.00909 0.00925 0.00878 0.00964 0.00946 0.00935
    ## [4,] 0.00314 0.00270 0.00287 0.00277 0.00261 0.00279 0.00278 0.00300 0.00294 0.00289
    ## [5,] 0.00200 0.00243 0.00196 0.00218 0.00229 0.00214 0.00218 0.00220 0.00212 0.00216
    ## [6,] 0.00200 0.00207 0.00232 0.00208 0.00217 0.00226 0.00208 0.00218 0.00219 0.00208

    apply(sample.mat, 2, function(x) aggregate(x, by=list(healthstatus), FUN=sum))

    ## [[1]]
    ##   Group.1       x
    ## 1    LTBI 0.98655
    ## 2 nonLTBI 0.01345
    ## 
    ## [[2]]
    ##   Group.1       x
    ## 1    LTBI 0.98628
    ## 2 nonLTBI 0.01372
    ## 
    ## [[3]]
    ##   Group.1       x
    ## 1    LTBI 0.98694
    ## 2 nonLTBI 0.01306
    ## 
    ## [[4]]
    ##   Group.1       x
    ## 1    LTBI 0.98734
    ## 2 nonLTBI 0.01266
    ## 
    ## [[5]]
    ##   Group.1       x
    ## 1    LTBI 0.98706
    ## 2 nonLTBI 0.01294
    ## 
    ## [[6]]
    ##   Group.1       x
    ## 1    LTBI 0.98716
    ## 2 nonLTBI 0.01284
    ## 
    ## [[7]]
    ##   Group.1       x
    ## 1    LTBI 0.98717
    ## 2 nonLTBI 0.01283
    ## 
    ## [[8]]
    ##   Group.1       x
    ## 1    LTBI 0.98704
    ## 2 nonLTBI 0.01296
    ## 
    ## [[9]]
    ##   Group.1       x
    ## 1    LTBI 0.98723
    ## 2 nonLTBI 0.01277
    ## 
    ## [[10]]
    ##   Group.1       x
    ## 1    LTBI 0.98654
    ## 2 nonLTBI 0.01346

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
    ## 1  LTBI screening cost                                      chance 1.000000000   0.2482551
    ## 2   ¦--under 40k cob incidence                              chance 0.250000000   0.5248658
    ## 3   ¦   ¦--Screening                                       logical 0.062500000   0.7514253
    ## 4   ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.2871955
    ## 5   ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   1.4621759
    ## 6   ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.4516406
    ## 7   ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.3520694
    ## 8   ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   3.4919536
    ## 9   ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   4.5881506
    ## 10  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   3.8819181
    ## 11  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   4.2232309
    ## 12  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   4.8404872
    ## 13  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   5.5209993
    ## 14  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   5.4380670
    ## 15  ¦   ¦   °--non-LTBI                                     chance 0.015625000   1.1218928
    ## 16  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   1.3991323
    ## 17  ¦   ¦       °--GP registered                            chance 0.006250000   1.7708223
    ## 18  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.2745392
    ## 19  ¦   ¦           °--Agree to Screen                      chance 0.003750000   2.3486544
    ## 20  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   2.8756316
    ## 21  ¦   ¦               °--Test Positive                    chance 0.002625000   2.6471518
    ## 22  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   2.7213864
    ## 23  ¦   ¦                   °--Start Treatment              chance 0.000787500   3.5679084
    ## 24  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   4.7153506
    ## 25  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   3.6481418
    ## 26  ¦   °--No Screening                                    logical 0.062500000   1.4047493
    ## 27  ¦       ¦--LTBI                                       terminal 0.025000000   1.9198178
    ## 28  ¦       °--non-LTBI                                   terminal 0.037500000   2.5278429
    ## 29  ¦--40-150k cob incidence                                chance 0.250000000   0.7402867
    ## 30  ¦   ¦--Screening                                       logical 0.062500000   1.1918214
    ## 31  ¦   ¦   ¦--LTBI                                         chance 0.015625000   1.4452677
    ## 32  ¦   ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   1.5197657
    ## 33  ¦   ¦   ¦   °--GP registered                            chance 0.006250000   2.0043853
    ## 34  ¦   ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   2.4911741
    ## 35  ¦   ¦   ¦       °--Agree to Screen                      chance 0.003750000   2.4494591
    ## 36  ¦   ¦   ¦           ¦--Test Negative                  terminal 0.002625000   2.5279503
    ## 37  ¦   ¦   ¦           °--Test Positive                    chance 0.002625000   3.0067876
    ## 38  ¦   ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   4.2843749
    ## 39  ¦   ¦   ¦               °--Start Treatment              chance 0.000787500   3.5869619
    ## 40  ¦   ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   3.6032521
    ## 41  ¦   ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   4.3442376
    ## 42  ¦   ¦   °--non-LTBI                                     chance 0.015625000   2.7445139
    ## 43  ¦   ¦       ¦--Not GP registered                      terminal 0.006250000   5.7840356
    ## 44  ¦   ¦       °--GP registered                            chance 0.006250000   3.5867235
    ## 45  ¦   ¦           ¦--Not Agree to Screen                terminal 0.003750000   3.8982129
    ## 46  ¦   ¦           °--Agree to Screen                      chance 0.003750000   4.6789168
    ## 47  ¦   ¦               ¦--Test Negative                  terminal 0.002625000   5.5820137
    ## 48  ¦   ¦               °--Test Positive                    chance 0.002625000   5.3360959
    ## 49  ¦   ¦                   ¦--Not Start Treatment        terminal 0.000787500   5.9894059
    ## 50  ¦   ¦                   °--Start Treatment              chance 0.000787500   6.8733832
    ## 51  ¦   ¦                       ¦--Complete Treatment     terminal 0.000590625   8.1471871
    ## 52  ¦   ¦                       °--Not Complete Treatment terminal 0.000590625   7.6492957
    ## 53  ¦   °--No Screening                                    logical 0.062500000   2.2568787
    ## 54  ¦       ¦--LTBI                                       terminal 0.025000000   4.9296138
    ## 55  ¦       °--non-LTBI                                   terminal 0.037500000   3.0027086
    ## 56  °--over 150k cob incidence                              chance 0.250000000   0.4726330
    ## 57      ¦--Screening                                       logical 0.062500000   0.8427322
    ## 58      ¦   ¦--LTBI                                         chance 0.015625000   1.5065272
    ## 59      ¦   ¦   ¦--Not GP registered                      terminal 0.006250000   1.7306996
    ## 60      ¦   ¦   °--GP registered                            chance 0.006250000   2.9418422
    ## 61      ¦   ¦       ¦--Not Agree to Screen                terminal 0.003750000   3.5655566
    ## 62      ¦   ¦       °--Agree to Screen                      chance 0.003750000   4.7103195
    ## 63      ¦   ¦           ¦--Test Negative                  terminal 0.002625000   6.9500844
    ## 64      ¦   ¦           °--Test Positive                    chance 0.002625000   4.9969507
    ## 65      ¦   ¦               ¦--Not Start Treatment        terminal 0.000787500   5.1768899
    ## 66      ¦   ¦               °--Start Treatment              chance 0.000787500   5.7724488
    ## 67      ¦   ¦                   ¦--Complete Treatment     terminal 0.000590625   6.4124897
    ## 68      ¦   ¦                   °--Not Complete Treatment terminal 0.000590625   6.1664054
    ## 69      ¦   °--non-LTBI                                     chance 0.015625000   1.6593343
    ## 70      ¦       ¦--Not GP registered                      terminal 0.006250000   3.3235134
    ## 71      ¦       °--GP registered                            chance 0.006250000   2.0366602
    ## 72      ¦           ¦--Not Agree to Screen                terminal 0.003750000   2.0867560
    ## 73      ¦           °--Agree to Screen                      chance 0.003750000   2.6154410
    ## 74      ¦               ¦--Test Negative                  terminal 0.002625000   3.0749560
    ## 75      ¦               °--Test Positive                    chance 0.002625000   2.9827558
    ## 76      ¦                   ¦--Not Start Treatment        terminal 0.000787500   3.9503555
    ## 77      ¦                   °--Start Treatment              chance 0.000787500   3.2395387
    ## 78      ¦                       ¦--Complete Treatment     terminal 0.000590625   3.2983104
    ## 79      ¦                       °--Not Complete Treatment terminal 0.000590625   3.5231442
    ## 80      °--No Screening                                    logical 0.062500000   1.0000454
    ## 81          ¦--LTBI                                       terminal 0.025000000   2.3076077
    ## 82          °--non-LTBI                                   terminal 0.037500000   1.0073578

    plot(data.frame(osNode$Get('path_payoff', filterFun = isLeaf),
               osNode$Get('path_prob', filterFun = isLeaf)), type="h",
         xlab="payoff", ylab="probability")

![](README_files/figure-markdown_strict/unnamed-chunk-19-1.png)

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
