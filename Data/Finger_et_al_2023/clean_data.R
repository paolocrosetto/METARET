#### Finger, R., Wuepper, D. & McCallum, C. (2023). The (in)stability of farmer
#### risk preferences.
#### Journal of Agricultural Economics, 74(1), 155-167. https://doi.org/10.1111/1477-9552.12496
#### Data: ETH Research Collection, https://www.research-collection.ethz.ch/handle/20.500.11850/588689
#### (grapedata, downloaded by hand; it was saved as RTF and converted back to CSV)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv holds the 210 Swiss grape growers who answered all ten
## rows of the Holt-Laury list in the 2018 online survey (grapedata.csv, year
## 2018), with canton, gender and year of birth. The fruit growers of the paper
## are in a separate dataset, not used here.
## Holt-Laury list, framed as a choice between two insecticides (Knapp et al.
## 2019, Data in Brief 24, 103920, figure 1): in scenario k insecticide A pays
## 105 or 84 CHF and B pays 200 or 6 CHF, the high return with probability k/10.
## 10% of participants were paid one random scenario. scenario_k: "A1" = A,
## "A2" = B; choice = number of B choices.
## As in the paper (footnote 5), subjects with multiple switches or no switch are
## removed: 23 switch more than once and 26 never switch (13 always A, 13 always
## B), leaving 161 single switchers (the paper reports 17 removals for its pooled
## fruit and grape sample).
## gender: "F" = 1, "M" = 0. Age = 2018 - year of birth (implausible years set
## to NA).
df <- read_csv("Data/Finger_et_al_2023/original_dataset.csv", show_col_types = FALSE)

b <- as.matrix(select(df, starts_with("scenario_"))) == "A2"
switches <- rowSums(b[, -1] != b[, -10])

df <- df %>%
  mutate(choice = rowSums(b), switches = switches) %>%
  filter(switches == 1) %>%
  transmute(subject,
            task = "HL",
            choice,
            age = if_else(year_b >= 1920 & year_b <= 2000, 2018 - year_b, NA_real_),
            gender = case_when(gender == "F" ~ 1, gender == "M" ~ 0, TRUE ~ NA_real_),
            country = "Switzerland")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Finger2023",
         paper = "Finger et al. 2023")

## online survey, and the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Finger_et_al_2023/formatted_dataset.csv")
