#### Björkman Nyqvist, M., Corno, L., de Walque, D. & Svensson, J. (2018).
#### Incentivizing Safer Sexual Behavior: Evidence from a Lottery Experiment
#### on HIV Prevention.
#### American Economic Journal: Applied Economics, 10(3), 287-314.
#### https://doi.org/10.1257/app.20160469
#### Data: openICPSR 10.3886/E113707V1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## A two-year randomised trial on HIV prevention in 29 rural and peri-urban
## villages across five districts of Lesotho, 3029 participants. At baseline
## everyone faced a price list: alternative k offered a sure 25*(k-1) maloti,
## so 0, 25, ... , 350, against a 50/50 lottery paying 500 or nothing. The
## package ships the menu and the implied bounds as crra_data.xlsx, copied
## into this folder.
df <- read_dta("Data/BjorkmanNyqvist_et_al_2018/original_dataset.dta")
stopifnot(nrow(df) == 3029)

## SAMPLE. riskcoefbas, the authors' risk coefficient, exists for 1703
## subjects, and that is the N their Table 1 reports for both risk measures.
## The remaining 1236 who answered never switched inside the menu: 1118 took
## the lottery in every row, so their certainty equivalent is only known to
## exceed 350, and 118 took the sure amount in every row, including the first,
## where the sure amount is nothing at all and the choice is dominated. The
## authors leave both out of the coefficient and bring them back only as a
## robustness check on the binary indicator, writing that such answers "are
## more likely to be a product of lack of comprehension of the MPL design".
## The 1118 are left out here for the same reason: putting 1118 subjects on one
## censored point would plant a spike at the risk-loving end of this paper's
## distribution. The 118 made a dominated choice: they are kept for the
## download only, with inconsistent = 1 (Data/inconsistent_rows.R) and
## choice = 1, the sure amount taken from the first alternative on; they are
## the subjects with no coefficient and riskloverbas_nomiss == 0. 90 more have
## no answer at all.
##
## RECOVERING THE SWITCH POINT. The file keeps no row-by-row answers, only
## riskcoefbas, but that is enough: the spreadsheet assigns each switch point
## the arithmetic midpoint of the two RRA bounds it implies, so the coefficient
## takes exactly fourteen values, one per alternative from 2 to 15, and the
## mapping back is one to one. The fourteen midpoints are reconstructed here
## from the same formula and matched to the nearest stored value; the largest
## gap is then 0.0007, which is the rounding of the single-precision column.
## The one exception is the first category: switching already at a sure 25
## leaves the coefficient unbounded above, so there is no midpoint to take and
## the spreadsheet simply writes the bound, 0.77, which is used here too.
rho <- 1 - log(0.5) / (log(seq(25, 350, by = 25)) - log(500))
mid <- c(0.77, (rho[-1] + rho[-14]) / 2)

df <- df %>%
  mutate(inconsistent = as.numeric(is.na(riskcoefbas) & riskloverbas_nomiss %in% 0)) %>%
  filter(!is.na(riskcoefbas) | inconsistent == 1) %>%
  mutate(choice = if_else(inconsistent == 1, 1L,
                          map_int(as.numeric(riskcoefbas),
                                  ~ if (is.na(.x)) NA_integer_ else which.min(abs(mid - .x)) + 1L)))
stopifnot(sum(df$inconsistent == 0) == 1703, sum(df$inconsistent) == 118,
          max(abs(mid[df$choice[df$inconsistent == 0] - 1] -
                    as.numeric(df$riskcoefbas[df$inconsistent == 0]))) < 0.001)

## female is 1 for women and complete for the whole trial; agebas is age at
## baseline, 18 to 32. Both reproduce Table 1 (age 23.45 over the 3029, 23.39
## in this subsample).
##
## A direction note: there is essentially no gender gap here. Men average an
## RRA of 0.248 against women's 0.243, and 34.1 percent of men against 35.6
## percent of women count as risk-lovers. The usual check neither passes nor
## fails; the coding of female is the trial's own and is labelled "correct
## gender of the respondent in the dataset".
df <- df %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice,
            inconsistent,
            gender = as.numeric(female),
            age = as.numeric(agebas),
            bibkey = "BjorkmanNyqvist2018",
            paper = "Bjorkman Nyqvist et al. 2018")

## Field experiment in Lesotho; the villages are not named in the data.
df$country = 'Lesotho'
df$city = ''
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
df %>% write_csv("Data/BjorkmanNyqvist_et_al_2018/formatted_dataset.csv")
