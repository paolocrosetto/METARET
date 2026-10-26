#### Mill, W. & Schneider, C. (2026). The bright side of tax evasion.
#### Economic Journal (version of 7 April 2026; SSRN working paper 4558424, 2023).
#### Data: replication package sent by the author (W. Mill), October 2026.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset_anon.csv: the risk-elicitation survey of the replication package
## (RiskElicitationExperiment.csv, Prolific, US, April-May 2025), reduced to the
## variables used here. IP addresses, location, Prolific IDs and browser data were
## removed. authors_sample = 1 for the rows the authors keep (consent given, US IP
## without VPN, Progress > 93, attention check passed), computed from the original
## file before those columns were dropped. Three IDs appear twice among them: their
## first attempt is kept.
df <- read_csv("Data/Mill_Schneider_2026/original_dataset_anon.csv", show_col_types = FALSE) %>% 
  filter(authors_sample == 1) %>% 
  arrange(anonymizedID, StartDate) %>% 
  distinct(anonymizedID, .keep_all = TRUE) %>% 
  mutate(subject = row_number())

## Eckel-Grossman, gain domain: six 50/50 gambles in points
##   A 528/528, B 432/720, C 336/912, D 240/1104, E 144/1296, F 0/1440
## choice = rank of the gamble (A = 1), as in the authors' code.
## BRET: static, 100 boxes; bret_risk = number of boxes collected.
## The loss-domain Eckel-Grossman (EckelGrossmann_lose) would be METARET's EG_loss;
## it is left out until the rule for gambles with losses is settled (see Babin et al.).
## The certainty equivalents and the prudence / temperance tasks have no counterpart
## in METARET.
## Gender (survey item): 1 male, 2 female (matches the Prolific records).
eg_levels <- c("528 points</b> if you lose or <b>528",
               "432 points</b> if you lose or <b>720",
               "336 points</b> if you lose or <b>912",
               "240 points</b> if you lose or <b>1104",
               "144 points</b> if you lose or <b>1296",
               "0 points</b> if you lose or <b>1440")

df <- df %>% 
  mutate(EG = map_dbl(EckelGrossmann_win, ~ {
           hit <- which(str_detect(.x, fixed(eg_levels)))
           if (length(hit) == 1) hit else NA_real_ }),
         BRET = as.numeric(bret_risk),
         age = as.numeric(Age),
         ## 1 - female, 0 - male
         gender = case_when(Gender == 2 ~ 1, Gender == 1 ~ 0, TRUE ~ NA_real_)) %>% 
  select(subject, EG, BRET, age, gender) %>% 
  pivot_longer(c(EG, BRET), names_to = "task", values_to = "choice") %>% 
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Mill2026",
         paper = "Mill and Schneider 2026")

## online (Prolific), US residents
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mill_Schneider_2026/formatted_dataset.csv")
