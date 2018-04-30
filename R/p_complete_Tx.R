
#' p_complete_Tx
#'
#' total prob successfully cured of LTBI for each WHO category
#' number of ways to effectively complete Tx per LTBI
#'
#' @param osNode.cost
#' @param who_levels
#'
#' @return
#' @export
#'
#' @examples
p_complete_Tx <- function(osNode.cost,
                          who_levels) {

  .Deprecated("LTBIscreeningproject::subset_pop_dectree")

  incid_cat <- "(350,1e+05]" #top group

  # extract screening part of tree
  LTBItreeClone <- Clone(osNode.cost[[incid_cat]]$LTBI,
                         pruneFun = function(x) myPruneFun(x, "Effective"))

  p_effective <- LTBItreeClone$Get('path_probs',
                                   filterFun = function(x) x$name == "Effective") %>% sum()

  p_LTBI <- osNode.cost$Get('path_probs',
                            filterFun = function(x) x$name == "LTBI") %>% setNames(who_levels)

  p_complete_Tx <- p_effective/p_LTBI[incid_cat]

  return(p_complete_Tx)
}
