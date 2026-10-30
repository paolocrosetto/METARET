#### Holt, C. A. & Laury, S. K. (2005). Risk aversion and incentive effects: New data
#### without order effects. American Economic Review, 95(3), 902-912.
#### https://doi.org/10.1257/0002828054201459
#### Data: from the collection of Harrison and Rutström (2008), "Risk Aversion in the
#### Laboratory" (CEAR, https://cear.gsu.edu/files/2016/07/Risk-Aversion-in-the-Laboratory.zip)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## HLreply.dta (folder HL_Reply): the four single-choice ("unordered") treatments
## of the 2004 experiment at the University of Virginia, one Holt-Laury menu per
## subject: 1x or 20x payoffs, real or hypothetical (48 + 48 real, 36 + 36
## hypothetical). The ordered 1x-then-20x treatment (48 subjects) is not in this
## file. reverse = left/right position of the safe option (pooled in the paper).
## d1-d10: 1 = safe, 0 = risky (mean safe choices 5.7 at 1x real and 6.7 at
## 20x real, as in Table 1 of the paper).
## Only the real-payment treatments are kept; choice = number of risky choices
## (11 - the row where B starts). Inconsistent (counted until 29.10.2026): 3
## subjects switch more than once and 1 keeps the safe option in row 10, where
## the risky one pays more for sure; they are kept for the download only, with
## inconsistent = 1 and one row per switch to the risky option
## (Data/inconsistent_rows.R).
## Holt and Laury (2002) is already in METARET as a separate paper (other subjects).
## No demographics in the file.
df <- read_csv("Data/Holt_Laury_2005/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
df <- df %>% filter(real == 1)
B <- 1 - as.matrix(select(df, d1:d10))
df <- df %>% 
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  transmute(subject = row_number(),
            task = "HL",
            points, inconsistent,
            country = "United States",
            city = "Charlottesville") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(n_distinct(df$subject[df$inconsistent == 1]) == 4)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Holt2005",
         paper = "Holt and Laury 2005")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Holt_Laury_2005/formatted_dataset.csv")
