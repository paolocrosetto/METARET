#### Drouvelis, M. & Pearce, G. (2025). Intelligence and strategy choice in
#### indefinitely repeated prisoner's dilemma games: A replication of Proto,
#### Rustichini & Sofianos (2022). European Economic Review, 178, 105075.
#### https://doi.org/10.1016/j.euroecorev.2025.105075
#### Data: Zenodo, https://doi.org/10.5281/zenodo.15462528 (cleandata.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Close replication of Proto et al. (2022), run at the Birmingham Experimental
## Economics Laboratory (BEEL), University of Birmingham, in zTree, recruited
## through SONA: 26 sessions of ten, 260 subjects, aged 17 to 45 (mean 22).
## Before the repeated prisoner's dilemmas subjects did a Raven test, the
## equality equivalence test and, in the paper's words, "a Holt and Laury (2002)
## multiple price list to measure risk preferences". One task was paid.
##
## WHICH COLUMNS ARE THE PRICE LIST. cleandata.dta has choice1 ... choice20 with
## no labels. The share choosing 1 runs
##   0.82 0.73 0.12 0.08 0.06 0.96 0.95 0.88 0.52 0.33 | 0.05 0.05 0.07 0.09
##   0.25 0.42 0.58 0.81 0.87 0.95
## The last ten rise monotonically from 0.05 to 0.95, which is what a price list
## looks like as the probability of the good outcome increases, while the first
## ten do not. So choice11 ... choice20 is the Holt-Laury list and 1 is the
## risky side; the earlier columns belong to the equality equivalence test.
##
## THE AUTHORS' OWN risk VARIABLE IS OFF BY ONE AND IS NOT USED. Their do file
## builds it as a count of safe choices over choice10 ... choice20, that is over
## ELEVEN columns, one of which (choice10, chosen by 33% of subjects) is not
## part of the price list at all. Among the 212 subjects who switch once in the
## ten real rows, risk equals 11 minus the number of risky choices for 208 of
## them - exactly one too many. The count here is taken from the raw rows
## instead. authors_risk is kept in original_dataset.csv for reference.
##
## Kept: the 212 subjects whose ten answers switch at most once; the other 48
## switch repeatedly, so their count is not a switching point.
## choice = number of risky choices.
## gender: NOT USED. The variable holds 1 and 2, while the do file comments say
## "1 male, 0 female", so the coding cannot be resolved from the package and the
## paper does not report the gender split.
df <- read_csv("Data/Drouvelis_Pearce_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 260)
hl <- df %>% select(choice11:choice20) %>% as.matrix()
stopifnot(all(hl %in% c(0, 1)))
switches <- rowSums(hl[, -1] != hl[, -10])

df <- df %>%
  mutate(switches = switches, n_risky = rowSums(hl == 1)) %>%
  filter(switches <= 1) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = n_risky,
            age,
            gender = NA_real_,
            country = "United Kingdom")
stopifnot(nrow(df) == 212)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "DrouvelisPearce2025",
         paper = "Drouvelis and Pearce 2025")

## Birmingham Experimental Economics Laboratory
df$city = 'Birmingham'
df$lattitude = '52.4508'
df$longitude = '-1.9305'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Drouvelis_Pearce_2025/formatted_dataset.csv")
