## Rebuilds the three analysis tables from df_mod.csv.  
## Run from the repository root:
##     Rscript Data/build_analysis_tables.R
##


suppressMessages(library(tidyverse))

df <- read_csv("METARET_APP_V2/DATA/df_mod.csv", show_col_types = FALSE)

quest_cols <- df %>%
  select(starts_with("soep"), starts_with("do"),
         "BIS", "BSSS", "AuditS", "CDCrisk") %>%
  names()


tasks <- df %>%
  filter(!is.na(r), !is.na(task), task != "quest_only") %>%
  distinct(bibkey, subject, task, .keep_all = TRUE)


safe_cor <- function(x, y) {
  ok <- complete.cases(x, y)
  x <- x[ok]; y <- y[ok]
  ## group_modify() wants a data frame back, so a skipped cell is an empty one
  if (length(x) < 4 || sd(x) == 0 || sd(y) == 0) {
    return(tibble(n = integer(), r_cor = double(), p = double(),
                  lo = double(), hi = double()))
  }
  ct <- cor.test(x, y, method = "pearson", conf.level = 0.95)
  tibble(n = length(x), r_cor = unname(ct$estimate), p = ct$p.value,
         lo = ct$conf.int[1], hi = ct$conf.int[2])
}

## --- 1. each task against each questionnaire ---------------
corr_task_quest <- tasks %>%
  select(bibkey, task, r, all_of(quest_cols)) %>%
  pivot_longer(all_of(quest_cols), names_to = "quest", values_to = "value") %>%
  filter(!is.na(value)) %>%
  group_by(bibkey, task, quest) %>%
  group_modify(~ safe_cor(.x$r, .x$value)) %>%
  ungroup()

## --- 2. each pair of tasks, on the subjects who did both -------------------
## Self-joined on subject and kept to task1 < task2, so each pair appears once
## and never against itself.
corr_task_task <- tasks %>%
  select(bibkey, subject, task, r) %>%
  inner_join(., ., by = c("bibkey", "subject"), relationship = "many-to-many") %>%
  filter(task.x < task.y) %>%
  group_by(bibkey, task1 = task.x, task2 = task.y) %>%
  group_modify(~ safe_cor(.x$r.x, .x$r.y)) %>%
  ungroup()

## --- 3. the gender gap in each cell ----------------------------------------
## Hedges' g of r, men minus women, with the variance a random-effects
## meta-analysis expects. Erkal2022 codes seven subjects as gender -1, which is
## neither, so the comparison is drawn explicitly between 0 and 1.
MIN_GROUP <- 15   # a group smaller than this gives a meaningless pooled sd

hedges_g <- function(m, f) {
  n1 <- length(m); n2 <- length(f)
  none <- tibble(nm = integer(), nf = integer(), g = double(), var_g = double())
  if (min(n1, n2) < MIN_GROUP) return(none)
  s_pooled <- sqrt(((n1 - 1) * var(m) + (n2 - 1) * var(f)) / (n1 + n2 - 2))
  if (!is.finite(s_pooled) || s_pooled == 0) return(none)
  d <- (mean(m) - mean(f)) / s_pooled
  J <- 1 - 3 / (4 * (n1 + n2) - 9)          # small-sample correction
  g <- J * d
  tibble(nm = n1, nf = n2, g = g,
         var_g = (n1 + n2) / (n1 * n2) + g^2 / (2 * (n1 + n2 - 2)))
}

gender_gap_by_cell <- tasks %>%
  filter(gender %in% c(0, 1)) %>%
  group_by(bibkey, task) %>%
  group_modify(~ hedges_g(.x$r[.x$gender == 0], .x$r[.x$gender == 1])) %>%
  ungroup()

write_csv(corr_task_quest,    "Data/corr_task_quest.csv")
write_csv(corr_task_task,     "Data/corr_task_task.csv")
write_csv(gender_gap_by_cell, "Data/gender_gap_by_cell.csv")

cat("analysis tables written from df_mod.csv\n")
cat("  corr_task_quest.csv    ", nrow(corr_task_quest), "cells,",
    n_distinct(corr_task_quest$bibkey), "papers\n")
cat("  corr_task_task.csv     ", nrow(corr_task_task), "pairs,",
    n_distinct(corr_task_task$bibkey), "papers\n")
cat("  gender_gap_by_cell.csv ", nrow(gender_gap_by_cell), "cells,",
    n_distinct(gender_gap_by_cell$bibkey), "papers (groups of at least",
    MIN_GROUP, "\b)\n")
