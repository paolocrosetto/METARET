#### Shachat, J., Walker, M. J. & Wei, L. (2024). Contingent payments in
#### procurement interactions: Experimental evidence.
#### European Economic Review, 170, 104886.
#### https://doi.org/10.1016/j.euroecorev.2024.104886
#### Data: https://osf.io/at672 (Data/data_N and Buyer_Expt/Data/data_B)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Procurement auctions with contingent payments, oTree, run "at the behavioral
## and experimental laboratory of a large competitive university in mainland
## China" (ethics approval from the Economics and Management School of Wuhan
## University). The auctions are not a risk elicitation, so the rows are
## 'quest_only' and generate_data_for_app.R moves `choice` into `soep`.
##
## The post-experiment questionnaire (data dictionary of the package) asks
## "Are you generally a person who is fully willing to take risks or do you try
## to avoid taking risks?" -- the SOEP general item, "an eleven-point scale" in
## the paper -- and "How would you rate your willingness to take risks in
## financial matters?", which goes to soep_financial. Both are stored as 1 ... 9
## with the end points as their labels: "completely unwilling to take risks" =
## 0 and "completely willing to take risks" = 10.
##
## Two sets of subjects, all different people:
##  - the three main treatments (data_N, 288 subjects, raw files dated October
##    2022 and May 2023), the sample of the paper ("We recruited a total of 288
##    subjects"; 56.9% female, which the data reproduce: 164 of 288);
##  - the three treatments with an active buyer of Online Appendix A.6
##    (data_B, 432 subjects, raw files dated November-December 2021).
## gender: Female 1, Male 0, "Prefer not to say" NA. Age in years.
df <- read_csv("Data/Shachat_et_al_2024/original_dataset.csv", show_col_types = FALSE)

to_num <- function(x) case_when(x == "completely unwilling to take risks" ~ 0,
                                x == "completely willing to take risks" ~ 10,
                                TRUE ~ suppressWarnings(as.numeric(x)))

df <- df %>%
  mutate(soep = to_num(risk_general), soep_fin = to_num(risk_financial))

stopifnot(nrow(df) == 720, all(df$soep %in% 0:10), all(df$soep_fin %in% 0:10),
          sum(df$gender[grepl("^main", df$part)] == "Female") == 164)

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = soep,
            soep_financial = soep_fin,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0, TRUE ~ NA_real_),
            age,
            bibkey = "Shachat2024",
            paper = "Shachat et al. 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## The map shows only the country, so no coordinates
df$country = 'China'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Shachat_et_al_2024/formatted_dataset.csv")
