#### Zheng, J. & Zhou, L. (2025). Too risky to hedge: An experiment on narrow
#### bracketing. Experimental Economics, 28(1), 128-154.
#### https://doi.org/10.1017/eec.2025.1
#### Data: figshare 10.6084/m9.figshare.28169810.v2 (replication/data.xlsx);
#### the lists are in Instructions EN.pdf and Table 2 of the paper

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 176 subjects in the TSE-econlab, Toulouse School of Economics, 20 sessions in
## March 2019 (the pilot session is not in the file). With an endowment of
## 10 EUR they priced four lotteries in each of three tasks; one of 18
## situations was paid. Only the investment task (INV) is a plain risk task:
## in row k (k = 1 ... 20) the subject either buys a lottery ticket at
## 0.50 k EUR or keeps the 10 EUR. Lottery R2, 10 EUR with probability 1/2,
## else 0, is used, the 50/50 format of the other CEPL papers on the site; R1
## and R3 (30% and 70%), R4 (8 or 2 EUR) and the two insurance tasks are not.
## SR2 is the first row where the ticket was not bought, so the certainty
## equivalent of the lottery lies between 0.50 (SR2 - 1) and 0.50 SR2 EUR. The
## switch was enforced by the software. Three subjects bought the ticket even at
## 10 EUR (SR2 = 21), which is dominated, and have no task row.
## Q_Risk is the general willingness to take risks (Dohmen et al. 2011), 0-10,
## answered by all; it goes in soep, and the three above enter as quest_only.
## The authors' files also hold religion, income, nationality, local IP
## addresses and oTree codes and are not copied; original_dataset.csv keeps
## session, treatment order, the four switching rows of the investment task,
## the risk question, sex and age, and subjects are row numbers.
df <- read_csv("Data/Zheng_Zhou_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 176, all(df$SR2 %in% 1:21), all(!is.na(df$q_risk)))

df <- df %>%
  mutate(dominated = SR2 == 21) %>%
  transmute(subject,
            task = if_else(dominated, "quest_only", "CEPL"),
            ## choice is what generate_data_for_app.R moves into soep for quest_only
            choice = if_else(dominated, q_risk, SR2),
            soep = if_else(dominated, NA_real_, q_risk),
            age,
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0),
            country = "France",
            city = "Toulouse",
            bibkey = "Zheng2025",
            paper = "Zheng and Zhou 2025")

stopifnot(sum(df$task == "CEPL") == 173)

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '43.6047'
df$longitude = '1.4442'

source("Data/generate_r.R")
cepl <- df$task == "CEPL"
df$r <- NA_real_
df$r[cepl] <- purrr::pmap_dbl(list(df$bibkey[cepl], df$task[cepl], df$choice[cepl]), get_r)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zheng_Zhou_2025/formatted_dataset.csv")
