#### Corgnet, B. & Hernan-Gonzalez, R. (2019). Revisiting the trade-off between
#### risk and incentives: The shocking effect of random shocks? Management
#### Science, 65(3), 1096-1114. https://doi.org/10.1287/mnsc.2017.2914
#### Data: replication package "Data and codes" (DATA.dta, Do file.do)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Principal-agent experiment at the Economic Science Institute, Chapman
## University: 174 subjects, the first 10 sessions "in the spring of 2014" and
## six more "two years later" at the same lab. Risk attitudes were elicited at
## the end with the Holt and Laury (2002) list, one of the ten rows paid.
##
## DATA.dta is one row per subject and period; original_dataset.csv keeps one
## row per subject. From the notes of the do-file: ownswitch is the row at
## which the subject first switches from A to B, numchanges the number of
## switches, stayinbed flags subjects the authors treat as not switching. The
## paper's own sample for risk (do-file, Table 3) is numchanges == 1 and
## stayinbed == 0; the same filter is used here, which also removes the 13
## without a switch row. 152 remain. The 6 with several switches (numchanges
## 3-5) are kept for the download only, with inconsistent = 1 and one row with
## their first switch (ownswitch) as choice (Data/inconsistent_rows.R); the
## file has no row-by-row answers. The 16 flagged stayinbed or without a
## switch row stay out: whether they took A or B throughout, and so whether the
## answer is dominated, cannot be told. With the first B in row s the subject made
## 11 - s B choices, the convention of the shared standard-HL block of
## generate_r.R. The package has no age or gender.
df <- read_csv("Data/Corgnet_HernanGonzalez_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 174)

df <- df %>%
  filter(stayinbed == 0, !is.na(ownswitch)) %>%
  mutate(inconsistent = as.numeric(numchanges > 1))

stopifnot(sum(df$inconsistent == 0) == 152, sum(df$inconsistent) == 6,
          all(df$ownswitch[df$inconsistent == 0] %in% 2:10))

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = 11 - ownswitch,
            inconsistent,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Corgnet2019",
            paper = "Corgnet and Hernan-Gonzalez 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## Chapman University, Orange (California); the map shows only the country
df$country = 'United States'
df$city = 'Orange'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Corgnet_HernanGonzalez_2019/formatted_dataset.csv")
