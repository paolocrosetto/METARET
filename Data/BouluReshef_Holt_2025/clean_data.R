#### Boulu-Reshef, B. & Holt, C. A. (2025).
#### Inventory management with carryover in the laboratory: going beyond the
#### news vendor.
#### Experimental Economics, 28(3), 782-803.
#### https://doi.org/10.1017/eec.2025.10026
#### Data: Zenodo 10.5281/zenodo.15775268 (Reproducibility package.zip)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The inventory game itself is not a risk elicitation, but every session was
## preceded by a Veconlab lottery-choice menu run as its own session. The
## package's DATA_INVENTORY.dta keeps only a summary of it (the columns hl and
## normhl, "Normalized Holt and Laury risk aversion measure"), so the row-by-
## row answers were taken from RAW DATA.xlsx instead, where each risk session
## has its own sheet with the menu printed above the choices.
##
## original_dataset.csv is that extract: one row per subject with the session,
## the four payoffs of its menu, and the ten choices as a string of S and R.
## 72 subjects, which matches the 72 in DATA_INVENTORY.
##
## The participants' real names appear in the raw sheets and were deliberately
## left out; the file keeps only the session and the within-session number.
df <- read_csv("Data/BouluReshef_Holt_2025/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 72)

## TWO DIFFERENT MENUS, so two task labels. Four sessions used $4.00 or $3.20
## against $7.70 or $0.20 and one used $8.00 or $6.40 against $15.40 or $0.40
## -- Holt and Laury's menu at twice and four times scale, 60 subjects in all,
## labelled HL. The sixth session put a sure $6.00 against $12.00 or $2.00,
## which is a sure amount against a lottery and so CEPL, 12 subjects. The
## bounds for each are in the BouluReshef2025 block of generate_r.R.
##
## Three subjects switch more than once: they are kept for the download only,
## with inconsistent = 1 and one row per switch to the risky side
## (Data/inconsistent_rows.R). One sits at a corner (R in every row, not
## dominated) and is in the statistics. That leaves 69 there.
##
## No demographics are published: DATA_INVENTORY has no age or gender column
## and the raw sheets carry only names.
source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(strsplit(choices, ""), function(x) switch_points(as.numeric(x == "R"))),
         inconsistent = as.numeric(switches > 1)) %>%
  transmute(subject = row_number(),
            task = if_else(safe_hi == safe_lo, "CEPL", "HL"),
            points, inconsistent,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "BouluReshef2025",
            paper = "Boulu-Reshef and Holt 2025")
stopifnot(sum(df$inconsistent == 0) == 69)
## choice = number of R choices = 11 - the row where R starts
df <- df %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## Veconlab, University of Virginia.
df$country = 'United States'
df$city = 'Charlottesville'
df$lattitude = '38.0336'
df$longitude = '-78.5080'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/BouluReshef_Holt_2025/formatted_dataset.csv")
