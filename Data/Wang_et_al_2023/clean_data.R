#### Wang, T.-M., Heine, F. & van Witteloostuijn, A. (2023). Pro-social risk-taking
#### and intergroup conflict: A volunteer's dilemma experiment.
#### Games and Economic Behavior, 140, 363-379. https://doi.org/10.1016/j.geb.2023.04.003
#### Data: DANS, https://doi.org/10.17026/dans-zer-sudz (downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The DANS package holds VoD_GEB.dat, a fixed-width text export of the authors'
## Stata file with no column layout, and VoD_GEB.do. The ten Holt-Laury answers
## (Choice1 ... Choice10 in the do-file: 1 = safe option A, 2 = risky option B)
## were located by position: characters 251-260 are the only ten-character block
## made of 1s and 2s on all 126 lines. Check: the mean number of safe choices is
## 4.722, the 4.72 reported in the paper (Table 2). original_dataset.csv keeps only
## a row number, the first digit of the subject id (the session) and these ten
## answers; the IP addresses, geolocation and other fields of the .dat file were
## not copied. age: characters 129-130 are the only two-digit field whose
## distribution matches the paper ("22.6 (s.d. = 3.20) years old"): mean 22.56,
## s.d. 3.20, range 17-40; it is copied as `age`. Gender is in the authors' file
## (the do-file tabulates by Gender) but no single column of the .dat matches
## the reported 53.4% female, so it is left missing.
## 126 students at CentERlab, Tilburg University, 2018, z-Tree.
## Holt-Laury list (instructions, Part 2): option A pays 3 or 2 EUR, option B pays
## 5 or 1 EUR, the high outcome with probability k/10 in row k -- not the standard
## table. choice = number of B choices.
df <- read_csv("Data/Wang_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = rowSums(across(starts_with("choice")) == 2),
            age,
            country = "Netherlands",
            city = "Tilburg")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Wang2023",
         paper = "Wang et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Wang_et_al_2023/formatted_dataset.csv")
