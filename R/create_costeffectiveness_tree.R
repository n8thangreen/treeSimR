
#' Constructor for a Cost-Effectiveness Tree Object
#'
#' The resulting object is used in the main package functions.
#' Branch distributions are currently permitted as uniform, gamma and triangle.
#' All branches require some distribution.
#' All branches must end in a terminal node.
#'
#' @param yaml_tree YAML file or location address
#' @param details General details of decision tree
#' @param data_prob Branching probability data
#' @param data_val Cost or health data
#' @param ... Additional arguments to be passed
#'
#' @return list of class costeffectiveness_object
#' @export
#'
#' @seealso \code{\link{calc.expectedValues}}
#'
#' @examples
#'
#' CEtree <- costeffectiveness_tree(yaml_tree = "raw data/LTBI_dtree-cost-distns.yaml")
#' print(CEtree)
#'
#' CEtree$osNode <- calc.expectedValues(CEtree$osNode)
#' print(CEtree)
#'
costeffectiveness_tree <- function(yaml_tree,
                                   details = "",
                                   data_prob = NA,
                                   data_val = NA, ...){

  stopifnot(is.character(yaml_tree))
  stopifnot(is.character(details))

  if (all(!is.na(data_val)) & !is.data.frame(data_val)) stop("data_val must be a data frame")
  if (all(!is.na(data_prob)) & !is.data.frame(data_prob)) stop("data_prob must be a data frame")

  if (grep(pattern = ".yaml$", x = yaml_tree))
    osList <- yaml::yaml.load_file(yaml_tree)
  else{
    osList <- yaml::yaml.load(yaml_tree)}

  osNode <- data.tree::as.Node(osList)

  ##TODO: how to link this with true list in sample_distribution() switch statement so always uptodate?
  if (!all(osNode$Get("distn") %in% c("lognormal", "pert", "beta", "gamma", "unif", "triangle", "none")))
                  stop("Error: Need to provide valid distribution for all branches")

  if (any(osNode$Get("type", filterFun = data.tree::isLeaf) != "terminal"))
    stop("Error: All leaf nodes must be terminal nodes")

  fields <- osNode$fields[osNode$fields %in% c('p','pmin','pmax','min','max','scale','shape')]
  attr_is.numeric <- purrr::map_lgl(.x = fields, .f = function(x) is.numeric(osNode$Get(x)))
  if (!all(attr_is.numeric)) warning('Check type of attributes. Should they be numeric rather than character?')


  ##TODO##
  # check for missing values
  # if missing probabilities then fill-in where possible, otherwise throw error
  # check that probabilities sum to 1, if not then give a warning

  if ("p" %in% osNode$fields) {

    osNode$Set(p = fill_in_missing_tree_probs(osNode, "p"))

  }else if (all(c("pmin", "pmax") %in% osNode$fields)) {

    osNode$Set(pmin = as.numeric(osNode$Get("pmin")))
    osNode$Set(pmax = as.numeric(osNode$Get("pmax")))

    ##TODO: use the inbuilt data.tree functions instead
    midpoint <- osNode$Get("pmin") + (osNode$Get("pmax") - osNode$Get("pmin"))/2
    osNode$Set(p = midpoint)

    osNode$Set(p = fill_in_missing_tree_probs(osNode, "p"))

  }else {
    stop("Missing branch probabilities")
  }


  # DSA data ----------------------------------------------------------------

  if (all(!is.na(data_prob))) {

    # transform to tidy format
    if (!"node" %in% names(data_prob)) {

      data_prob <- reshape2::melt(data = data_prob,
                                  id.vars = "scenario",
                                  variable.name = "node",
                                  value.name = "p")
    }

    data_node_names <- unique(data_prob$nodes)
    CE_tree_node_names <- unique(names(osNode$Get("level")))

    if (!all(data_node_names %in% CE_tree_node_names)) {
      stop("Node labels in probability data do not match node labels on cost-effectiveness decision tree.")
    }
  }

  if (all(!is.na(data_val))) {

    if (!"node" %in% names(data_val))
      stop("Node label column missing from cost-effectiveness data.")

    data_node_names <- unique(data_val$nodes)
    CE_tree_node_names <- unique(names(osNode$Get("level")))

    if (!all(data_node_names %in% CE_tree_node_names)) {
      stop("Node labels in cost-effectiveness value data do not match node labels on cost-effectiveness decision tree.")
    }
  }


  # return object -----------------------------------------------------------

  class(osNode) <- c("costeffectiveness_tree", class(osNode))

  costeff <- list(osNode = osNode,
                  data = list(data_prob = data_prob,
                              data_val = data_val))
  attr(costeff, "details") <- details
  class(costeff) <- c("costeffectiveness_object", class(costeff))

  invisible(costeff)
}
