#### Zhou and Hey, "Context matters", Experimental Economics 21(4):723-756, 2018
#### Lab of the University of York, 96 subjects in 4 sessions of 24.

#### cleaning data to be used for the meta-analysis

## The paper compares four elicitation methods. Only the price list maps onto a
## task this site already models -- it is a certainty equivalent price list, so
## CEPL. The other three (pairwise lottery choice, allocation between two
## states, and a BDM selling price) have no category here and are left out
## rather than forced into one that does not fit.

library(tidyverse)

## PLAll.txt has no header; the layout is documented in "Guide for PL.txt".
## Probabilities and the sure amount are stored multiplied by 10.
pl <- read_csv("Data/Zhou_Hey_Experimental_Economics_2018/original_dataset/PLAll.txt",
               col_names = c("subject", "problem", "x1", "p10", "x2", "cert10", "switch"),
               show_col_types = FALSE)

## Two rows per problem: the last row on which the subject still took the
## lottery, then the row on which they switched to the sure amount. So the
## indifference point is bracketed between the two rows rather than observed.
##
## A subject who never switched has the whole row filled with -1 (always the
## lottery) or -2 (always the sure amount) -- not just the switch column. Those
## problems are censored: the indifference point lies outside the list and the
## data cannot say where, so they are dropped.
pl <- pl %>%
  mutate(pair = rep(seq_len(n() / 2), each = 2)) %>%
  group_by(pair) %>%
  filter(!any(x1 < 0 | switch < 0), n() == 2) %>%
  summarise(subject = first(subject),
            x1 = first(x1), x2 = first(x2),
            ## row A is before the switch, row B after it
            p_hi = first(p10) / 10, p_lo = last(p10) / 10,
            c_lo = first(cert10) / 10, c_hi = last(cert10) / 10,
            switch_row = last(switch),
            .groups = "drop")

## The list moves one of two things between the two rows -- for some problems
## the probability falls while the sure amount is held, for others the sure
## amount rises while the probability is held. Either way the indifference
## point sits in the bracket, and a point is drawn from it uniformly, which is
## how every interval-valued task on this site is handled (see generate_r.R).
set.seed(20220823)
pl <- pl %>%
  mutate(p_star = if_else(p_hi > p_lo, runif(n(), p_lo, p_hi), p_hi),
         c_star = if_else(c_hi > c_lo, runif(n(), c_lo, c_hi), c_lo))

## Under u(w) = w^r the certainty equivalent of a two-outcome lottery is the
## weighted power mean of the payoffs, CE(r) = (p*x1^r + (1-p)*x2^r)^(1/r),
## which is increasing in r. So setting CE(r) equal to the elicited sure amount
## has exactly one solution, and r = 1 returns the expected value -- the same
## risk-neutral benchmark the rest of the site uses.
##
## r is computed here rather than through generate_r.R because get_r() maps a
## single choice index through a per-paper lookup table, and this task has 48
## different lotteries per subject; there is no one table to look up.
ce <- function(r, p, x1, x2) {
  if (abs(r) < 1e-8) return(exp(p * log(pmax(x1, 1e-12)) + (1 - p) * log(pmax(x2, 1e-12))))
  (p * x1^r + (1 - p) * x2^r)^(1 / r)
}
solve_r <- function(p, x1, x2, cert) {
  lo <- min(x1, x2); hi <- max(x1, x2)
  if (!is.finite(cert) || cert <= lo || cert >= hi) return(NA_real_)   # outside the lottery's range
  if (x2 == 0) return(log(p) / log(cert / x1))                        # closed form when the low payoff is zero
  f <- function(r) ce(r, p, x1, x2) - cert
  if (f(-5) * f(5) > 0) return(NA_real_)
  uniroot(f, c(-5, 5), tol = 1e-8)$root
}
pl <- pl %>%
  mutate(r_problem = pmap_dbl(list(p_star, x1, x2, c_star), solve_r))

## One value per subject: the median across their solvable problems. The median
## rather than the mean because a sure amount that lands near either end of a
## list drives r to an extreme, and a single such problem should not move the
## subject's estimate.
df <- pl %>%
  filter(!is.na(r_problem)) %>%
  group_by(subject) %>%
  summarise(r = median(r_problem),
            choice = median(switch_row),   # median switching row, the raw behaviour behind r
            problems = n(), .groups = "drop") %>%
  filter(problems >= 10)                   # too few solvable problems to pin a subject down

df <- df %>%
  mutate(task = "CEPL",
         bibkey = "Zhou2018",
         paper = "Zhou and Hey 2018",
         country = "United Kingdom",
         age = NA_real_,
         gender = NA_real_)                # neither is recorded in the released files

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything(), -problems)

# Writing to file
df %>% write_csv("Data/Zhou_Hey_Experimental_Economics_2018/formatted_dataset.csv")
