#### Krull, S., Pelster, M. & Steinorth, P. (2024). Skill, effort, luck:
#### Determinants of rank-based endowments and risk-taking in a social setting.
#### Journal of Behavioral and Experimental Finance, 42, 100924.
#### https://doi.org/10.1016/j.jbef.2024.100924
#### Data: rawdata.RData and rawdata_endowment.RData of the replication package

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online oTree experiment on CloudResearch (MTurk), restricted to users in
## the United States: December 2021 and February 2022 (rawdata.RData), plus an
## additional treatment in November 2023 (rawdata_endowment.RData) -- no
## participant appears in both files. "First, we measured individuals' risk
## preferences. Participants self-reported their perceived willingness to take
## risks on an eleven-point scale (Dohmen et al., 2011). In addition,
## participants completed a Holt and Laury (2002) risk aversion elicitation
## task", using the ready-made oTree app of Holzmeister (2017): the standard
## list, 2.00/1.60 against 3.85/0.10 dollars (the payoffs seen in the file).
## The Gneezy-Potters investment that follows is the treated outcome (it is
## played after a rank-based endowment) and is not used.
##
## The HL list goes to the shared standard-HL block of generate_r.R:
## choice = number of B (risky) choices = 11 - the row where B starts.
## Subjects who switched more than once or chose A in the last row's dominance
## check keep an HL row with inconsistent = 1, for the download only, one row
## per switch to B (Data/inconsistent_rows.R); their SOEP answer still counts.
## Subjects with an incomplete list keep only the SOEP item, as 'quest_only'.
##
## The SOEP answer is stored as 1 ... 9 with the end points as their labels:
## "not at all willing to take risks" = 0 and "very willing to take risks" =
## 10. Age was asked in brackets: midpoints, 69.5 for "65 or above" as in
## Burro et al. 2026. gender: Female 1, Male 0, non-binary / not said NA.
## Kept: the 1,074 who reached the exit survey (the paper reports 608 + 469
## completed).
df <- read_csv("Data/Krull_et_al_2024/original_dataset.csv", show_col_types = FALSE) %>%
  filter(finished)

hl <- as.matrix(df[, paste0("hl_", 1:10)])
## consistent = all ten answered, at most one switch and only from A to B, and
## B in the last row (where B pays 3.85 for sure)
consistent <- apply(hl, 1, function(x) {
  if (any(is.na(x) | !(x %in% c("A", "B")))) return(FALSE)
  b <- as.integer(x == "B")
  all(diff(b) >= 0) & b[10] == 1
})

df <- df %>%
  mutate(n_b = rowSums(hl == "B", na.rm = TRUE),
         consistent = consistent,
         soep = case_when(risk_self == "not at all willing to take risks" ~ 0,
                          risk_self == "very willing to take risks" ~ 10,
                          TRUE ~ suppressWarnings(as.numeric(risk_self))))

stopifnot(nrow(df) == 1074, all(df$soep %in% 0:10 | is.na(df$soep)))

source("Data/inconsistent_rows.R")
complete <- apply(hl, 1, function(x) !any(is.na(x) | !(x %in% c("A", "B"))))
df <- df %>%
  mutate(points = lapply(seq_len(nrow(hl)), function(i)
           if (complete[i]) switch_points(as.numeric(hl[i, ] == "B")) else integer(0))) %>%
  transmute(subject,
            task = if_else(complete, "HL", "quest_only"),
            inconsistent = as.numeric(complete & !consistent),
            points,
            ## for the quest_only rows generate_data_for_app.R moves choice
            ## into soep, so it carries the SOEP answer there
            choice = if_else(complete, NA_real_, soep),
            soep = if_else(complete, soep, NA_real_),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            age = recode(age_bracket, "18 to 24" = 21, "25 to 34" = 29.5,
                         "35 to 44" = 39.5, "45 to 54" = 49.5, "55 to 64" = 59.5,
                         "65 or above" = 69.5, .default = NA_real_),
            bibkey = "Krull2024",
            paper = "Krull et al. 2024") %>%
  filter(!(task == "quest_only" & is.na(choice)))
df <- bind_rows(
  df %>% filter(task == "HL") %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k)),
  df %>% filter(task == "quest_only") %>% select(-points)) %>%
  arrange(match(subject, unique(subject)))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
## only the HL rows go through get_r; the quest_only rows have no task
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice, inconsistent), function(b, t, c, i)
  if (t == "HL" && i == 0) get_r(b, t, c) else NA_real_))

## online, United States
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Krull_et_al_2024/formatted_dataset.csv")
