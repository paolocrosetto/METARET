## The rows every statistic of the site is computed on.
##
## df_mod.csv keeps inconsistent task answers (inconsistent == 1: a price list
## answered with more than one switch, or a dominated choice), one row per
## switching point (switch_no), with choice coded as for everyone else and r
## empty. They are offered in the download only. Here they leave the task
## statistics; a subject's questionnaire answers still count, so an
## inconsistent subject with questionnaire answers and no consistent task row
## stays in as a questionnaire-only row (once, not once per switching point).
## Used by server.R, Data/build_corr_cache.R and Data/build_analysis_tables.R,
## so the site and the precomputed tables can never disagree.
consistent_rows <- function(d) {
  if (!"inconsistent" %in% names(d)) return(d)
  quest <- intersect(c("soep", "soep_financial", "soep_patience", "soep_impulsive",
                       "doall", "dohealth", "dosocial", "doinvest", "dogamble",
                       "doethic", "dorecre", "BIS", "BSSS", "AuditS", "CDCrisk"),
                     names(d))
  ok   <- is.na(d$inconsistent) | d$inconsistent == 0
  keep <- ok
  ## the first inconsistent row of a subject with no consistent row and with at
  ## least one questionnaire answer becomes that subject's questionnaire row
  first <- !ok & !d$subject %in% d$subject[ok] & !duplicated(d$subject) &
    rowSums(!is.na(d[, quest, drop = FALSE])) > 0
  keep[first] <- TRUE
  d$task[first]   <- "quest_only"
  d$choice[first] <- NA
  d$r[first]      <- NA
  d[keep, , drop = FALSE]
}
