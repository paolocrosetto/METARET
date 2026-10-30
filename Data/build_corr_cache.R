## Precomputes the correlation panels
##  Re-run whenever df_mod.csv changes:
##     Rscript Data/build_corr_cache.R      (from the repository root)

suppressMessages(library(tidyverse))

df <- read.csv("METARET_APP/DATA/df_mod.csv", sep = ",")
## the same rows as the site: inconsistent answers out
source("METARET_APP/consistent_rows.R")
df <- consistent_rows(df)

quest_cols <- df %>%
  select(starts_with("soep"), starts_with("do"),
         "BIS", "BSSS", "AuditS", "CDCrisk") %>%
  names()
stopifnot(!"doi_2" %in% quest_cols)

## subject x task matrix of CRRA values 
wide_tasks <- df %>%
  filter(r > -1.5 & r < 2.5) %>%
  distinct(subject, task, .keep_all = TRUE) %>%
  select(task, r, subject) %>%
  pivot_wider(id_cols = subject, names_from = "task", values_from = "r") %>%
  select(-subject)

##  questionnaire answers, one row per person. Keeping only rows with a SOEP
##  answer dropped every paper without SOEP (BIS, BSSS, AUDIT and CDC, which come
##  from Fairley2019 alone, and the DOSPERT-only papers), and people with
##  several task rows were counted once per task.
wide_quest <- df %>%
  filter(if_any(all_of(quest_cols), ~ !is.na(.x))) %>%
  distinct(subject, .keep_all = TRUE) %>%
  select(all_of(quest_cols))

## subject x (task + questionnaire) matrix
wide_task_quest <- df %>%
  filter(r > -1.5 & r < 2.5) %>%
  distinct(subject, task, .keep_all = TRUE) %>%
  select(task, r, subject, all_of(quest_cols)) %>%
  pivot_wider(id_cols = c(subject, all_of(quest_cols)),
              names_from = "task", values_from = "r") %>%
  select(-subject)

task_cols <- setdiff(names(wide_task_quest), quest_cols)

## the correlation matrices
cor_tasks      <- cor(wide_tasks,      use = "pairwise.complete.obs")
cor_quest      <- cor(wide_quest,      use = "pairwise.complete.obs")
cor_task_quest <- cor(wide_task_quest, use = "pairwise.complete.obs")


POINT_CAP <- 4000
set.seed(20220823)
thin <- function(d, cap = POINT_CAP) if (nrow(d) <= cap) d else d[sample(nrow(d), cap), , drop = FALSE]
wide_tasks_thin <- thin(wide_tasks)
wide_quest_thin <- thin(wide_quest)

cache <- list(
  wide_tasks      = wide_tasks,
  wide_quest      = wide_quest,
  wide_task_quest = wide_task_quest,
  wide_tasks_thin = wide_tasks_thin,
  wide_quest_thin = wide_quest_thin,
  cor_tasks       = cor_tasks,
  cor_quest       = cor_quest,
  cor_task_quest  = cor_task_quest,
  task_cols       = task_cols,
  quest_cols      = quest_cols,
  point_cap       = POINT_CAP,
  built_at        = Sys.time()
)

saveRDS(cache, "METARET_APP/DATA/corr_cache.rds", compress = "xz")

cat("corr_cache.rds written\n")
cat("  wide_tasks      ", nrow(wide_tasks), "x", ncol(wide_tasks), "\n")
cat("  wide_quest      ", nrow(wide_quest), "x", ncol(wide_quest), "\n")
cat("  wide_task_quest ", nrow(wide_task_quest), "x", ncol(wide_task_quest), "\n")
cat("  scatter points capped at", POINT_CAP, "\n")
