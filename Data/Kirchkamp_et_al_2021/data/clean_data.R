## O. Kirchkamp, J. Oechssler and A. Sofianos
## The Binary Lottery Procedure does not induce risk neutrality in the Holt & Laury and Eckel & Grossman tasks
## Journal of Economic Behavior and Organization 185 (2021) 348–369

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires


#### getting the data
load("Data/Kirchkamp_et_al_2021/data/data.Rdata")

## So we have several datasets from various sources, we can treat them separately
## If 11 then person always chose non risky lottery -> no switching point

## Holt and Lorry pull of tasks 
## ----------BRUNNER-----------------
## hlSwitch is the row at which the subject leaves the safe option, so the
## number of safe choices is hlSwitch - 1 and the number of RISKY choices --
## which is what `choice` means everywhere else in this project, and what
## generate_r.R's table expects -- is 11 - hlSwitch. The block above filters
## hlSwitch == 11 out, which is exactly the "never switched, all safe" case,
## i.e. 0 risky choices.
##
## This used to be a plain rename, and fed the number of SAFE choices into a
## table built for risky ones. It flipped the CRRA of every dataset in this
## file: mean r came out at 1.11 (risk loving) against 0.57 for the other 60
## HL papers on the site, with 54% of subjects past the risk-neutral r = 1
## against 20% elsewhere.
##
## One caveat is recorded here rather than silently resolved. The Duersch,
## Oechssler and Vadovic experiment appears both here (as DOV) and in the
## ManSci2016 meta-analysis, and the two codings sit one step apart: matching
## the meta-analysis exactly would need 12 - hlSwitch, which puts one subject
## at 11 on a 0-10 scale. 11 - hlSwitch follows this file's own definition of
## hlSwitch and stays in range, so that is what is used.

brunner = HL$BHO %>% 
  filter(hlSwitch!=11, consistent == 1) %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, hlSwitch) %>%
  mutate(choice = 11L - as.integer(hlSwitch)) %>%
  select(-hlSwitch)

## add the name of the task   
brunner$task = 'HL'
brunner$country = 'Germany'
# adding paper name and bibkey
brunner <- brunner %>% 
  mutate(bibkey = "Brunner2014",
         paper = "Brunner et al 2014")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
brunner <- brunner %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
brunner <- brunner %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

brunner %>% write_csv("Data/Kirchkamp_et_al_2021/data/Brunner2014/formatted_dataset.csv")


## ----------Dürsch-----------------

dursch = HL$DOV %>% 
  filter(hlSwitch!=11, consistent == 1) %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, hlSwitch) %>%
  mutate(hlSwitch = as.integer(hlSwitch)) %>%
  mutate(choice = 11L - as.integer(hlSwitch)) %>%
  select(-hlSwitch)

## add the name of the task   
dursch$task = 'HL'
dursch$country = 'Germany'
# adding paper name and bibkey
dursch <- dursch %>% 
  mutate(bibkey = "Dursch2012",
         paper = "Dursch et al 2012")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
dursch <- dursch %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
dursch <- dursch %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

## NOT written to the app any more -- this is the same experiment, and the same
## ~200 subjects, that the ManSci2016 meta-analysis already contributes as
## Duersch2012. Verified: this file's `choice` equals the meta-analysis'
## `totsafe` + 2 (a monotone increasing map, 7 mismatches in 400 observations,
## all explained by the two cleanings dropping different inconsistent subjects).
##
## The two disagreed on direction as well. Everywhere else in this project
## `choice` for HL is the number of RISKY choices -- see the "coding choices in
## HL as number of risky choices" line in the Crosetto/Filippin ExpEcon script,
## and generate_r.R, where choice = 6 maps to r ~ 1, the risk-neutral value the
## HL table puts at 4 safe / 6 risky choices. `hlSwitch` counts the other way,
## so this block produced mean r = 1.34, i.e. risk loving, for a sample the
## meta-analysis puts at r = 0.80. The kept copy is the meta-analysis one.
##
## The block is left in place because the same `hlSwitch` coding is used for
## Brunner2014 / Proto2018 / Kirchkamp2021 / Roth2016 / Dursch2017 below and
## wants the same look; only the output file is renamed out of the way.
# dursch %>% write_csv("Data/Kirchkamp_et_al_2021/data/Dursch2012/formatted_dataset.csv")

## ----------Proto----------------
proto = HL$PRS %>%  
  filter(hlSwitch!=11, consistent == 1) %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, hlSwitch) %>%
  mutate(choice = 11L - as.integer(hlSwitch)) %>%
  select(-hlSwitch)

## add the name of the task   
proto$task = 'HL'
proto$country = 'Germany'
# adding paper name and bibkey
proto <- proto %>% 
  mutate(bibkey = "Proto2018",
         paper = "Proto et al 2018")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
proto <- proto %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
proto <- proto %>%  
  select(bibkey, paper, task, subject, choice, r, everything())

proto %>% write_csv("Data/Kirchkamp_et_al_2021/data/Proto2018/formatted_dataset.csv")


## ----------Kirchkamp----------------
kirch = HL$onlineStd %>% 
  filter(hlSwitch!=11, consistent == 1) %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, hlSwitch) %>%
  mutate(hlSwitch = as.integer(hlSwitch)) %>%
  mutate(choice = 11L - as.integer(hlSwitch)) %>%
  select(-hlSwitch)

## add the name of the task   
kirch$task = 'HL'
kirch$country = 'Germany'
# adding paper name and bibkey
kirch <- kirch %>% 
  mutate(bibkey = "Kirchkamp2021",
         paper = "Kirchkamp et al 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
kirch <- kirch %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
kirch <- kirch %>%  
  select(bibkey, paper, task, subject, choice, r, everything())

# kirch %>% write_csv("Data/Kirchkamp_et_al_2021/data/formatted_dataset.csv")

## ----------Roth----------------
roth = HLS$RTV %>% 
  filter(hlSwitch!=11, consistent == 1) %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, hlSwitch) %>%
  mutate(hlSwitch = as.integer(hlSwitch)) %>%
  mutate(choice = 11L - as.integer(hlSwitch)) %>%
  select(-hlSwitch)

## add the name of the task   
roth$task = 'HL'
roth$country = 'Germany'
# adding paper name and bibkey
roth <- roth %>% 
  mutate(bibkey = "Roth2016",
         paper = "Roth et al 2016")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
roth <- roth %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
roth <- roth %>%  
  select(bibkey, paper, task, subject, choice, r, everything())

roth %>% write_csv("Data/Kirchkamp_et_al_2021/data/Roth2016/formatted_dataset.csv")

## ----------Dürsch et al. (2017)----------------

dursch = HLS$DRR %>% 
  filter(hlSwitch!=11, consistent == 1) %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, hlSwitch) %>%
  mutate(hlSwitch = as.integer(hlSwitch)) %>%
  mutate(choice = 11L - as.integer(hlSwitch)) %>%
  select(-hlSwitch)
## add the name of the task   
dursch$task = 'HL'
dursch$country = 'Germany'
# adding paper name and bibkey
dursch <- dursch %>% 
  mutate(bibkey = "Dursch2017",
         paper = "Dursch et al 2017")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
dursch <- dursch %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
dursch <- dursch %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

dursch %>% write_csv("Data/Kirchkamp_et_al_2021/data/Dursch2017/formatted_dataset.csv")


## Eickel and Grosmann pull of tasks 

## ----------Apesteguia et al. (2020)----------------

apesteguia = EG$AOW %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, choice)
## add the name of the task   
apesteguia$task = 'EG'
apesteguia$country = 'Germany'
# adding paper name and bibkey
apesteguia <- apesteguia %>% 
  mutate(bibkey = "Apesteguia2020",
         paper = "Apesteguia et al 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
apesteguia <- apesteguia %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
apesteguia <- apesteguia %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

apesteguia %>% write_csv("Data/Kirchkamp_et_al_2021/data/Apesteguia2020/formatted_dataset.csv")

## ----------Kersting-Koenig ----------------

kersting = EG$LMK %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, choice)
## add the name of the task   
kersting$task = 'EG'
kersting$country = 'Germany'
# adding paper name and bibkey
kersting <- kersting %>% 
  mutate(bibkey = "Kersting2019",
         paper = "Kersting et al 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
kersting <- kersting %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
kersting <- kersting %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

kersting %>% write_csv("Data/Kirchkamp_et_al_2021/data/Kersting2019/formatted_dataset.csv")

## ----------Schmidt 2019 ----------------

schmidt = EG$S %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, choice)
## add the name of the task   
schmidt$task = 'EG'
schmidt$country = 'Germany'
# adding paper name and bibkey
schmidt <- schmidt %>% 
  mutate(bibkey = "Schmidt2019",
         paper = "Schmidt et al 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
schmidt <- schmidt %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
schmidt <- schmidt %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

schmidt %>% write_csv("Data/Kirchkamp_et_al_2021/data/Schmidt2019/formatted_dataset.csv")

## ----------Kirchkamp----------------

kirchkamp = EG$onlineStd %>% 
  mutate(subject = rownames(.)) %>%
  select(subject, choice)
## add the name of the task   
kirchkamp$task = 'EG'
kirchkamp$country = 'Germany'
# adding paper name and bibkey
kirchkamp <- kirchkamp %>% 
  mutate(bibkey = "Kirchkamp2021",
         paper = "Kirchkamp et al 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
kirchkamp <- kirchkamp %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
kirchkamp <- kirchkamp %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

kirchkamp1 = rbind(kirchkamp, kirch) 

kirchkamp1 %>% write_csv("Data/Kirchkamp_et_al_2021/data/formatted_dataset.csv")


