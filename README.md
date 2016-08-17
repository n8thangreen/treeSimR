    treeSimR
========

R package for easy forward simulating probability decision trees and
PSA.

Currently contains functions to:

-   read-in and check tree object
-   simulate final outcomes
-   Monte Carlo simulate multiple simulations

Read-in trees
-------------

Simulate a scenario
-------------------

Monte Carlo forward simulation
------------------------------

library(yaml)

    ## Warning: package 'yaml' was built under R version 3.3.1

    library(data.tree)

    ## Warning: package 'data.tree' was built under R version 3.3.1

    devtools::load_all(".")

    ## Loading treeSimR

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

    # osList <- yaml.load(yaml)
    osList <- yaml.load_file("raw data/LTBI_dtree-cost-distns.yaml")
    osNode <- as.Node(osList)
    print(osNode, "type", "p", "distn", "mean", "sd")

    ##                                             levelName     type    p distn
    ## 1  LTBI screening cost                                decision   NA gamma
    ## 2   ¦--Screening                                        chance   NA gamma
    ## 3   ¦   ¦--LTBI                                         chance 0.25 gamma
    ## 4   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma
    ## 5   ¦   ¦   °--GP registered                            chance 0.40 gamma
    ## 6   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma
    ## 7   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma
    ## 8   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma
    ## 9   ¦   ¦           °--Test Positive                    chance 0.70 gamma
    ## 10  ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma
    ## 11  ¦   ¦               °--Start Treatment              chance 0.30 gamma
    ## 12  ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma
    ## 13  ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma
    ## 14  ¦   °--non-LTBI                                     chance 0.25 gamma
    ## 15  ¦       ¦--Not GP registered                      terminal 0.40 gamma
    ## 16  ¦       °--GP registered                          terminal 0.40 gamma
    ## 17  ¦           ¦--Not Agree to Screen                  chance 0.60 gamma
    ## 18  ¦           °--Agree to Screen                      chance 0.60 gamma
    ## 19  ¦               ¦--Test Negative                  terminal 0.70 gamma
    ## 20  ¦               °--Test Positive                  terminal 0.70 gamma
    ## 21  ¦                   ¦--Not Start Treatment        terminal 0.30 gamma
    ## 22  ¦                   °--Start Treatment            terminal 0.30 gamma
    ## 23  ¦                       ¦--Complete Treatment     terminal 0.75 gamma
    ## 24  ¦                       °--Not Complete Treatment terminal 0.75 gamma
    ## 25  °--No Screening                                     chance 0.25 gamma
    ## 26      ¦--LTBI                                       terminal 0.40 gamma
    ## 27      °--non-LTBI                                   terminal 0.60 gamma
    ##    mean sd
    ## 1     1  1
    ## 2     1  1
    ## 3     1  1
    ## 4     1  1
    ## 5     1  1
    ## 6     1  1
    ## 7     1  1
    ## 8     1  1
    ## 9     1  1
    ## 10    1  1
    ## 11    1  1
    ## 12    1  1
    ## 13    1  1
    ## 14    1  1
    ## 15    1  1
    ## 16    1  1
    ## 17    1  1
    ## 18    1  1
    ## 19    1  1
    ## 20    1  1
    ## 21    1  1
    ## 22    1  1
    ## 23    1  1
    ## 24    1  1
    ## 25    1  1
    ## 26    1  1
    ## 27    1  1

    sampleNode <- function(node) {
      DISTN <- list(distn=node$distn, params=c(mean=node$mean, sd=node$sd))
      sample.distributions(list(DISTN))
    }

    rpayoff <- osNode$Get(sampleNode)

    ## Loading required package: triangle

    osNode$Set(payoff = rpayoff)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                             levelName     type    p distn
    ## 1  LTBI screening cost                                decision   NA gamma
    ## 2   ¦--Screening                                        chance   NA gamma
    ## 3   ¦   ¦--LTBI                                         chance 0.25 gamma
    ## 4   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma
    ## 5   ¦   ¦   °--GP registered                            chance 0.40 gamma
    ## 6   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma
    ## 7   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma
    ## 8   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma
    ## 9   ¦   ¦           °--Test Positive                    chance 0.70 gamma
    ## 10  ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma
    ## 11  ¦   ¦               °--Start Treatment              chance 0.30 gamma
    ## 12  ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma
    ## 13  ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma
    ## 14  ¦   °--non-LTBI                                     chance 0.25 gamma
    ## 15  ¦       ¦--Not GP registered                      terminal 0.40 gamma
    ## 16  ¦       °--GP registered                          terminal 0.40 gamma
    ## 17  ¦           ¦--Not Agree to Screen                  chance 0.60 gamma
    ## 18  ¦           °--Agree to Screen                      chance 0.60 gamma
    ## 19  ¦               ¦--Test Negative                  terminal 0.70 gamma
    ## 20  ¦               °--Test Positive                  terminal 0.70 gamma
    ## 21  ¦                   ¦--Not Start Treatment        terminal 0.30 gamma
    ## 22  ¦                   °--Start Treatment            terminal 0.30 gamma
    ## 23  ¦                       ¦--Complete Treatment     terminal 0.75 gamma
    ## 24  ¦                       °--Not Complete Treatment terminal 0.75 gamma
    ## 25  °--No Screening                                     chance 0.25 gamma
    ## 26      ¦--LTBI                                       terminal 0.40 gamma
    ## 27      °--non-LTBI                                   terminal 0.60 gamma
    ##    mean sd    payoff
    ## 1     1  1 4.5107784
    ## 2     1  1 0.5607906
    ## 3     1  1 0.1367957
    ## 4     1  1 1.3205362
    ## 5     1  1 1.5735139
    ## 6     1  1 2.5569487
    ## 7     1  1 1.1241522
    ## 8     1  1 0.7146934
    ## 9     1  1 0.3045186
    ## 10    1  1 0.6952084
    ## 11    1  1 0.4995321
    ## 12    1  1 1.8853262
    ## 13    1  1 3.0972807
    ## 14    1  1 1.0815729
    ## 15    1  1 1.9505662
    ## 16    1  1 0.3293278
    ## 17    1  1 0.2013202
    ## 18    1  1 1.4345249
    ## 19    1  1 0.2683697
    ## 20    1  1 3.0815861
    ## 21    1  1 0.4378544
    ## 22    1  1 0.1077776
    ## 23    1  1 0.5076647
    ## 24    1  1 0.2424056
    ## 25    1  1 1.0754149
    ## 26    1  1 0.7080922
    ## 27    1  1 1.7876971

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)

    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                             levelName     type    p distn
    ## 1  LTBI screening cost                                decision   NA gamma
    ## 2   ¦--Screening                                        chance   NA gamma
    ## 3   ¦   ¦--LTBI                                         chance 0.25 gamma
    ## 4   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma
    ## 5   ¦   ¦   °--GP registered                            chance 0.40 gamma
    ## 6   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma
    ## 7   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma
    ## 8   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma
    ## 9   ¦   ¦           °--Test Positive                    chance 0.70 gamma
    ## 10  ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma
    ## 11  ¦   ¦               °--Start Treatment              chance 0.30 gamma
    ## 12  ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma
    ## 13  ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma
    ## 14  ¦   °--non-LTBI                                     chance 0.25 gamma
    ## 15  ¦       ¦--Not GP registered                      terminal 0.40 gamma
    ## 16  ¦       °--GP registered                          terminal 0.40 gamma
    ## 17  ¦           ¦--Not Agree to Screen                  chance 0.60 gamma
    ## 18  ¦           °--Agree to Screen                      chance 0.60 gamma
    ## 19  ¦               ¦--Test Negative                  terminal 0.70 gamma
    ## 20  ¦               °--Test Positive                  terminal 0.70 gamma
    ## 21  ¦                   ¦--Not Start Treatment        terminal 0.30 gamma
    ## 22  ¦                   °--Start Treatment            terminal 0.30 gamma
    ## 23  ¦                       ¦--Complete Treatment     terminal 0.75 gamma
    ## 24  ¦                       °--Not Complete Treatment terminal 0.75 gamma
    ## 25  °--No Screening                                     chance 0.25 gamma
    ## 26      ¦--LTBI                                       terminal 0.40 gamma
    ## 27      °--non-LTBI                                   terminal 0.60 gamma
    ##    mean sd    payoff
    ## 1     1  1 1.3558551
    ## 2     1  1 0.5993223
    ## 3     1  1 1.4853317
    ## 4     1  1 1.3205362
    ## 5     1  1 2.3927931
    ## 6     1  1 2.5569487
    ## 7     1  1 1.4310398
    ## 8     1  1 0.7146934
    ## 9     1  1 1.3296491
    ## 10    1  1 0.6952084
    ## 11    1  1 3.7369552
    ## 12    1  1 1.8853262
    ## 13    1  1 3.0972807
    ## 14    1  1 0.9119576
    ## 15    1  1 1.9505662
    ## 16    1  1 0.3293278
    ## 17    1  1 0.2013202
    ## 18    1  1 2.3449691
    ## 19    1  1 0.2683697
    ## 20    1  1 3.0815861
    ## 21    1  1 0.4378544
    ## 22    1  1 0.1077776
    ## 23    1  1 0.5076647
    ## 24    1  1 0.2424056
    ## 25    1  1 1.3558551
    ## 26    1  1 0.7080922
    ## 27    1  1 1.7876971

    osNode$Do(decision, filterFun = function(x) x$type == 'decision')
    osNode$Get('decision')[1]

    ## LTBI screening cost 
    ##      "No Screening"

    ## probabilty of successfully & correctly treating LTBI
    dummy <- rep(0, osNode$totalCount)
    dummy[12] <- 1
    osNode$Set(payoff = dummy)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                             levelName     type    p distn
    ## 1  LTBI screening cost                                decision   NA gamma
    ## 2   ¦--Screening                                        chance   NA gamma
    ## 3   ¦   ¦--LTBI                                         chance 0.25 gamma
    ## 4   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma
    ## 5   ¦   ¦   °--GP registered                            chance 0.40 gamma
    ## 6   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma
    ## 7   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma
    ## 8   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma
    ## 9   ¦   ¦           °--Test Positive                    chance 0.70 gamma
    ## 10  ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma
    ## 11  ¦   ¦               °--Start Treatment              chance 0.30 gamma
    ## 12  ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma
    ## 13  ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma
    ## 14  ¦   °--non-LTBI                                     chance 0.25 gamma
    ## 15  ¦       ¦--Not GP registered                      terminal 0.40 gamma
    ## 16  ¦       °--GP registered                          terminal 0.40 gamma
    ## 17  ¦           ¦--Not Agree to Screen                  chance 0.60 gamma
    ## 18  ¦           °--Agree to Screen                      chance 0.60 gamma
    ## 19  ¦               ¦--Test Negative                  terminal 0.70 gamma
    ## 20  ¦               °--Test Positive                  terminal 0.70 gamma
    ## 21  ¦                   ¦--Not Start Treatment        terminal 0.30 gamma
    ## 22  ¦                   °--Start Treatment            terminal 0.30 gamma
    ## 23  ¦                       ¦--Complete Treatment     terminal 0.75 gamma
    ## 24  ¦                       °--Not Complete Treatment terminal 0.75 gamma
    ## 25  °--No Screening                                     chance 0.25 gamma
    ## 26      ¦--LTBI                                       terminal 0.40 gamma
    ## 27      °--non-LTBI                                   terminal 0.60 gamma
    ##    mean sd payoff
    ## 1     1  1      0
    ## 2     1  1      0
    ## 3     1  1      0
    ## 4     1  1      0
    ## 5     1  1      0
    ## 6     1  1      0
    ## 7     1  1      0
    ## 8     1  1      0
    ## 9     1  1      0
    ## 10    1  1      0
    ## 11    1  1      0
    ## 12    1  1      1
    ## 13    1  1      0
    ## 14    1  1      0
    ## 15    1  1      0
    ## 16    1  1      0
    ## 17    1  1      0
    ## 18    1  1      0
    ## 19    1  1      0
    ## 20    1  1      0
    ## 21    1  1      0
    ## 22    1  1      0
    ## 23    1  1      0
    ## 24    1  1      0
    ## 25    1  1      0
    ## 26    1  1      0
    ## 27    1  1      0

    osNode$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)
    print(osNode, "type", "p", "distn", "mean", "sd", "payoff")

    ##                                             levelName     type    p distn
    ## 1  LTBI screening cost                                decision   NA gamma
    ## 2   ¦--Screening                                        chance   NA gamma
    ## 3   ¦   ¦--LTBI                                         chance 0.25 gamma
    ## 4   ¦   ¦   ¦--Not GP registered                      terminal 0.40 gamma
    ## 5   ¦   ¦   °--GP registered                            chance 0.40 gamma
    ## 6   ¦   ¦       ¦--Not Agree to Screen                terminal 0.60 gamma
    ## 7   ¦   ¦       °--Agree to Screen                      chance 0.60 gamma
    ## 8   ¦   ¦           ¦--Test Negative                  terminal 0.70 gamma
    ## 9   ¦   ¦           °--Test Positive                    chance 0.70 gamma
    ## 10  ¦   ¦               ¦--Not Start Treatment        terminal 0.30 gamma
    ## 11  ¦   ¦               °--Start Treatment              chance 0.30 gamma
    ## 12  ¦   ¦                   ¦--Complete Treatment     terminal 0.75 gamma
    ## 13  ¦   ¦                   °--Not Complete Treatment terminal 0.75 gamma
    ## 14  ¦   °--non-LTBI                                     chance 0.25 gamma
    ## 15  ¦       ¦--Not GP registered                      terminal 0.40 gamma
    ## 16  ¦       °--GP registered                          terminal 0.40 gamma
    ## 17  ¦           ¦--Not Agree to Screen                  chance 0.60 gamma
    ## 18  ¦           °--Agree to Screen                      chance 0.60 gamma
    ## 19  ¦               ¦--Test Negative                  terminal 0.70 gamma
    ## 20  ¦               °--Test Positive                  terminal 0.70 gamma
    ## 21  ¦                   ¦--Not Start Treatment        terminal 0.30 gamma
    ## 22  ¦                   °--Start Treatment            terminal 0.30 gamma
    ## 23  ¦                       ¦--Complete Treatment     terminal 0.75 gamma
    ## 24  ¦                       °--Not Complete Treatment terminal 0.75 gamma
    ## 25  °--No Screening                                     chance 0.25 gamma
    ## 26      ¦--LTBI                                       terminal 0.40 gamma
    ## 27      °--non-LTBI                                   terminal 0.60 gamma
    ##    mean sd  payoff
    ## 1     1  1 0.00945
    ## 2     1  1 0.00945
    ## 3     1  1 0.03780
    ## 4     1  1 0.00000
    ## 5     1  1 0.09450
    ## 6     1  1 0.00000
    ## 7     1  1 0.15750
    ## 8     1  1 0.00000
    ## 9     1  1 0.22500
    ## 10    1  1 0.00000
    ## 11    1  1 0.75000
    ## 12    1  1 1.00000
    ## 13    1  1 0.00000
    ## 14    1  1 0.00000
    ## 15    1  1 0.00000
    ## 16    1  1 0.00000
    ## 17    1  1 0.00000
    ## 18    1  1 0.00000
    ## 19    1  1 0.00000
    ## 20    1  1 0.00000
    ## 21    1  1 0.00000
    ## 22    1  1 0.00000
    ## 23    1  1 0.00000
    ## 24    1  1 0.00000
    ## 25    1  1 0.00000
    ## 26    1  1 0.00000
    ## 27    1  1 0.00000

    osNode$Get('payoff')[1]

    ## LTBI screening cost 
    ##             0.00945
