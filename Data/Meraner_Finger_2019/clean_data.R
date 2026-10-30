#### Meraner, M. & Finger, R. (2019). Risk perceptions, preferences and management
#### strategies: evidence from a case study using German livestock farmers.
#### Journal of Risk Research. https://doi.org/10.1080/13669877.2017.1351476
#### Data: the companion Data in Brief article, "Data on German farmers risk
#### preference, perception and management strategies" (mmc2.csv = mmc3.xlsx, the
#### data; mmc4.docx, the codebook; mmc5.pdf, the questionnaire), kept in
#### raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Paper-and-pencil survey of specialized livestock farmers in North
## Rhine-Westphalia, "in December 2015 and January 2016", sent through the local
## extension service to 256 farmers "located mainly in the region of Muenster";
## 64 answered, one row each.
##
## Task: Holt and Laury (2002), framed as an agricultural investment. Option A
## pays 100,000 or 80,000 tokens, option B 192,500 or 5,000, the high return with
## probability k/10 in row k; tokens are converted back by 1,000, so 100/80 vs
## 192.5/5 euro, the Holt-Laury table times 50, which keeps its CRRA intervals.
## "10% of all participants are selected for real payouts based on their
## choices." HLk: 1 = A, 0 = B; choice = number of B choices, as for the other HL
## papers. 58 farmers switched once. The 5 who switched more than once are kept
## for the download only, with inconsistent = 1 and one row per switch to B
## (Data/inconsistent_rows.R); the one who answered only the first two rows has
## no task answer.
##
## Questionnaire: "How do you see yourself personally: Are you generally a
## risk-averse person, or do you try to avoid risks? (from 0 = 'risk averse' to 10
## = 'very risk loving')", SA, the general question of Dohmen et al. (2011). It
## goes into soep; farmers without a task answer keep it as questionnaire-only
## rows. One farmer left it empty.
##
## gender: 1 = male, 0 = female (codebook); age = age in 2016.
df <- read_csv("Data/Meraner_Finger_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 64)

hl <- df %>% select(num_range("HL", 1:10)) %>% as.matrix()
n_b <- rowSums(1 - hl)
single <- sapply(seq_len(nrow(hl)), function(i)
  !anyNA(hl[i, ]) && identical(unname(1 - hl[i, ]), c(rep(0, 10 - n_b[i]), rep(1, n_b[i]))))
has_task <- single & n_b >= 1
stopifnot(sum(single) == 58, sum(has_task) == 58)

source("Data/inconsistent_rows.R")
complete <- !apply(hl, 1, anyNA)
stopifnot(sum(complete & !has_task) == 5)
df <- df %>%
  mutate(subject = id,
         task = if_else(complete, "HL", "quest_only"),
         inconsistent = as.numeric(complete & !has_task),
         points = lapply(seq_len(nrow(hl)), function(i)
           if (complete[i]) switch_points(1 - hl[i, ]) else integer(0)),
         ## for questionnaire-only rows generate_data_for_app.R moves
         ## choice into soep
         choice = if_else(complete, NA_real_, SA),
         soep = if_else(complete, SA, NA_real_)) %>%
  filter(task == "HL" | !is.na(choice)) %>%
  transmute(subject, task, choice, soep, points, inconsistent,
            gender = if_else(gender == 1, 0, 1),
            age,
            country = "Germany",
            city = "Münster")
## choice = number of B choices = 11 - the row where B starts; the
## questionnaire-only row keeps its SOEP answer in choice
df <- bind_rows(
  df %>% filter(task == "HL") %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k)),
  df %>% filter(task == "quest_only") %>% select(-points)) %>%
  arrange(subject)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Meraner2019",
         paper = "Meraner and Finger 2019")

## the map is drawn by country; the coordinates are those of Münster, the centre
## of the surveyed region
df$lattitude = '51.9607'
df$longitude = '7.6261'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
## (the questionnaire-only rows have no task, so no r)
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice, inconsistent), function(b, t, c, i)
  if (t == "quest_only" || i == 1) NA_real_ else get_r(b, t, c)))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Meraner_Finger_2019/formatted_dataset.csv")
