#### Forteza, A., Mussio, I. & Pereyra, J. S. (2024).
#### Can political gridlock undermine checks and balances? A lab experiment.
#### Journal of Behavioral and Experimental Economics, 108, 102128.
#### https://doi.org/10.1016/j.socec.2023.102128
#### Data: https://github.com/alforteza/weakening-checks-and-balances
#### (the whole repository is in raw_repository/; the three place-of-residence
#### variables, departamento_10, departamento_hoy and montevideo_localidad, are
#### removed from data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## data.dta: 243 subjects x 14 scenarios of part 2 (t). The risk task and the
## questionnaire were done once, so one row per subject is kept (t == 1, as in
## Weakening_CB_DATABASE.do).
df <- read_dta("Data/Forteza_Mussio_Pereyra_2024/original_dataset.dta") %>%
  zap_labels() %>%
  filter(t == 1)
stopifnot(nrow(df) == 243, !anyDuplicated(df$i))

## Part 3, "Risk aversion measurement" (online appendix, section 6): a
## Holt-Laury list, option A $20 or $16, option B $39 or $1 (Uruguayan pesos),
## the high prize with probability 1/10 ... 10/10. rpref1 ... rpref10 are the
## ten rows, 1 = A, 2 = B (the do-file: "chosen option for row 1 was Option
## B"). choice = number of B choices. As in the authors' risk file, nobody is
## dropped: 3 subjects chose B in row 1 and 37 switched more than once.
df <- df %>%
  mutate(choice = rowSums(across(rpref1:rpref10) == 2))

## genero_nac is the gender assigned at birth, "Femenino" / "Masculino" (21
## blank). Age is only asked as "19 años o menos" / "20 años o más", so it is
## left missing.
df <- df %>%
  transmute(subject = row_number(),
            age = NA_real_,
            gender = case_when(genero_nac == "Femenino" ~ 1, genero_nac == "Masculino" ~ 0),
            task = "HL",
            choice = choice)

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Forteza2024",
         paper = "Forteza, Mussio and Pereyra 2024")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## "We conducted all experimental sessions in 2019, between August and
## October, at the Experimental Laboratory of the Faculty of Social Sciences at
## Universidad de la República, Uruguay."
df$country = 'Uruguay'
df$city = 'Montevideo'
df$lattitude = '-34.9077'
df$longitude = '-56.1759'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Forteza_Mussio_Pereyra_2024/formatted_dataset.csv")
