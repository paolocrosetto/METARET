#### Harrison, G. W. & Rutström, E. E. (2008). Risk aversion in the laboratory.
#### In J. C. Cox & G. W. Harrison (eds.), Risk Aversion in Experiments,
#### Research in Experimental Economics 12, 41-196. https://doi.org/10.1016/S0193-2306(08)00003-3
#### Data: CEAR, https://cear.gsu.edu/files/2016/07/Risk-Aversion-in-the-Laboratory.zip
#### (Glenn Harrison agreed to the inclusion in METARET, e-mail to Paolo Crosetto, 20.10.2026)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The zip collects data of several studies, one folder each. This script uses
## only the authors' own comparison of methods (folder Methods, HLdata.dta):
## 53 subjects, each doing a Holt-Laury list and a Binswanger choice (order
## randomised, hl_first). The other folders hold data of separately published
## papers (Holt and Laury 2002 is already in METARET; Gneezy and Potters 1997,
## Haigh and List 2005, Holt and Laury 2005 are handled on their own).
##  - HL: Holt-Laury list times 10 (A 20/16, B 38.50/1 dollars).
##    decision_x: 1 = safe (A). numB = number of risky choices.
##  - Binswanger (Binswanger Replication Instructions.pdf): one of eight 50/50
##    options a-h: 10/10, 19/9, 24/8, 25/7, 30/6, 32/4, 38/2, 40/0 dollars.
##    choice = 1 (a) ... 8 (h).
## No demographics in this file; subjects are UCF students (Orlando, US).
df <- read_csv("Data/Harrison_Rutstrom_2008/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            HL = numB,
            EG = match(binswanger, letters[1:8]),
            country = "United States",
            city = "Orlando") %>% 
  pivot_longer(c(HL, EG), names_to = "task", values_to = "choice") %>% 
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "HarrisonRutstrom2008",
         paper = "Harrison and Rutström 2008")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Harrison_Rutstrom_2008/formatted_dataset.csv")
