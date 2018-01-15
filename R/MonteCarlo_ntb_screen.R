
#' MonteCarlo_n.tb_screen
#'
#' frequency of active tb and disease-free (screened)
#' TODO: generalise or remove from treeSimR::
#'
#' @param p_complete_Tx
#' @param n.uk_tb
#' @param n.all_tb
#' @param n
#'
#' @return
#' @export
#'
#' @examples
#' sum(IMPUTED_sample_year_cohort$all_tb)
#' 395
#' sum(IMPUTED_sample_year_cohort$uk_tb)
#' 197
MonteCarlo_n.tb_screen <- function(p_complete_Tx,
                                   n.uk_tb,
                                   n.all_tb,
                                   n = 2){

  n.tb_screen.all_tb <- c(NULL, NULL, NULL)
  n.tb_screen.uk_tb  <- c(NULL, NULL, NULL)

  prob <- max(p_complete_Tx, na.rm = TRUE)

  for (i in seq_len(n)) {

    after_screen.all_tb <- sum(runif(n = n.all_tb) > prob)
    after_screen.uk_tb  <- sum(runif(n = n.uk_tb) > prob)

    n.tb_screen.all_tb <- rbind(n.tb_screen.all_tb,
                                data.frame(sim = i,
                                           status = c("disease-free", "tb") ,
                                           n = c(n.all_tb - after_screen.all_tb, after_screen.all_tb)))

    n.tb_screen.uk_tb <- rbind(n.tb_screen.uk_tb,
                               data.frame(sim = i,
                                          status = c("disease-free", "tb"),
                                          n = c(n.uk_tb - after_screen.uk_tb, after_screen.uk_tb)))
  }

  list(n.tb_screen.all_tb = n.tb_screen.all_tb,
       n.tb_screen.uk_tb  = n.tb_screen.uk_tb)
}
