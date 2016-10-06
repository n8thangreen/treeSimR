#' Constructor for a Cost-Effectiveness Tree Object
#'
#' The resulting object is used in the main package functions.
#' Branch distributions are currently permitted as uniform, gamma and triangle.
#' All branches require some distribution.
#' All branches must end in a terminal node.
#'
#' @param yaml_tree YAML file or location address
#' @param details general details of decision tree
#'
#' @return data.tree object of class costeffectiveness_tree
#' @export
#'
#' @seealso calc.expectedValues
#' @examples
#' osNode <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
#' print(osNode, "type", "p", "distn", "mean", "sd")
#'
#' osNode <- calc.expectedValues(osNode)
#' print(osNode, "type", "p", "distn", "mean", "sd", "payoff")
#'
costeffectiveness_tree <- function(yaml_tree, details=NULL){

  stopifnot(is.character(yaml_tree))
  stopifnot(is.string(details))

  if (grep(pattern = ".yaml$", x = yaml_tree))
    osList <- yaml::yaml.load_file(yaml_tree)
  else{
    osList <- yaml::yaml.load(yaml_tree)}

  osNode <- data.tree::as.Node(osList)

  if(!all(osNode$Get("distn")%in%c("unif","gamma","triangle")))
                  stop("Error: Need to provide distributions for all branches")

  stopifnot(all(osNode$Get("type", filterFun = isLeaf) == "terminal"))

  ##TODO##
  # check for missing values
  # if missing probabilities then fill-in where possible, otherwise throw error
  # check that probabilities sum to 1
  # if not then give a warning

  class(osNode) <- c("costeffectiveness_tree", class(osNode))
  attr(osNode, "details") <- details

  osNode
}
