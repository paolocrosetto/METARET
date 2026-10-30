#### Crosetto and Filippin, "The Bomb Risk Elicitation Task", JRU 2013

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_dta("Data/Crosetto_Filippin_Experimental_Economics_2016/original_dataset.dta") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(subject, gender, age, treatment, perc, pump, eg, cgptotal, safechoices, inconsistent, soep, starts_with("do")) %>% 
  select(-dominated)

# gathering and renaming each different chocie variable 'choice'
df <- df %>% 
  gather(key, choice, -subject, -gender, -age, -inconsistent, -soep, -starts_with("do"), -treatment) %>% 
  filter(!is.na(choice))

# adding task
df <- df %>% 
  mutate(task = case_when(treatment == "bret" ~ "BRET",
                          treatment == "cgp" ~ "IG",
                          treatment == "eg" ~ "EG",
                          treatment == "hl" ~ "HL",
                          treatment == "balloon" ~ "BART"))

# removing bret as it is duplicate of the one in JRU
df <- df %>% 
  filter(treatment != "bret")

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER
df <- df %>% 
  mutate(treatment = " ")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Crosetto2016",
         paper = "Crosetto and Filippin EXEC 2016")


# coding choices in HL as number of risky choices
df <- df %>% 
  mutate(choice = if_else(task == "HL", 10-choice, choice))

## Inconsistent HL answers (29.10.2026). The authors flag 15 subjects who switch
## more than once (inconsistent; safechoices is missing for them, so the
## gather above dropped them) and 13 who keep A in row 10, where B pays the
## high prize for sure (dominated; 5 of them switch once and were counted until
## now). The row answers hl1-hl10 (1 = B) give the same 20 subjects. They are
## kept for the download only, with inconsistent = 1 and one row per switch to
## B (Data/inconsistent_rows.R); the other tasks have no inconsistent answers.
source("Data/inconsistent_rows.R")
raw_hl <- read_dta("Data/Crosetto_Filippin_Experimental_Economics_2016/original_dataset.dta") %>%
  as_factor() %>%
  filter(treatment == "hl")
B <- sapply(paste0("hl", 1:10), function(v) as.numeric(as.character(raw_hl[[v]])))
hl_rows <- raw_hl %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inc = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  filter(inc == 1) %>%
  transmute(subject, gender, age, soep, across(starts_with("do") & !any_of("dominated")),
            points, inconsistent = inc, treatment = " ", key = "safechoices",
            task = "HL", bibkey = "Crosetto2016", paper = "Crosetto and Filippin EXEC 2016") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(n_distinct(hl_rows$subject) == 20)
## the 5 single switchers among them are already in df: drop them there, and
## add every inconsistent row at the end, so the r draws of the rows before
## stay as they were
df <- df %>%
  mutate(inconsistent = 0) %>%
  filter(!(task == "HL" & subject %in% hl_rows$subject)) %>%
  bind_rows(hl_rows)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)



# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())
df$country = 'Germany'
df$city = 'Jena'
# Writing to file
df %>% write_csv("Data/Crosetto_Filippin_Experimental_Economics_2016/formatted_dataset.csv")
