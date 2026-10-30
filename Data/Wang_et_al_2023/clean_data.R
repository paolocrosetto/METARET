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
## s.d. 3.20, range 17-40; it is copied as `age`. male: character 131, right
## after age, is the authors' Gender (male = 1, as in the paper's regressions):
## 0 for 68, 1 for 57 and blank for one participant, who wrote "Airplane" in
## the free-text field that follows (characters 132-139) -- the "third gender"
## the paper drops (footnote 9). Check against footnote 8: in session 7 the 8
## people coded 1 answered the Dutch-language version in 75% of cases ("most of
## them are Dutch (75%...)"). 68 of 126 is 54.0% female, against 53.4% in the
## paper. The third-gender answer is left missing.
## 126 students at CentERlab, Tilburg University, 2018, z-Tree.
## Holt-Laury list (instructions, Part 2): option A pays 3 or 2 EUR, option B pays
## 5 or 1 EUR, the high outcome with probability k/10 in row k -- not the standard
## table. choice = number of B choices. Nobody switches more than once; the 5
## who keep A in row 10, where B pays 5 for sure against 3 (dominated; counted
## until 29.10.2026), are kept for the download only, with inconsistent = 1
## (Data/inconsistent_rows.R).
df <- read_csv("Data/Wang_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = rowSums(across(starts_with("choice")) == 2),
            inconsistent = as.numeric(choice10 == 1),
            age,
            gender = 1 - male,
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
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Wang_et_al_2023/formatted_dataset.csv")
