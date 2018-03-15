
#' Fill-in Missing Tree Probabilities
#'
#' For binary tree only i.e. event/no event
#'
#' @param osNode
#' @param pname
#'
#' @return fill filled-in probabilities
#' @export
#'
#' @examples
#'
#' pname <- "pmax"
#' osNode <- osNode.cost_pdistn
#'
fill_in_missing_tree_probs <- function(osNode,
                                       pname) {

  df <-
    suppressWarnings(
      data.frame(level = osNode$Get("level"),
                 p = as.numeric(as.character(osNode$Get(pname)))
      )
    )

  df$id <- seq_len(nrow(df))

  fill <- df$p
  df$keep <- TRUE

  while (max(df$level) != 1) {

    for (i in seq_len(nrow(df) - 1)) {

      if (df$level[i] == df$level[i + 1]) {

        if (any(is.na(df[i, "p"]), is.na(df[i + 1, "p"]))) {

          na_entry <- which(is.na(c(df[i, "p"], df[i + 1, "p"]))) - 1
          fill[df$id[i + na_entry]] <- 1 - df[i + 1 - na_entry, "p"]
        }

        df$keep[c(i, i + 1)] <- c(FALSE, FALSE)
      }
    }

    df <- df[df$keep, ]
  }

  return(fill)
}



