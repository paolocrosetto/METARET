#### Chen, Y., Jiang, M. & Krupka, E. L. (2019). Hunger and the gender gap.
#### Experimental Economics, 22(4), 885-917.
#### https://doi.org/10.1007/s10683-018-9589-9
#### Data: openICPSR 120065 (Hunger_data.dta); the instructions are in the
#### Springer electronic supplementary material (Online Appendix A, Part III)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 201 adults (of 204 who took part) at a health-screening clinic in Shanghai,
## recruited after their annual physical exam either fasting (hungry) or after
## the clinic breakfast (sated). Paper-and-pencil Holt-Laury list: A pays 30 or
## 17 CNY, B pays 40 or 1 CNY, the high prize with probability k/10 in row k
## (a ten-sided die), one row paid. r1-r10: 1 = A (left), 2 = B. At the end,
## "Do you think you are someone who is willing to take risks, or someone who is
## trying to minimize risks?", 0-10 (survey_r).
## 128 subjects switch once from A to B; the other 73 (36.3%, as in the paper)
## switch more than once or keep A in row 10. Those of them with a survey answer
## (49) enter as quest_only; 24 have neither and are dropped. 66 subjects in all
## have no survey answer (the closing questions differed across subject ids).
## The authors' file holds the subjects' medical records (blood tests, blood
## pressure, tumour markers, height, weight) and the clinic's client id, and is
## not copied; original_dataset.csv keeps treatment, task order, session, the
## ten choices, the survey answer, sex and age, and subjects are row numbers.
df <- read_csv("Data/Chen_Jiang_Krupka_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 201)

hl <- df %>% select(r1:r10) %>% as.matrix()
pattern <- apply(hl, 1, paste, collapse = "")
single <- str_detect(pattern, "^1*2+$")
stopifnot(sum(single) == 128)

keep <- single | !is.na(df$survey_r)
df <- df[keep, ]; hl <- hl[keep, ]; single <- single[keep]
stopifnot(nrow(df) == 177)

df <- df %>%
  mutate(nB = rowSums(hl == 2), single = single) %>%
  transmute(subject,
            task = if_else(single, "HL", "quest_only"),
            ## choice is what generate_data_for_app.R moves into soep for quest_only
            choice = if_else(single, nB, survey_r),
            soep = if_else(single, survey_r, NA_real_),
            age,
            gender = case_when(gender == "f" ~ 1, gender == "m" ~ 0),
            country = "China",
            city = "Shanghai",
            bibkey = "Chen2019",
            paper = "Chen et al. 2019")

## the map is drawn by country; the coordinates are those of the city
df$lattitude = '31.2304'
df$longitude = '121.4737'

source("Data/generate_r.R")
hlrow <- df$task == "HL"
df$r <- NA_real_
df$r[hlrow] <- purrr::pmap_dbl(list(df$bibkey[hlrow], df$task[hlrow], df$choice[hlrow]), get_r)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chen_Jiang_Krupka_2019/formatted_dataset.csv")
