## function that translates choices into each different task
## into an 'r' risk parameter of a CRRA x utility funtion

## For the interval-based tasks (HL, EG, CEPL, EG_loss, PV) an answer only pins
## down a range, and we draw a point from it with runif() -- 60% of the rows.
## Without a seed the HL x EG correlation moved between 0.205 and 0.247 across
## rebuilds of the same data, so published figures could not be reproduced.
##
## The seed sits at the top of this file on purpose: every clean_data.R sources
## it, so each paper starts from the same RNG state and adding a new paper
## cannot disturb values already published for the others.
set.seed(20220823)


### Comment calculer les bornes? 

## https://economics.stackexchange.com/questions/33003/how-to-calculate-crra-bounds-from-holt-and-laury-2002-type-lottery
## https://www.wolframalpha.com/input?i=1.11369
## ex. 16 ^ r * 0.5 + 72 ^  r * 0.5 = 0 ^ r * 0.5 + 84 ^ r * 0.5

## Investment Game (Gneezy-Potters) inversion.
## Endowment X, invest x, win with prob 1/2 -> X + (k-1)x, else -> X - x.
## With u(w) = w^r the interior FOC is
##     (k-1) * (X + (k-1)x)^(r-1) = (X - x)^(r-1)
## which solves to
##     r = 1 - log(k-1) / [ log(X + (k-1)x) - log(X - x) ]
## Corner cases keep the convention already used across the file:
##   x = X (invest everything) -> r = 1  (risk neutral; the IG cannot express r > 1)
##   x = 0 (invest nothing)    -> r = -1 (censored; the corner is consistent with any low r)
ig_crra <- function(choice, X, k) {
  if (choice >= X) return(1)
  if (choice <= 0) return(-1)
  1 - log(k - 1) / (log(X + (k - 1) * choice) - log(X - choice))
}

## Gneezy-Potters investment with a general binary asset: with probability p the
## invested amount c gains g*c, otherwise it loses l*c. The first-order condition
## of p*u(X + g*c) + (1-p)*u(X - l*c) with u = x^r gives r for an interior choice.
## With l = 1 investing everything means r >= 1 (coded 1); with l < 1 the
## all-in choice gives the bound at c = X.
ig_crra_pgl <- function(choice, X, p, g, l) {
  if (choice <= 0) return(-1)
  if (choice >= X & l >= 1) return(1)
  c <- min(choice, X)
  1 - log(p * g / ((1 - p) * l)) / (log(X + g * c) - log(X - l * c))
}

## CE staircase (bisection) inversion. A lottery paying X with probability p,
## else 0; the last choice of the staircase leaves the certainty equivalent in
## [lo, hi]. CE = X * p^(1/r) gives r = log(p) / log(CE / X), drawn between the
## two ends. A CE interval reaching 0 starts at r = 0; an interval reaching X
## (the subject took the lottery even at the highest sure amount) is coded at
## the point `top`, the r of the lowest CE in that interval.
ce_stair_crra <- function(lo, hi, X, p = 0.5, top) {
  if (hi >= X) return(top)
  r_lo <- if (lo <= 0) 0 else log(p) / log(lo / X)
  runif(1, min = r_lo, max = log(p) / log(hi / X))
}

## A Holt-Laury menu collapsed into a single stated switching probability. Both
## lotteries share the probability of the high prize; the subject names the
## smallest integer X, in percent, at which the riskier lottery B becomes
## preferable to the safer A, so the indifference probability sits in
## ((X-1)/100, X/100]. Solving
##     p*u(A_hi) + (1-p)*u(A_lo) = p*u(B_hi) + (1-p)*u(B_lo)
## for the relative risk aversion rho under the proper CRRA
## u(w) = w^(1-rho)/(1-rho) gives one end of the interval for each of the two
## probabilities, and the site's r = 1 - rho is drawn between them. r falls as X
## rises, so the low end comes from X and the high end from X-1. Both ends of
## the 1-100 scale are open intervals, hence the explicit truncation.
hl_switch_crra <- function(choice, A_hi, A_lo, B_hi, B_lo, floor_r, ceiling_r) {
  u <- function(w, rho) if (abs(rho - 1) < 1e-12) log(w) else w^(1 - rho) / (1 - rho)
  r_at <- function(p) {
    if (p <= 0) return(ceiling_r)
    if (p >= 1) return(floor_r)
    f <- function(rho) p * u(A_hi, rho) + (1 - p) * u(A_lo, rho) -
                       p * u(B_hi, rho) - (1 - p) * u(B_lo, rho)
    1 - uniroot(f, c(-60, 60), tol = 1e-10)$root
  }
  lo <- max(r_at(choice / 100), floor_r)
  hi <- min(r_at((choice - 1) / 100), ceiling_r)
  if (hi <= lo) return(lo)
  runif(1, min = lo, max = hi)
}

get_r <- function(bibkey, task, choice) {
  
  if (bibkey == "Charness2019") {
    
    if (task == "EG") {
      if (choice == 1) { out <- -2.45 }
      if (choice == 2) { out <- runif(1, min = -2.45, max = -0.16)}
      if (choice == 3) { out <- runif(1, min = -0.16, max = 0.29)}
      if (choice == 4) { out <- runif(1, min = 0.29, max = 0.50)}
      if (choice == 5) { out <- runif(1, min = 0.50, max = 1)}
      if (choice == 6) { out <- 1}
    }
    
    if (task == "HL") {
      if (choice == 10) { out <- 2.71   }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    
    ## TODO: how to deal with the long left tail??
    if (task == "IG") { out <- ig_crra(choice, X = 8, k = 2.5) }
    
    if (task != "HL" & task != "EG" & task != "IG") { out <- NA }
  }
  
  ## Li and Zafar 2023 used the same five 50/50 gambles ($2/2, 3/1.5, 4/1, 5/0.5,
  ## 6/0, the classic Eckel-Grossman menu halved), so the EG bounds are shared.
  ## Meraner and Finger 2019 used the Holt-Laury table times 50 (100/80 vs
  ## 192.5/5 euro), Crockett et al. 2019 the table times 3 and Cipriani et al.
  ## 2018 the original one, so the HL bounds are shared.
  if (bibkey == "Crosetto2016" | bibkey == "LiZafar2023" | bibkey == "Meraner2019" |
      bibkey == "Cipriani2018" | bibkey == "CrockettDuffy2019") {
    
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
    
    if (task == "HL") {
      if (choice == 10) { out <- 2.71   }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    
    if (task == "BART") { out <- choice/(100-choice) }
    
    if (task == "IG") { out <- ig_crra(choice, X = 4, k = 4) }
    
  }
  
  if (bibkey == "Meta2016") {
    if (task == "HL") {
      if (choice == 10) { out <- 2.71   }
      if (choice == 9) {out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }    
  }
  
  if (bibkey == "Menkhoff_Sakha_2017") {
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
    
    ## EG with a possible loss: 50/50, 90/30, 130/10, 170/-10, 210/-30 THB
    ## (data_description.pdf, Table A2). Subjects first received 30 THB, the
    ## largest possible loss, so final payoffs are these plus 30:
    ## 80/80, 120/60, 160/40, 200/20, 240/0 -- the EG table above times 5, hence
    ## the same bounds. (Corrected in 2026: the earlier bounds -0.25 / 0.60 /
    ## 0.82 / 1 were marked "a bit iffy" and could not be reproduced; the stored
    ## values were mapped to the new intervals by fix_EG_loss_2026.R.)
    if (task == "EG_loss") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
    
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 3) }
    
    if (task == "CEPL") {
      if (choice == 20) { out <- 1.52   }
      if (choice == 19)  { out <- runif(1, min = 1.36, max = 1.52) }
      if (choice == 18)  { out <- runif(1, min = 1.22, max = 1.36) }
      if (choice == 17)  { out <- runif(1, min = 1.1, max = 1.22) }
      if (choice == 16)  { out <- runif(1, min = 1, max = 1.1) }
      if (choice == 15)  { out <- runif(1, min = 0.91, max = 1) }
      if (choice == 14)  { out <- runif(1, min = 0.83, max = 0.91) }
      if (choice == 13)  { out <- runif(1, min = 0.76, max = 0.83) }
      if (choice == 12)  { out <- runif(1, min = 0.69, max = 0.76) }
      if (choice == 11)  { out <- runif(1, min = 0.63, max = 0.69) }
      if (choice == 10) { out <- runif(1, min = 0.57, max = 0.63) }
      if (choice == 9) { out <- runif(1, min = 0.52, max = 0.57) }
      if (choice == 8) { out <- runif(1, min = 0.48, max = 0.52) }
      if (choice == 7) { out <- runif(1, min = 0.43, max = 0.48) }
      if (choice == 6) { out <- runif(1, min = 0.39, max = 0.43) }
      if (choice == 5) { out <- runif(1, min = 0.34, max = 0.39) }
      if (choice == 4) { out <- runif(1, min = 0.3, max = 0.34) }
      if (choice == 3) { out <- runif(1, min = 0.26, max = 0.3) }
      if (choice == 2) { out <- runif(1, min = 0.2, max = 0.26) }
      if (choice == 1) { out <- runif(1, min = -1, max = 0.2) }
      if (choice == 0) { out <- -1 }
    }
  }
  
  if (bibkey == "Holzmeister2019") {
    
      if (task == "HL") {
        if (choice == 10) { out <- 2.71   }
        if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
        if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
        if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
        if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
        if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
        if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
        if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
        if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
        if (choice == 1) { out <- -0.37 }
        if (choice == 0) { out <- -0.37 }
      }
      
      if (task == "BRET") {
        if (choice == 100) { out <- 10 }
        if (choice != 100) { out <- choice/(100-choice) }
      }
      
      if (task == "EG") {
        if (choice == 1) { out <- -1.97 }
        if (choice == 2) { out <- runif(1, min = -1.97, max = 0)}
        if (choice == 3) { out <- runif(1, min = 0, max = 0.39)}
        if (choice == 4) { out <- runif(1, min = 0.39, max = 0.58)}
        if (choice == 5) { out <- runif(1, min = 0.58, max = 1)}
        if (choice == 6) { out <- 1}
      }
      
      if (task == "CEPL") {
        if (choice == 9) { out <- 7.96 }
        if (choice == 8) { out <- runif(1, min = 3.71, max = 7.96) }
        if (choice == 7) { out <- runif(1, min = 2.06, max = 3.71) }
        if (choice == 6) { out <- runif(1, min = 1, max = 2.06) }
        if (choice == 5) { out <- runif(1, min = 0.07, max = 1) }
        if (choice == 4) { out <- runif(1, min = -1, max = 0.07) }
        if (choice == 3) { out <- runif(1, min = -2.93, max = -1) }
        if (choice == 2) { out <- -2.93 }
        if (choice == 1) { out <- -2.93 }
      }
    }
  
  ## Schuermann et al. 2019, Michael et al. 2020 and Zhang & Palma 2021 use the
  ## same 128-pump BART as Frey et al. 2017
  if (bibkey == "Frey2017" | bibkey == "Schuermann2019" | bibkey == "Michael2020" |
      bibkey == "Zhang2021") {
    if (task == "BART") {
      out <- choice/(128-choice)
    }
    
    if (task == "HL"){
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }
  if (bibkey == "ErtHaruvy2017") {
    if (task == "HL") {
      if (choice == 10) { out <- 2.71   }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }
  
  ### here we use the function from the article for EG
  ### and reverse all the limits using 1 - limit
  if (bibkey == "Csermely2016") {
    if (task == "EG") {
      if (choice == 9) { out <- 1.95 } 
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95)}
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49)}
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15)}
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85)}
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59)}
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32)}
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03)}
      if (choice == 1) { out <- -0.37}
    }
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    ###Bruner, D.M. (2009) design 
    if (task == "CEPL") {
      if (choice == 1) { out <- 1.74 } 
      if (choice == 2) { out <- 1.74 } 
      if (choice == 3) { out <- runif(1, min = 1.32, max = 1.74)}
      if (choice == 4) { out <- runif(1, min = 1, max = 1.32)}
      if (choice == 5) { out <- runif(1, min = 0.74, max = 1)}
      if (choice == 6) { out <- runif(1, min = 0.52, max = 0.74)}
      if (choice == 7) { out <- runif(1, min = 0.32, max = 0.52)}
      if (choice == 8) { out <- runif(1, min = 0, max = 0.32)}
      if (choice == 9) { out <- runif(1, min = 0, max = 0.32)}
    }
    
  }
  
  ## Huber and Weitzel are the same group running the same protocol: a BRET on
  ## a 5x5 grid, so 25 boxes. Collecting the boxes is the only choice, and the
  ## CRRA that rationalises stopping at k of n boxes is k/(n-k).
  ## Brox et al. 2025 used the same 25-box static BRET (20 Eurocents per box).
  if (bibkey == "Huber2019" | bibkey == "Weitzel2019" | bibkey == "Brox2025") {
    if (task == "BRET") {
      if (choice == 25) { out <- 10 }
      if (choice != 25) { out <- choice/(25-choice) }
    }
  }
  ## Karapetian et al. 2025 used the standard HL list ($2.00/$1.60 vs $3.85/$0.10),
  ## Buyukboyaci et al. 2026 the same list x 5 in ECU. Schipper 2023 used the list x 2
  ## shifted by one row; its choice is recoded to the standard count in clean_data.R.
  ## Kagan et al. 2020 do not give their payoffs; the standard list is assumed and
  ## the switching row is turned into the count of B choices in clean_data.R.
  if (bibkey == "Brunner2014" | bibkey == "Dursch2012" | bibkey == "Proto2018" | bibkey == "Kirchkamp2021" | bibkey == "Roth2016" | bibkey == "Dursch2017" | bibkey == "Karapetian2025" | bibkey == "Buyukboyaci2026" | bibkey == "Schipper2023" | bibkey == "Kagan2020") {
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    if (task == "EG") {
      if (choice == 1) { out <- -0.09 } 
      if (choice == 2) { out <- runif(1, min = -0.09, max = 0.51)}
      if (choice == 3) { out <- runif(1, min = 0.51, max = 1.11)}
      if (choice == 4) { out <- 1.11}
    }
  }
    if (bibkey == "Apesteguia2020"){
    if (task == "EG") {
      if (choice == 1) { out <- -4 } 
      if (choice == 2) { out <- runif(1, min = -4, max = 0.66)}
      if (choice == 3) { out <- runif(1, min = 0.66, max = 1.49)}
      if (choice == 4) { out <- 1.49}
    }
    }
  if (bibkey == "Kersting2019"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.32 } 
      if (choice == 2) { out <- runif(1, min = -2.32, max = -0.11)}
      if (choice == 3) { out <- runif(1, min = -0.11, max = 0.33)}
      if (choice == 4) {out <- runif(1, min = 0.33, max = 0.53)}
      if (choice == 5) { out <- runif(1, min = 0.53, max = 0.64) } 
      if (choice == 6) { out <- runif(1, min = 0.64, max = 0.71)}
      if (choice == 7) { out <- runif(1, min = 0.71, max = 0.77)}
      if (choice == 8) { out <- runif(1, min = 0.77, max = 0.81)}
      if (choice == 9) { out <- runif(1, min = 0.81, max = 0.9)}
      if (choice == 10) { out <- runif(1, min = 0.9, max = 1)}
      if (choice == 11) { out <- 1}
    }
  }
  if (bibkey == "Schmidt2019"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.94 } 
      if (choice == 2) { out <- runif(1, min = -2.94, max = -0.32)}
      if (choice == 3) { out <- runif(1, min = -0.32, max = 0.19)}
      if (choice == 4) {out <- runif(1, min = 0.19, max = 0.43)}
      if (choice == 5) { out <- runif(1, min = 0.43, max = 0.56) } 
      if (choice == 6) { out <- runif(1, min = 0.56, max = 0.66)}
      if (choice == 7) { out <- runif(1, min = 0.66, max = 1)}
      if (choice == 8) { out <- 1}
    }
  }
  if (bibkey == "DrichoutisNayga2022" | bibkey == "DrichoutisNayga2013"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    if (task == 'PV'){
      if (choice == 10) { out <- 3.79 } 
      if (choice == 9) { out <- runif(1, min = 2.24, max = 3.79 )}
      if (choice == 8) { out <- runif(1, min = 1.69, max = 2.24)}
      if (choice == 7) { out <- runif(1, min = 1.24, max = 1.69)}
      if (choice == 6) { out <- runif(1, min = 0.78, max = 1.24) } 
      if (choice == 5) { out <- runif(1, min = 0.61, max = 0.78)}
      if (choice == 4) { out <- runif(1, min = 0.41 , max = 0.61)}
      if (choice == 3) { out <- runif(1, min = 0.2 , max = 0.41)}
      if (choice == 2) { out <- runif(1, min = 0.1, max = 0.2)}
      if (choice == 1) { out <- runif(1, min = -0.02, max = 0.1)}
      if (choice == 0) { out <- -0.02 }
    }
  } 
  if (bibkey == "Brañas-Garza2021"){
    if (task == "HL") {
      if (choice == 5) { out <- 2.60}
      if (choice == 4) { out <- runif(1, min = 1.11 , max = 2.60)}
      if (choice == 3) { out <- runif(1, min = 0.84 , max = 1.11)}
      if (choice == 2) { out <- runif(1, min = 0.64, max = 0.84)}
      if (choice == 1) { out <- runif(1, min = -0.21, max = 0.64)}
      if (choice == 0) { out <- -0.21 }
    }
  } 
  if (bibkey == "Costa-Gomes2022"){
    if (task == "BRET") {
      if (choice == 25) { out <- 10 }
      if (choice != 25) { out <- choice/(25-choice) }
    }
  } 
  if (bibkey == "Hopfensitz2019"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.25 } 
      if (choice == 2) { out <- runif(1, min = -2.25, max = -0.10)}
      if (choice == 3) { out <- runif(1, min = -0.10, max = 0.32)}
      if (choice == 4) {out <- runif(1, min = 0.32, max = 0.53)}
      if (choice == 5) { out <- 0.53 } 
    }
  } 
  if (bibkey == "Amador2021"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }
  if (bibkey == "Nielsen2019"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }
  ## Orland 2025: endowment of 1 euro invested in 10-cent units (choice 0-10), 2.5-fold
  if (bibkey == "Orland2025"){
    if (task == "IG") { out <- ig_crra(choice, X = 10, k = 2.5) }
  }
  ## Dadon et al. 2026: endowment of 100 points, invested amount pays 2.5-fold
  if (bibkey == "Dadon2026"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 2.5) }
  }
  ## Filippin and Mantovani 2023, Mantovani and Filippin 2026: endowment of 200 MU, 2.5-fold
  if (bibkey == "Filippin2023" | bibkey == "Mantovani2026"){
    if (task == "IG") { out <- ig_crra(choice, X = 200, k = 2.5) }
  }
  ## Chaudhuri et al. 2024: endowment of Rs. 100, invested amount tripled
  if (bibkey == "Chaudhuri2024"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 3) }
  }
  ## Razen et al. 2021: six 50/50 lotteries 10/10, 13/8, 16/6, 19/4, 22/2, 24/0.
  ## Bounds are the CRRA values that make adjacent lotteries indifferent;
  ## lotteries 5 and 6 have the same expected value, hence the bound of 1.
  if (bibkey == "Razen2021"){
    if (task == "EG") {
      if (choice == 1) { out <- -0.668 }
      if (choice == 2) { out <- runif(1, min = -0.668, max = 0.445)}
      if (choice == 3) { out <- runif(1, min = 0.445, max = 0.678)}
      if (choice == 4) { out <- runif(1, min = 0.678, max = 0.791)}
      if (choice == 5) { out <- runif(1, min = 0.791, max = 1)}
      if (choice == 6) { out <- 1}
    }
  }
  ## Mueller et al. 2023: a ten-row Holt and Laury list run on Prolific. The
  ## payoffs are not stated in the paper, but the realised payments give them
  ## away: HL_result only ever takes 10, 160, 200 or 385, and in the last row,
  ## where the high outcome is certain, only 200 and 385 occur -- so the safe
  ## option pays 200 or 160 and the risky one 385 or 10. That is the Holt and
  ## Laury 1x table times 100, and CRRA bounds are scale-invariant, so the
  ## canonical bounds apply unchanged.
  if (bibkey == "Mueller2023"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }

  ## Masters, Lloyd and Starmer 2025: a certainty-equivalent price list for a
  ## lottery paying GBP 12 with probability 1/2, else nothing. 25 rows, the sure
  ## amount rising from 3.00 to 9.00 in 25p steps (Fig. 3 of the paper).
  ## `choice` is the number of rows where the lottery is kept, so with k of them
  ## the certainty equivalent lies between the k-th and the (k+1)-th sure
  ## amount, and CE = 12 * 0.5^(1/r) gives r = log(0.5) / log(CE / 12).
  ##
  ## Control: a risk-neutral subject values the lottery at its expected value of
  ## 6.00, which is exactly the sure amount of row 13, so keeping the lottery in
  ## rows 1 to 12 must put r at the top of its interval -- and k = 12 returns
  ## 0.942 to 1. This matches the paper, which says risk-neutral subjects prefer
  ## the lottery in rows 1-12.
  ##
  ## The ends are open and take the bound: k = 0 (the sure 3.00 taken straight
  ## away) is held at r = 0.5, and k = 25 (the lottery kept through the whole
  ## sheet) at r = 2.409.
  if (bibkey == "Masters2025"){
    if (task == "CEPL") {
      r_of <- function(ce) log(0.5) / log(ce / 12)
      if (choice <= 0)  { out <- r_of(3) }
      if (choice >= 25) { out <- r_of(9) }
      if (choice > 0 & choice < 25) {
        out <- runif(1, min = r_of(3 + 0.25 * (choice - 1)),
                        max = r_of(3 + 0.25 * choice))
      }
    }
  }

  ## Faravelli et al. 2026: the authors call this the Holt and Laury (2002)
  ## measure, but what moves down the list is the spread of the payoffs, not
  ## the probability, so it is a payoff-varying list and is filed as PV, the
  ## same cell as the Drichoutis-Lusk list, rather than as HL.
  ## Every row puts a 50-50 lottery between 49 and 70 cents against a 50-50
  ## lottery between 12 and X cents, with X running 70, 80, ... 160 (online
  ## appendix). Indifference solves 49^r + 70^r = 12^r + X^r.
  ##
  ## Two checks on the numbers below. The first row, X = 70, has no root: the
  ## safe lottery first-order stochastically dominates there, which is the
  ## attention check the authors built in, and the 14 subjects who still took
  ## the risky side are dropped in clean_data.R, so choice never reaches 10
  ## here. And a risk-neutral subject is indifferent at X = 107, between the
  ## fourth and fifth row, so six risky choices must bracket r = 1 -- it gives
  ## 0.932 to 1.195.
  ##
  ## The list only spans r from 0.37 to 2.50, so both ends hold a lot of
  ## subjects: 161 of 786 never took the risky side and sit at the bottom
  ## bound, 27 took it from the second row on and sit at the top one.
  if (bibkey == "Faravelli2026"){
    if (task == "PV") {
      if (choice == 0) { out <- 0.366 }
      if (choice == 1) { out <- runif(1, min = 0.366, max = 0.433) }
      if (choice == 2) { out <- runif(1, min = 0.433, max = 0.515) }
      if (choice == 3) { out <- runif(1, min = 0.515, max = 0.618) }
      if (choice == 4) { out <- runif(1, min = 0.618, max = 0.751) }
      if (choice == 5) { out <- runif(1, min = 0.751, max = 0.932) }
      if (choice == 6) { out <- runif(1, min = 0.932, max = 1.195) }
      if (choice == 7) { out <- runif(1, min = 1.195, max = 1.622) }
      if (choice == 8) { out <- runif(1, min = 1.622, max = 2.505) }
      if (choice == 9) { out <- 2.505 }
    }
  }

  ## Bruhin, Petros and Santos-Pinto 2024: the Crosetto and Filippin (2013)
  ## BRET in block 3, after the quiz that manipulates self-confidence. A
  ## hundred boxes at 2.5 centimes each -- the paper's payment for the risk
  ## task runs from CHF 0 to 2.48, which is 99 boxes times 0.025 -- so the same
  ## hundred-box rule as Nielsen 2019 above.
  if (bibkey == "Bruhin2024"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## Zhou et al. 2021: a 30-trial BART whose break points were pregenerated with
  ## a mean of 20 pumps and a range of 1 to 39. The paper describes this as
  ## setting "the probability of losing to be 0.05 for all trials", which would
  ## mean a constant hazard, but the spread it reports settles the question: a
  ## break point uniform on 1-39 has mean 20 and SD 11.25 against the paper's
  ## 20 and 11.83, whereas a geometric hazard of 0.05 gives SD 19.49, and that
  ## hazard truncated at 39 gives a mean of only 13.9. The balloon is therefore
  ## the usual uniform one, and the site's BART rule applies with N = 39: a
  ## risk-neutral subject stops at 19.5 pumps, which returns r = 1, matching the
  ## average break point of 20. `choice` is the adjusted score, the mean number
  ## of pumps over the trials that did not burst, so it is not an integer.
  if (bibkey == "Zhou2021"){
    if (task == "BART") { out <- choice/(39-choice) }
  }

  ## Lopez-Perez et al. 2021: the Holt and Laury (2002) 1x lotteries -- A pays
  ## 2.00 or 1.60 euros, B pays 3.85 or 0.10 -- but asked as one question
  ## instead of a ten-row menu: "from what value of X, the probability of the
  ## higher prize, would you prefer B to A?", an integer between 1 and 100.
  ## Because the payoffs are exactly Holt and Laury's, feeding p = 0.1 ... 0.9
  ## to the helper reproduces this site's canonical HL bounds (2.71, 1.95,
  ## 1.49, 1.15, 0.85, 0.59, 0.32, 0.03, -0.37) to three decimals, which is
  ## what the numbers below were checked against. A risk-neutral subject
  ## switches at X = 44.78, so X = 45 brackets r = 1.
  ##
  ## The stated X only has to be an integer, so each answer pins r down far
  ## more tightly than a ten-row menu would. Truncation: X = 100 means the
  ## subject would switch only at certainty, which no finite r satisfies, so it
  ## is held at the r of X = 99; the same is done at the other end for X = 1.
  if (bibkey == "LopezPerez2021"){
    if (task == "HL") {
      out <- hl_switch_crra(choice, A_hi = 2.00, A_lo = 1.60,
                            B_hi = 3.85, B_lo = 0.10,
                            floor_r = -1.366, ceiling_r = 5.270)
    }
  }

  ## Feltovich and Giovannoni 2024: six 50/50 options, 4/4, 3/6, 2/8, 1/10, 0/12
  ## and -1/13 AUD. The lotteries are in neither the paper nor the codebook, but
  ## they are recovered exactly from the realised RiskPayoff: every subject who
  ## picked option k was paid one of the two outcomes of gamble k and nothing
  ## else, and the counts split roughly in half within each option, as a fair
  ## coin requires. Expected values 4, 4.5, 5, 5.5, 6, 6 -- the last two are
  ## equal, the Dave et al. (2010) structure, hence the bound of 1 between
  ## options 5 and 6.
  ##
  ## Option 6 can take a dollar off the subject, and w^r is undefined there, so
  ## as for Menkhoff_Sakha_2017 and Babin2026 the payoffs are shifted by the
  ## largest possible loss (+1): 5/5, 4/7, 3/9, 2/11, 1/13, 0/14. That is
  ## exactly half of Eckel et al. 2025's set, and CRRA bounds are
  ## scale-invariant, so the bounds below are the ones already used there --
  ## an independent check that both the recovered lotteries and the shift are
  ## right.
  if (bibkey == "Feltovich2024"){
    if (task == "EG_loss") {
      if (choice == 1) { out <- -1.489 }
      if (choice == 2) { out <- runif(1, min = -1.489, max = 0.163)}
      if (choice == 3) { out <- runif(1, min = 0.163, max = 0.503)}
      if (choice == 4) { out <- runif(1, min = 0.503, max = 0.670)}
      if (choice == 5) { out <- runif(1, min = 0.670, max = 1)}
      if (choice == 6) { out <- 1}
    }
  }
  ## Eckel et al. 2025: six 50/50 options 10/10, 8/14, 6/18, 4/22, 2/26, 0/28 dollars
  ## (Dave et al. 2010 version). Bounds make adjacent options indifferent;
  ## options 5 and 6 have the same expected value, hence the bound of 1.
  if (bibkey == "Eckel2025"){
    if (task == "EG") {
      if (choice == 1) { out <- -1.489 }
      if (choice == 2) { out <- runif(1, min = -1.489, max = 0.163)}
      if (choice == 3) { out <- runif(1, min = 0.163, max = 0.503)}
      if (choice == 4) { out <- runif(1, min = 0.503, max = 0.670)}
      if (choice == 5) { out <- runif(1, min = 0.670, max = 1)}
      if (choice == 6) { out <- 1}
    }
  }
  ## Hackethal et al. 2023: investors saw euros, students the same amounts / 4;
  ## CRRA bounds do not depend on the scale.
  ##  HL: A 24/19.20, B 46.20/1.20 = standard HL list x 12 -> standard HL bounds.
  ##  EG: 21/21, 27/18, 33/15, 39/12, 45/9, 51/6; bounds make adjacent gambles
  ##      indifferent. Gamble 6 has a higher expected value than 5, so the last bound
  ##      is below 1; as for HL, the extreme choices take the bound value.
  ##  IG: endowment 24, 2.5-fold (student choices are rescaled to euros).
  if (bibkey == "Hackethal2023"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    if (task == "EG") {
      if (choice == 1) { out <- -2.46 }
      if (choice == 2) { out <- runif(1, min = -2.46, max = -0.161)}
      if (choice == 3) { out <- runif(1, min = -0.161, max = 0.294)}
      if (choice == 4) { out <- runif(1, min = 0.294, max = 0.501)}
      if (choice == 5) { out <- runif(1, min = 0.501, max = 0.628)}
      if (choice == 6) { out <- 0.628}
    }
    if (task == "IG") { out <- ig_crra(choice, X = 24, k = 2.5) }
  }
  ## Lima de Miranda et al. 2025: six 50/50 coins 4/4, 5/3.5, 6/3, 7/2.5, 8/2, 9/1 euros.
  ## Coins 5 and 6 have the same expected value, hence the bound of 1.
  if (bibkey == "LimaDeMiranda2025"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.944 }
      if (choice == 2) { out <- runif(1, min = -2.944, max = -0.320)}
      if (choice == 3) { out <- runif(1, min = -0.320, max = 0.195)}
      if (choice == 4) { out <- runif(1, min = 0.195, max = 0.425)}
      if (choice == 5) { out <- runif(1, min = 0.425, max = 1)}
      if (choice == 6) { out <- 1}
    }
  }
  ## Segovia et al. 2025: standard HL list, plus the Drichoutis-Lusk payoff-varying list
  ## as given in the data (rows 11-20, p = 0.5). The PV bounds are the CRRA values that
  ## make A and B indifferent in each row of that list; they differ from the PV rule
  ## used above for Drichoutis and Nayga.
  if (bibkey == "Segovia2025"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    if (task == "PV") {
      if (choice == 10) { out <- 2.735 }
      if (choice == 9) { out <- runif(1, min = 1.920, max = 2.735) }
      if (choice == 8) { out <- runif(1, min = 1.471, max = 1.920) }
      if (choice == 7) { out <- runif(1, min = 1.130, max = 1.471) }
      if (choice == 6) { out <- runif(1, min = 0.864, max = 1.130) }
      if (choice == 5) { out <- runif(1, min = 0.596, max = 0.864) }
      if (choice == 4) { out <- runif(1, min = 0.316, max = 0.596) }
      if (choice == 3) { out <- runif(1, min = 0.033, max = 0.316) }
      if (choice == 2) { out <- runif(1, min = -0.367, max = 0.033) }
      if (choice == 1) { out <- -0.367 }
      if (choice == 0) { out <- -0.368 }
    }
  }
  ## Mill and Schneider 2026: EG gambles 528/528, 432/720, 336/912, 240/1104,
  ## 144/1296, 0/1440 points (E and F have the same expected value, hence the bound
  ## of 1); static BRET with 100 boxes.
  if (bibkey == "Mill2026"){
    if (task == "EG") {
      if (choice == 1) { out <- -1.732 }
      if (choice == 2) { out <- runif(1, min = -1.732, max = 0.081)}
      if (choice == 3) { out <- runif(1, min = 0.081, max = 0.449)}
      if (choice == 4) { out <- runif(1, min = 0.449, max = 0.624)}
      if (choice == 5) { out <- runif(1, min = 0.624, max = 1)}
      if (choice == 6) { out <- 1}
    }
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }
  ## Schwaiger et al. 2025: Gneezy-Potters asset, 1/3 chance of +250% (or +230%),
  ## 2/3 chance of losing 100% (or 90%); 100 ECU per period, choice = % invested.
  ## The two asset versions use the internal task labels IG_250 and IG_230;
  ## clean_data.R renames both to IG after computing r.
  if (bibkey == "Schwaiger2025"){
    if (task == "IG_250") { out <- ig_crra_pgl(choice, X = 100, p = 1/3, g = 2.5, l = 1) }
    if (task == "IG_230") { out <- ig_crra_pgl(choice, X = 100, p = 1/3, g = 2.3, l = 0.9) }
  }
  
  ## Hueber & Schwaiger 2022: Gneezy-Potters asset, 1/3 chance of winning 2.5 times
  ## the bet, 2/3 chance of losing it; 200 tokens per round, choice = tokens bet
  if (bibkey == "Hueber2022"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 200, p = 1/3, g = 2.5, l = 1) }
  }

  ## von Essen et al. 2020: the same Gneezy-Potters asset with 60 ECU
  if (bibkey == "VonEssen2020"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 60, p = 1/3, g = 2.5, l = 1) }
  }
  
  ## Adamo & Coricelli 2026: 100 tokens, 50% chance the investment pays 2.5 times
  if (bibkey == "Adamo2026"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 2.5) }
  }
  
  ## Fuellbrunn et al. 2026 (robustness experiment) and Bachmann et al. 2023: original Gneezy-Potters,
  ## 1/3 chance of gaining 2.5 times the investment, 2/3 chance of losing it;
  ## choice = % of the endowment invested
  if (bibkey == "Fuellbrunn2026" | bibkey == "Bachmann2023"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 100, p = 1/3, g = 2.5, l = 1) }
  }
  
  ## Heinke et al. 2024, MPL 1: 50% 500 ECU or 0 against a sure -50, 0, 50, ..., 550.
  ## choice = number of rows where the lottery is taken. With k rows the certainty
  ## equivalent lies between the k-th and (k+1)-th sure amount, and
  ## CE = 500 * 0.5^(1/r) gives r = log(0.5) / log(CE / 500). A CE of 0 or less
  ## (choice 0 or 1) means r <= 0, coded 0 as in the Bruner list above; a CE above
  ## 450 is coded at the bound 6.58.
  if (bibkey == "Heinke2024"){
    if (task == "CEPL") {
      if (choice <= 1) { out <- 0 }
      if (choice == 2) { out <- runif(1, min = 0, max = 0.301) }
      if (choice == 3) { out <- runif(1, min = 0.301, max = 0.431) }
      if (choice == 4) { out <- runif(1, min = 0.431, max = 0.576) }
      if (choice == 5) { out <- runif(1, min = 0.576, max = 0.756) }
      if (choice == 6) { out <- runif(1, min = 0.756, max = 1) }
      if (choice == 7) { out <- runif(1, min = 1, max = 1.357) }
      if (choice == 8) { out <- runif(1, min = 1.357, max = 1.943) }
      if (choice == 9) { out <- runif(1, min = 1.943, max = 3.106) }
      if (choice == 10) { out <- runif(1, min = 3.106, max = 6.579) }
      if (choice >= 11) { out <- 6.579 }
    }
  }
  
  ## Clist et al. 2025: eight 50/50 lotteries 7000/7000, 6000/10000, 5000/12000,
  ## 4000/14000, 3000/16000, 2000/18000, 1000/20000, 0/22000 UGX (choice 1 = safest).
  ## Bounds make adjacent lotteries indifferent; the riskiest lottery has the
  ## highest expected value and is coded 1, as for Crosetto2016.
  if (bibkey == "Clist2025"){
    if (task == "EG") {
      if (choice == 1) { out <- -3.487 }
      if (choice == 2) { out <- runif(1, min = -3.487, max = 0)}
      if (choice == 3) { out <- runif(1, min = 0, max = 0.348)}
      if (choice == 4) { out <- runif(1, min = 0.348, max = 0.525)}
      if (choice == 5) { out <- runif(1, min = 0.525, max = 0.640)}
      if (choice == 6) { out <- runif(1, min = 0.640, max = 0.730)}
      if (choice == 7) { out <- runif(1, min = 0.730, max = 0.833)}
      if (choice == 8) { out <- 1}
    }
  }
  
  ## Clist et al. 2021: 10 coins, each risked coin is doubled with an 80% chance
  ## and lost with a 20% chance; choice = coins risked
  if (bibkey == "Clist2021"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 10, p = 0.8, g = 1, l = 1) }
  }
  
  ## Dong et al. 2026: a 50% chance of GBP 4 against a sure 1, 1.5, 1.75, 2, 2.25, 2.75.
  ## choice = number of gambles taken; with k gambles the certainty equivalent is
  ## between the k-th and (k+1)-th sure amount, and CE = 4 * 0.5^(1/r) gives
  ## r = log(0.5) / log(CE / 4). Extremes take the bounds, as for HL.
  if (bibkey == "Dong2026"){
    if (task == "CEPL") {
      if (choice == 0) { out <- 0.5 }
      if (choice == 1) { out <- runif(1, min = 0.5, max = 0.707) }
      if (choice == 2) { out <- runif(1, min = 0.707, max = 0.838) }
      if (choice == 3) { out <- runif(1, min = 0.838, max = 1) }
      if (choice == 4) { out <- runif(1, min = 1, max = 1.205) }
      if (choice == 5) { out <- runif(1, min = 1.205, max = 1.85) }
      if (choice == 6) { out <- 1.85 }
    }
  }
  
  ## Harrison and Rutstrom 2008 (Methods data): Binswanger list of eight 50/50 options
  ## A 10/10, B 19/9, C 24/8, D 25/7, E 30/6, F 32/4, G 38/2, H 40/0 dollars.
  ## Under CRRA only A, B, C, E, G, H are ever optimal: A for r < -6.51, B up to
  ## -0.743, C up to 0.188, E up to 0.685, G up to 1, H above. D and F are never
  ## optimal (each has the expected value of the option before it with more
  ## spread); they come closest to optimal at the C|E and E|G boundaries, so they
  ## are coded at those points.
  if (bibkey == "HarrisonRutstrom2008"){
    ## Holt-Laury list times 10 (Methods: A 20/16, B 38.50/1 dollars) and times 2
    ## (first-price auction sessions): the same ratios, so the standard bounds
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
    if (task == "EG") {
      if (choice == 1) { out <- -6.51 }
      if (choice == 2) { out <- runif(1, min = -6.51, max = -0.743)}
      if (choice == 3) { out <- runif(1, min = -0.743, max = 0.188)}
      if (choice == 4) { out <- 0.188}
      if (choice == 5) { out <- runif(1, min = 0.188, max = 0.685)}
      if (choice == 6) { out <- 0.685}
      if (choice == 7) { out <- runif(1, min = 0.685, max = 1)}
      if (choice == 8) { out <- 1}
    }
  }
  
  ## Gneezy and Potters 1997: 200 cents per round, 1/3 chance of gaining 2.5 times
  ## the bet, 2/3 chance of losing it; choice = cents bet
  if (bibkey == "Gneezy1997"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 200, p = 1/3, g = 2.5, l = 1) }
  }
  
  ## Haigh and List 2005: Gneezy-Potters design, 100 units per round, 1/3 chance of
  ## gaining 2.5 times the bet, 2/3 chance of losing it; choice = % bet
  if (bibkey == "Haigh2005"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 100, p = 1/3, g = 2.5, l = 1) }
  }
  
  ## Holt and Laury 2005 (1x or 20x payoffs), Andersen et al. 2014 (x1000 DKK) and
  ## Engel and Simon 2025 (original payoffs), Buyukboyaci et al. 2025 (x40): the
  ## original Holt-Laury list at another scale; the
  ## CRRA bounds do not depend on the scale, so the standard ones apply
  if (bibkey == "Holt2005" | bibkey == "Andersen2014" | bibkey == "Engel2025" | bibkey == "Buyukboyaci2025" |
      bibkey == "BarredaTarrazona2022" | bibkey == "AlosFerrer2018" | bibkey == "Engel2020" |
      bibkey == "Engel2024" | bibkey == "ValdezGonzalez2025" | bibkey == "Krull2024" |
      bibkey == "EngelKirchkamp2019" | bibkey == "Corgnet2019" | bibkey == "Koch2024" |
      bibkey == "Asako2020" | bibkey == "Farjam2018" | bibkey == "BellemareLeeJust2020" |
      bibkey == "Gallo2023" | bibkey == "Shrum2022" | bibkey == "Mimra2025"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }
  
  ## Babin et al. 2026, EG with losses: 10/10, 18/6, 26/2, 34/-2, 42/-6 tokens.
  ## As for Menkhoff_Sakha_2017, the payoffs are shifted by the largest loss (+6)
  ## so that every outcome is non-negative: 16/16, 24/12, 32/8, 40/4, 48/0, the
  ## standard EG table, hence the same bounds.
  if (bibkey == "Babin2026"){
    if (task == "EG_loss") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
  }
  
  ## Lauber et al. 2026: a sure 180 against 400 with probability p = 0.1 ... 1.0, else 0.
  ## Indifference p * 400^r = 180^r gives r = log(p) / log(0.45). With k risky choices
  ## the indifferent p lies between (10-k)/10 and (11-k)/10. Never taking the lottery,
  ## even at p = 1, is coded 0; taking it already at p = 0.1 gets the bound 2.884.
  if (bibkey == "Lauber2026"){
    if (task == "CEPL") {
      if (choice == 10) { out <- 2.884 }
      if (choice == 9) { out <- runif(1, min = 2.016, max = 2.884) }
      if (choice == 8) { out <- runif(1, min = 1.508, max = 2.016) }
      if (choice == 7) { out <- runif(1, min = 1.148, max = 1.508) }
      if (choice == 6) { out <- runif(1, min = 0.868, max = 1.148) }
      if (choice == 5) { out <- runif(1, min = 0.640, max = 0.868) }
      if (choice == 4) { out <- runif(1, min = 0.447, max = 0.640) }
      if (choice == 3) { out <- runif(1, min = 0.279, max = 0.447) }
      if (choice == 2) { out <- runif(1, min = 0.132, max = 0.279) }
      if (choice == 1) { out <- runif(1, min = 0, max = 0.132) }
      if (choice == 0) { out <- 0 }
    }
  }
  
  ## Chan et al. 2024: eleven 50/50 lotteries 10/10, 12/9, ..., 28/1, 30/0 (choice 1 = safest).
  ## Bounds make adjacent lotteries indifferent (they match the authors' table read
  ## as 1 - RRA); the riskiest lottery has the highest expected value and is coded 1.
  if (bibkey == "Chan2024"){
    if (task == "EG") {
      if (choice == 1) { out <- -3.91 }
      if (choice == 2) { out <- runif(1, min = -3.91, max = -0.636)}
      if (choice == 3) { out <- runif(1, min = -0.636, max = 0)}
      if (choice == 4) { out <- runif(1, min = 0, max = 0.28)}
      if (choice == 5) { out <- runif(1, min = 0.28, max = 0.442)}
      if (choice == 6) { out <- runif(1, min = 0.442, max = 0.551)}
      if (choice == 7) { out <- runif(1, min = 0.551, max = 0.633)}
      if (choice == 8) { out <- runif(1, min = 0.633, max = 0.70)}
      if (choice == 9) { out <- runif(1, min = 0.70, max = 0.762)}
      if (choice == 10) { out <- runif(1, min = 0.762, max = 0.844)}
      if (choice == 11) { out <- 1}
    }
  }
  
  ## Ranehill and Weber 2022: 100 ECU, the investment returns 2.5 times with 50%
  if (bibkey == "Ranehill2022"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 2.5) }
  }
  
  ## Buser et al. 2022: a sure 2 CHF, then 50/50 lotteries 3.50/1.50, 4/1, 5/0.50, 6/0
  ## (choice 1 = sure). Under CRRA the sure amount is optimal for r < -1.63, 3.50/1.50 up
  ## to 0.7295, 5/0.50 up to 0.803 and 6/0 above (coded 1, highest expected value).
  ## 4/1 has the expected value of 3.50/1.50 with more spread and is never optimal; it
  ## comes closest at the 3.50/1.50 | 5/0.50 boundary and is coded there, as for
  ## options D and F of HarrisonRutstrom2008. (The BRET is in the Fisar2023 block.)
  if (bibkey == "Buser2022"){
    if (task == "EG") {
      if (choice == 1) { out <- -1.63 }
      if (choice == 2) { out <- runif(1, min = -1.63, max = 0.7295)}
      if (choice == 3) { out <- 0.7295}
      if (choice == 4) { out <- runif(1, min = 0.7295, max = 0.803)}
      if (choice == 5) { out <- 1}
    }
  }
  
  ## Berlin et al. 2026: CE of 80 EUR with 50% (else 0), found by four bisection
  ## questions (CE_staircase), equivalent to a list of sure amounts 5, ..., 75.
  ## choice = k sure amounts below the CE, so CE lies in (5k, 5k + 5) and
  ## CE = 80 * 0.5^(1/r) gives r = log(0.5) / log(CE / 80). A CE above 75 is
  ## coded at the bound 10.74.
  if (bibkey == "Berlin2026"){
    if (task == "CE_staircase") {
      bnd <- c(0, 0.25, 0.333, 0.414, 0.5, 0.596, 0.707, 0.838, 1, 1.205, 1.475,
               1.85, 2.409, 3.338, 5.191, 10.74)
      if (choice < 15) { out <- runif(1, min = bnd[choice + 1], max = bnd[choice + 2]) }
      if (choice == 15) { out <- 10.74 }
    }
  }
  
  ## Hackethal et al. 2023: Falk et al. staircase (CE_staircase), four choices
  ## between a sure amount and 45 EUR with 50% (else 0); sure amounts 24, then
  ## +-12, +-6, +-3 (students: all divided by 4, which does not change r).
  ## choice = FA (1 ... 16): the CE lies in [3(FA - 1), 3 FA]. FA = 15 and 16
  ## (lottery taken at a sure 45) are coded at the point r(42) = 10.047.
  if (bibkey == "Hackethal2023"){
    if (task == "CE_staircase") {
      out <- ce_stair_crra(lo = 3 * (choice - 1), hi = 3 * choice, X = 45,
                           top = log(0.5) / log(42 / 45))
    }
  }

  ## Mueller and Rau 2020: the Eckel and Grossman gamble-choice task, five
  ## 50/50 gambles paying 0.80/0.80, 1.20/0.60, 1.60/0.40, 2.00/0.20 and
  ## 2.40/0.00 euro (Table 1 of the paper). That is the canonical Eckel and
  ## Grossman set 16/16, 24/12, 32/8, 40/4, 48/0 times 0.05, and CRRA bounds are
  ## scale-invariant, so the standard bounds apply. The paper's own Table 1
  ## confirms them: it reports the ranges in RRA as 2, 0.67, 0.38 and 0.20,
  ## which on this site's scale r = 1 - RRA are -1, 0.33, 0.62 and 0.80.
  ## Prati and Saucet 2025: part 5 of session 1 is a Gneezy-Potters investment,
  ## 200 cents of endowment, any amount c between 0 and 200 may be invested,
  ## the investment wins with probability 1/3 and is "multiplied by 2.5".
  ##
  ## THE GAMBLE IS NOT THE ONE GNEEZY AND POTTERS RAN, and the difference
  ## flips the sign of its expected value, so the parameters below are not the
  ## ones used for Gneezy1997. Their instructions settle their own case: "your
  ## earnings in the lottery for the round are equal to -X ... and equal to
  ## +2.5X ... Your total earnings for the round are equal to 200 cents (your
  ## starting amount) plus your earnings in the lottery" -- the stake is not
  ## taken out of the endowment, so a win ends at 200 + 2.5X and investing is
  ## favourable. Here the stake is taken out: "le montant que vous choisissez
  ## de ne pas investir sera directement ajoute a votre gain", and a win
  ## returns 2.5c, so a win ends at (200 - c) + 2.5c = 200 + 1.5c, hence
  ## g = 1.5. The 344 realised payoffs confirm it without a single exception,
  ## and 33.1 percent of those who invested won, against the stated third.
  ##
  ## Expected value is therefore 200 - c/6: investing is a losing bet, and any
  ## positive investment implies r > 1. That is not a quirk of this file, it is
  ## what the design implies -- 287 of 344 subjects did invest. The flip side
  ## is that the task cannot separate degrees of risk aversion at all: every
  ## subject with r <= 1 invests nothing and lands on the censored -1 that
  ## ig_crra_pgl gives the lower corner.
  ##
  ## Near zero the inversion is steep -- one cent of 200 implies r = 24 -- so
  ## the value is capped at 10, the same ceiling the BRET blocks use for their
  ## degenerate corner. Ten subjects, all of whom invested three cents or
  ## less, sit on it; the rest run from 1 to 3.3 with a median of 1.23.
  if (bibkey == "Prati2025"){
    if (task == "IG") {
      out <- ig_crra_pgl(choice, X = 200, p = 1/3, g = 1.5, l = 1)
      if (out > 10) { out <- 10 }
    }
  }

  ## Congiu and Moscati 2026: task 3 of the experiment, a Gneezy-Potters
  ## allocation. The instructions give it in full: "You are given 100 tokens.
  ## You must choose how much of this amount you keep for yourself and how much
  ## you invest in a lottery. The money you bet will either be lost or
  ## multiplied by 2.5 depending on the color of a ball drawn at random from a
  ## box. The box contains 100 balls, of which 50 are black and 50 are red."
  ## So the endowment is 100, the probability a half, and a win returns 2.5
  ## times the stake while the stake itself leaves the endowment -- which is
  ## what ig_crra's k already means, the same call used for Adamo2026.
  ##
  ## The realised payoffs confirm the rule on every subject: outcome is 2.5
  ## times the investment, rounded to the token, for the 46.4 percent who won
  ## and zero for the rest.
  ##
  ## Control: the gamble is favourable (half of 1.5 times the stake beats half
  ## of losing it), so a risk-neutral subject invests all 100 tokens, which
  ## ig_crra codes at exactly r = 1. A third of the sample did precisely that.
  if (bibkey == "Congiu2026") {
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 2.5) }
  }

  ## Boulu-Reshef and Holt 2025: before the inventory game each session ran a
  ## Veconlab lottery-choice menu, ten rows in which the probability of the
  ## high prize rises from 0.1 to 1.0. The raw spreadsheet records the menu for
  ## every session, and they are not all the same.
  ##
  ## Four of the six sessions used a safe option of $4.00 or $3.20 against a
  ## risky $7.70 or $0.20, and a fifth used $8.00 or $6.40 against $15.40 or
  ## $0.40. Those are Holt and Laury's own menu at twice and four times scale,
  ## and CRRA bounds are scale-invariant, so the canonical bounds apply to all
  ## sixty of those subjects; they carry the task label HL.
  ##
  ## The sixth session, scqc8, used a different menu: a sure $6.00 against
  ## $12.00 or $2.00. A sure amount against a lottery is this site's CEPL, and
  ## its bounds are solved separately below. Indifference at p = 0.1 ... 0.9
  ## gives RRA -2.2864, -1.2172, -0.5372, 0, 0.4767, 0.9384, 1.4256, 2 and
  ## 2.8303, so on this site's scale r = 1 - RRA the cut points are 3.29, 2.22,
  ## 1.54, 1.00, 0.52, 0.06, -0.43, -1.00 and -1.83.
  ##
  ## Control: in that menu the lottery's expected value equals the sure $6.00
  ## exactly at p = 0.4, the fourth row, so r = 1 falls exactly on the boundary
  ## between six and seven risky choices -- no interpolation needed.
  ##
  ## choice is the number of risky choices in both tasks.
  if (bibkey == "BouluReshef2025") {
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice <= 1) { out <- -0.37 }
    }
    if (task == "CEPL") {
      rk <- c(3.29, 2.22, 1.54, 1.00, 0.52, 0.06, -0.43, -1.00, -1.83)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Lambrecht, Proto, Rustichini and Sofianos 2024: an incentivised
  ## Holt-Laury menu, run in z-Tree before the repeated game. The z-Tree file
  ## in the package is called HL_halved, and the screens it draws give the
  ## amounts: the safe option pays 1.00 or 0.80 euro and the risky one 1.90 or
  ## 0.05, with the high prize at k/10 in row k.
  ##
  ## That is NOT simply Holt and Laury halved -- half of their 3.85 would be
  ## 1.925, and the program rounds it to 1.90 -- so the canonical bounds do not
  ## apply and the indifference condition is solved for these amounts instead.
  ## Rows 1 to 9 give RRA -1.7558, -0.9789, -0.5124, -0.1641, 0.1283, 0.3962,
  ## 0.6633, 0.9599 and 1.3601, which on this site's scale r = 1 - RRA are
  ## 2.76, 1.98, 1.51, 1.16, 0.87, 0.60, 0.34, 0.04 and -0.36. Close to the
  ## canonical set, as the small change in one prize implies, but not equal.
  ##
  ## choice is the number of risky choices, as everywhere else on the site.
  ## Control: the expected values cross at p = 0.4545, so a risk-neutral
  ## subject switches in row 5 and makes six risky choices -- choice 6, whose
  ## interval (0.87, 1.16) brackets r = 1.
  if (bibkey == "Lambrecht2024") {
    if (task == "HL") {
      if (choice == 10) { out <- 2.76 }
      if (choice == 9) { out <- runif(1, min = 1.98, max = 2.76) }
      if (choice == 8) { out <- runif(1, min = 1.51, max = 1.98) }
      if (choice == 7) { out <- runif(1, min = 1.16, max = 1.51) }
      if (choice == 6) { out <- runif(1, min = 0.87, max = 1.16) }
      if (choice == 5) { out <- runif(1, min = 0.60, max = 0.87) }
      if (choice == 4) { out <- runif(1, min = 0.34, max = 0.60) }
      if (choice == 3) { out <- runif(1, min = 0.04, max = 0.34) }
      if (choice == 2) { out <- runif(1, min = -0.36, max = 0.04) }
      if (choice == 1) { out <- -0.36 }
      if (choice == 0) { out <- -0.36 }
    }
  }

  ## Ashraf, Brown, Burris and Vitaku 2023: the Eckel and Grossman gamble
  ## choice, unincentivised, asked once in the Study 2 survey. The package's
  ## readme points to the supplemental materials for the menu, and the Wiley
  ## supporting information prints it verbatim: "Out of the 5 gambles below,
  ## which one do you prefer most?", then 50/50 chances of $10 and $10, $18
  ## and $6, $26 and $2, $34 and -$2, $42 and -$6. Five gambles, not the six
  ## the readme claims, which is why the column never takes the value 6.
  ##
  ## This is the identical set to Babin et al. 2026, down to the numbers, so
  ## the same treatment applies: w^r is undefined at a negative payoff, and
  ## shifting every outcome by the largest possible loss (+6) gives 16/16,
  ## 24/12, 32/8, 40/4, 48/0 -- the standard Eckel and Grossman table, hence
  ## the standard bounds.
  ##
  ## Control: gamble 5 is the all-in one, which sits exactly at r = 1. A second
  ## check comes from the shape of the data. Gamble 4 spans (0.62, 0.80), the
  ## narrowest of the five intervals, so it should be the rarest choice, and it
  ## is: 5.4 percent against 21 to 26 percent for its neighbours.
  if (bibkey == "Ashraf2023"){
    if (task == "EG_loss") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
  }

  ## Alan, Boneva and Ertac 2019: the Gneezy and Potters allocation task, run
  ## at baseline on fourth-graders in Istanbul. The published article only
  ## cites the task, but the same team describes its own version in Alan,
  ## Ertac, Kubilay and Loranth (2020): "Students have 5 tokens corresponding
  ## to gifts from a gift basket, which they can allocate between a risky and
  ## a riskless option. Tokens placed in the risky option ... are either
  ## tripled or lost, with 50% chance. Tokens that are not put in the bowl are
  ## safe." So the endowment is 5 and the multiplier 3, and the published
  ## summary statistics confirm the column is that allocation: Table II of the
  ## grit paper reports risk tolerance at 2.60 and 2.51 in the two arms of
  ## sample 1 and 2.17 and 2.21 in sample 2, which average to the 2.553 and
  ## 2.185 the data give.
  ##
  ## Control: the gamble is actuarially favourable (half of three times the
  ## stake beats the stake), so a risk-neutral child invests all five tokens,
  ## which ig_crra codes at exactly r = 1.
  ## Alan et al. 2020 (8th graders) used the same five-token version.
  if (bibkey == "Alan2019" | bibkey == "Alan2020") {
    if (task == "IG") { out <- ig_crra(choice, X = 5, k = 3) }
  }
  ## van Leeuwen et al. 2020: Gneezy-Potters, 600 points, x2.5 or lost with 50%.
  if (bibkey == "VanLeeuwen2020") {
    if (task == "IG") { out <- ig_crra(choice, X = 600, k = 2.5) }
  }

  ## Tungodden and Willen 2023: the Eckel and Grossman gamble choice, which the
  ## paper calls "an adaptation from Eckel and Grossman 2002". The menu is not
  ## in the published article; the working-paper appendix (CESifo 9516) prints
  ## it as a sure 200 NOK and then 50/50 gambles paying 350 or 50, 400 or 100,
  ## 500 or 50, and 600 or 0.
  ##
  ## The second option as printed is a misprint, and the other four settle what
  ## it must be. 200/200, 400/100, 500/50 and 600/0 are exactly 12.5 times the
  ## canonical Eckel and Grossman set 16/16, 32/8, 40/4 and 48/0; the only
  ## value that fills the gap is 12.5 times 24/12, which is 300/150. Read that
  ## way the ladder is the usual one -- expected values 200, 225, 250, 275, 300
  ## rising by exactly 25, and spreads 0, 150, 300, 450, 600 rising by exactly
  ## 150. Read as printed, both sequences break and, worse, 400/100 pays 50
  ## more than 350/50 in BOTH states, so the second option would be strictly
  ## dominated -- yet 29 percent of the children chose it, and their
  ## self-reported risk willingness sits neatly between that of the first and
  ## third options (4.72, 5.10, 5.86, 6.02, 6.77 across the five). A dominated
  ## option cannot behave like that; a mild gamble does.
  ##
  ## So the set is the canonical one times 12.5, CRRA bounds are
  ## scale-invariant, and the standard Eckel and Grossman bounds apply.
  ## Control: option 5 is the all-in gamble, which sits exactly at r = 1.
  if (bibkey == "Tungodden2023") {
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
  }

  ## Cahlikova, Cingl and Levely 2020: Task 7 of the experiment, described in
  ## the paper as "a series of choices between a lottery, which paid CZK 240
  ## or 0 with 50% probability each, and a safe payment. The safe payment
  ## varied across choices, gradually increasing from CZK 0 to CZK 240 in
  ## steps of CZK 20." Thirteen rows, so twelve switching intervals of width
  ## 20, and the published CertaintyEquivalent column is the midpoint of the
  ## one the subject landed in.
  ##
  ## choice is the row at which the safe payment was first taken, 2 to 13, so
  ## the certainty equivalent lies in (20*(choice-2), 20*(choice-1)) and
  ## ce_stair_crra inverts it as r = log(0.5) / log(CE / 240).
  ##
  ## Control: a sure 120 is the expected value of the lottery, so r = 1 falls
  ## exactly on the boundary between choice 7, (0.830, 1), and choice 8,
  ## (1, 1.237).
  if (bibkey == "Cahlikova2020") {
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 20 * (choice - 2), hi = 20 * (choice - 1),
                           X = 240, p = 0.5, top = NA_real_)
    }
  }

  ## Falk et al. 2023: two 21-row price lists, a sure 0, 50, ..., 1000 points
  ## (the second perturbed by -5 to +5 points) against 1000 points with
  ## probability 0.5 (online appendix A). choice is x_risk_av, the average of
  ## the two first rows in which the sure amount was taken, so x.0 or x.5; the
  ## certainty equivalent lies between the sure amounts of rows floor(x) - 1 and
  ## ceiling(x): 50 * (floor(x) - 2) and 50 * (ceiling(x) - 1). The top cell
  ## takes its lower bound, as for the other lists here.
  if (bibkey == "Falk2023") {
    if (task == "CEPL") {
      lo <- 50 * (floor(choice) - 2)
      out <- ce_stair_crra(lo = lo, hi = 50 * (ceiling(choice) - 1),
                           X = 1000, p = 0.5, top = log(0.5) / log(max(lo, 1) / 1000))
    }
  }

  ## Bjorkman Nyqvist, Corno, de Walque and Svensson 2018: a fifteen-row price
  ## list, reproduced in the package's own crra_data.xlsx. Alternative k pits a
  ## sure 25*(k-1) maloti, so 0, 25, ... , 350, against the same 50/50 lottery
  ## paying 500 or nothing, whose expected value is 250. A sure amount against
  ## a lottery is this site's CEPL.
  ##
  ## choice is the alternative at which the subject first took the sure amount,
  ## 2 to 15, so the certainty equivalent lies between the previous row's sure
  ## amount and this one's, and ce_stair_crra inverts that interval the usual
  ## way: r = log(0.5) / log(CE / 500). The authors' spreadsheet solves the
  ## same indifference and prints it as RRA, which is 1 - r; their "Switch
  ## point" column reads 0.7686, 0.6990, 0.6346, 0.5693, 0.5, 0.4243, 0.3397,
  ## 0.2435, 0.1319, 0, -0.1594, -0.3569, -0.6090 and -0.9434 and is exactly
  ## 1 minus the ends this block produces.
  ##
  ## Control: alternative 11 offers a sure 250, the expected value of the
  ## lottery, so a risk-neutral subject is indifferent there. The block puts
  ## the boundary between choice 11, (0.868, 1), and choice 12, (1, 1.159),
  ## at exactly r = 1.
  if (bibkey == "BjorkmanNyqvist2018") {
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 25 * (choice - 2), hi = 25 * (choice - 1),
                           X = 500, p = 0.5, top = NA_real_)
    }
  }

  ## Novak, Matveenko and Ravaioli 2024: the final questionnaire of the
  ## experiment opened with a paid eleven-row price list, recovered from the
  ## per-subject session files. LotteryAmounts is [2.00, 1.75, 4.00, 0.10] and
  ## hl_text_left_words / hl_text_right_words spell the menu out: row k offers
  ## (k-1)/10 of $2.00 against the rest at $1.75 on the left, and the same
  ## probability of $4.00 against $0.10 on the right. So it is Holt and Laury's
  ## shape on its own prizes -- their own low safe prize is 1.60 and high risky
  ## prize 3.85 -- and the bounds have to be solved rather than copied. Doing so
  ## for p = 0.1 ... 0.9 gives RRA -1.8396, -1.0166, -0.5256, -0.1624, 0.1396,
  ## 0.4137, 0.6847, 0.9833 and 1.3832, which on this site's scale r = 1 - RRA
  ## are 2.84, 2.02, 1.53, 1.16, 0.86, 0.59, 0.32, 0.02 and -0.38.
  ##
  ## choice is the number of risky choices, as everywhere else on the site. The
  ## menu has eleven rows rather than ten because it starts at p = 0, where
  ## $1.75 for sure dominates $0.10 for sure, so both ends are dominance checks
  ## and the nine interior boundaries are the same ones a ten-row menu would
  ## give: a subject who first takes the risky side in row j is indifferent
  ## somewhere in ((j-2)/10, (j-1)/10), exactly as in the canonical block.
  ## choice 11 and 10 collapse on the top point and choice 1 and 0 on the
  ## bottom one, the same convention the canonical Holt-Laury block uses.
  ##
  ## Control: the expected values cross at p = 0.4521, so a risk-neutral
  ## subject takes the safe side through row 5 and the risky side from row 6,
  ## which is six risky choices -- choice 6, whose interval (0.86, 1.16)
  ## brackets r = 1.
  if (bibkey == "Novak2024") {
    if (task == "HL") {
      if (choice == 11) { out <- 2.84 }
      if (choice == 10) { out <- 2.84 }
      if (choice == 9) { out <- runif(1, min = 2.02, max = 2.84) }
      if (choice == 8) { out <- runif(1, min = 1.53, max = 2.02) }
      if (choice == 7) { out <- runif(1, min = 1.16, max = 1.53) }
      if (choice == 6) { out <- runif(1, min = 0.86, max = 1.16) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.86) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.02, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.38, max = 0.02) }
      if (choice == 1) { out <- -0.38 }
      if (choice == 0) { out <- -0.38 }
    }
  }

  ## Wang 2026: ten Holt-Laury rows, which the paper itself describes as "ten
  ## Holt-Laury (HL, 2002) binary lottery choices with 2x the baseline payoff
  ## scale of theirs". The screenshot the author sent confirms it: the safe
  ## lottery pays $4.00 or $3.20 and the risky one $7.70 or $0.20, against
  ## Holt and Laury's own 2.00/1.60 and 3.85/0.10, and the probability of the
  ## high prize runs 0.1, 0.2, ... , 1.0 down the menu. CRRA bounds are
  ## scale-invariant, so the canonical bounds apply, and solving the
  ## indifference condition for these payoffs returns them to the digit:
  ## rows 1 to 9 give RRA -1.7128, -0.9468, -0.4866, -0.1426, 0.1464, 0.4115,
  ## 0.6762, 0.9706 and 1.3684, which on this site's scale r = 1 - RRA are
  ## 2.71, 1.95, 1.49, 1.15, 0.85, 0.59, 0.32, 0.03 and -0.37.
  ## choice is the number of risky choices, as everywhere else on the site.
  ## Control: the expected values cross at p = 0.4478, so a risk-neutral
  ## subject switches in row 5 and makes six risky choices -- choice 6, whose
  ## interval (0.85, 1.15) brackets r = 1 exactly as it should.
  if (bibkey == "Wang2026") {
    if (task == "HL") {
      if (choice == 10) { out <- 2.71   }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }

  if (bibkey == "Mueller2020"){
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
  }

  ## Bittner et al. 2024: the staircase of the Global Preferences Survey as a
  ## survey item, five choices between a sure amount and a lottery paying X with
  ## probability 1/2, else nothing (Falk et al.). Five bisections give 32
  ## outcomes, and the paper counts them as such ("an additional switching row
  ## (out of 32)"). The same instrument is already on this site twice: four
  ## choices and 16 outcomes for Hackethal2023, five choices and 32 for
  ## Schmidt2025, and in both the sure amounts span 1.0667 * X, so an outcome of
  ## 32 steps is one of width X/30.
  ##
  ## The amounts themselves are never needed: r = log(0.5) / log(CE / X) depends
  ## only on CE/X, so the Chinese, American and German versions give the same
  ## bounds. X = 300 with steps of 10 is used below because that is the wording
  ## of the GPS itself. Control: the risk-neutral CE is 150, the border between
  ## outcomes 15 and 16, and r there comes out at exactly 1.
  ##
  ## Nine subjects land on an interval that reaches the lottery amount; as for
  ## Hackethal and Schmidt they are held at the r of its lowest CE.
  if (bibkey == "Bittner2024"){
    if (task == "CE_staircase") {
      out <- ce_stair_crra(lo = 10 * (choice - 1), hi = 10 * choice, X = 300,
                           top = log(0.5) / log(290 / 300))
    }
  }

  ## Bauer et al. 2020: the same GPS staircase in Kenyan shillings, every amount
  ## times 3 (lottery 900, sure amounts 30 ... 930), so the bounds are Bittner's.
  ## CEPL: KSh 2,000 with 50% (else 0) against sure amounts 0, 100, ..., 2,000;
  ## choice = first row with the sure amount (2 ... 22), so the CE lies in
  ## [100 (choice - 2), 100 (choice - 1)]. Intervals reaching 2,000 (choice 21
  ## and 22, the lottery over every sure amount) are coded at r(1,900).
  if (bibkey == "Bauer2020"){
    if (task == "CE_staircase") {
      out <- ce_stair_crra(lo = 30 * (choice - 1), hi = 30 * choice, X = 900,
                           top = log(0.5) / log(870 / 900))
    }
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 100 * (choice - 2), hi = 100 * (choice - 1), X = 2000,
                           top = log(0.5) / log(1900 / 2000))
    }
  }

  ## Schmidt 2025.
  ## EG: eight 50/50 lotteries 8/8, 7/10, 6/12, 5/14, 4/16, 3/18, 2/20, 1/21.
  ## Bounds make adjacent lotteries indifferent; 7 and 8 have the same expected
  ## value, hence the bound of 1. The extremes are coded at their bound, as for
  ## Eckel2025.
  ## IG: endowment 8 EUR, 2.5-fold with 50%.
  ## CE_staircase: Falk et al. 2023 staircase, five choices between a sure amount
  ## and 15 EUR with 50% (else 0); sure amounts 8, then +-4, +-2, +-1, +-0.5.
  ## choice = (staircase5 - 0.25) / 0.5 (0 ... 31): the CE lies in
  ## [0.5 choice, 0.5 choice + 0.5]. Intervals reaching 15 are coded at r(14.5).
  if (bibkey == "Schmidt2025"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.944 }
      if (choice == 2) { out <- runif(1, min = -2.944, max = -0.320)}
      if (choice == 3) { out <- runif(1, min = -0.320, max = 0.195)}
      if (choice == 4) { out <- runif(1, min = 0.195, max = 0.425)}
      if (choice == 5) { out <- runif(1, min = 0.425, max = 0.563)}
      if (choice == 6) { out <- runif(1, min = 0.563, max = 0.660)}
      if (choice == 7) { out <- runif(1, min = 0.660, max = 1)}
      if (choice == 8) { out <- 1}
    }
    if (task == "IG") { out <- ig_crra(choice, X = 8, k = 2.5) }
    if (task == "CE_staircase") {
      out <- ce_stair_crra(lo = 0.5 * choice, hi = 0.5 * choice + 0.5, X = 15,
                           top = log(0.5) / log(14.5 / 15))
    }
  }

  ## Aydogan et al. 2024: CE of a bet paying 20 EUR with 50% (else 0), from a
  ## list of sure amounts 0, 0.5, 1.5, ..., 19.5, 20. choice = number of the CE
  ## interval: 0 = [0, 0.5], i = [i - 0.5, i + 0.5], 20 = [19.5, 20]. The CE
  ## interval is inverted with ce_stair_crra (r = log(0.5) / log(CE / 20) at both
  ## ends); the top interval reaches 20 and is coded at r(19.5) = 27.38.
  if (bibkey == "Aydogan2024"){
    if (task == "CEPL") {
      lo <- if (choice == 0) 0 else choice - 0.5
      hi <- if (choice == 0) 0.5 else min(choice + 0.5, 20)
      out <- ce_stair_crra(lo = lo, hi = hi, X = 20,
                           top = log(0.5) / log(19.5 / 20))
    }
  }

  ## Bettega et al. 2025: static BART, 1 ... 64 pumps chosen in advance, burst
  ## point uniform on 1 ... 64, so as for Frey2017 r = choice / (64 - choice);
  ## choice is the mean over rounds 1-5. Always choosing 64 (r infinite) is
  ## coded at 10, as the 100-box BRET is for Crosetto2016.
  if (bibkey == "Bettega2025"){
    if (task == "BART") {
      if (choice >= 64) { out <- 10 } else { out <- choice/(64-choice) }
    }
  }

  ## Fornwagner 2026: Gneezy-Potters investment, endowment 0.50 GBP, 2.5-fold.
  if (bibkey == "Fornwagner2026"){
    if (task == "IG") { out <- ig_crra(choice, X = 0.5, k = 2.5) }
  }

  ## Horn, Kiss and Lenard 2022: the 100-box BRET (Crosetto and Filippin 2013),
  ## the same rule as Crosetto2016 and Bruhin2024. The authors set 100 boxes to
  ## missing, so the 100 case does not occur.
  if (bibkey == "Horn2022"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## Tatarnikova et al. 2026: BRET with 100 boxes
  if (bibkey == "Tatarnikova2026"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## Fonseca & McCrea 2025: BRET with 100 boxes
  if (bibkey == "Fonseca2025"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## Flambard et al. 2024: Holt-Laury list with A = 8.5 / 6.8 and B = 16 / 0.5 EUR,
  ## the high outcome with probability k/10 in row k. Indifference in row k gives
  ## r_k = 2.787, 2.001, 1.528, 1.173, 0.875, 0.600, 0.324, 0.017, -0.400 (k = 1..9),
  ## close to the standard table. choice = number of B choices: n risky choices put
  ## r between r_(11-n) and r_(10-n); 10 is coded at r_1, 0 and 1 at r_9.
  if (bibkey == "Flambard2024"){
    if (task == "HL") {
      rk <- c(2.787, 2.001, 1.528, 1.173, 0.875, 0.600, 0.324, 0.017, -0.400)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Chapman et al. 2025: CE of a 50/50 lottery of 5000 or 0 points from a list
  ## of sure amounts; choice = first row with the sure amount (2 ... 19), whose CE
  ## interval is given by the authors (lo / hi below). r = log(0.5) / log(CE / 5000)
  ## at both ends (ce_stair_crra). Row 2 ([-500, 0], lottery refused even against
  ## nothing) is coded at 0; rows 18-19 reach 5000 and are coded at r(4500) = 6.579.
  if (bibkey == "Chapman2025"){
    if (task == "CEPL") {
      lo <- c(-500, 0, 500, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000,
              3250, 3500, 3750, 4000, 4500, 5000)[choice - 1]
      hi <- c(0, 500, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3250,
              3500, 3750, 4000, 4500, 5000, 5500)[choice - 1]
      if (hi <= 0) { out <- 0 } else {
        out <- ce_stair_crra(lo = max(lo, 0), hi = hi, X = 5000,
                             top = log(0.5) / log(4500 / 5000))
      }
    }
  }

  ## Di Falco and Vieider 2022: CE of a 50/50 prospect of 120 birr or 0 (20 / 0 in
  ## file units), list of sure amounts in steps of 3 birr (0.5 units). choice =
  ## interval number 0 ... 39, CE in [0.5 choice, 0.5 choice + 0.5]; r = log(0.5) /
  ## log(CE / 20) at both ends. The top interval [19.5, 20] is coded at r(19.5) = 27.38.
  ## Hefti et al. 2025: sure 0 ... 19 CHF against 30 / 0 CHF at 50%; choice = number
  ## of rows (from the top) in which the lottery was taken, CE in [choice - 1, choice]
  if (bibkey == "Hefti2025"){
    if (task == "CEPL") {
      ## 20 = lottery in every row, CE above 19 CHF: coded at that bound
      if (choice == 20) { out <- log(0.5) / log(19 / 30) } else {
        out <- ce_stair_crra(lo = choice - 1, hi = choice, X = 30,
                             top = log(0.5) / log(19 / 30))
      }
    }
  }

  ## Halim et al. 2025: 1 SGD for sure against 3 SGD with probability (k - 1) / 10 in
  ## row k. A is kept while p <= 3^(-r), so switching point k (A in row k - 1, B in
  ## row k) gives r between log(10 / (k - 1)) / log(3) and log(10 / (k - 2)) / log(3);
  ## 2 and 11 are open-ended and coded at their bound.
  ## Halim et al. 2019 ran the same list in the same lab.
  ## Buser, Van Veldhuizen and Zhong 2025: 11 rows, a sure EUR 4 or a lottery
  ## paying EUR 6 with probability (row - 1)/10 and EUR 2 otherwise. choice = rows
  ## where the lottery was taken (all single switchers; the dominated 0 and 11 are
  ## dropped in clean_data.R), so the switch lies at a probability p of EUR 6 in
  ## ((10 - choice)/10, (11 - choice)/10]. Indifference u(4) = p u(6) + (1 - p) u(2)
  ## under CRRA gives r = 5.634, 3.826, 2.685, 1.790, 1.000, 0.239, -0.559,
  ## -1.495, -2.839 at p = 0.1 ... 0.9; r falls as p rises. The open ends
  ## (choice 1 and 10) take the bound.
  if (bibkey == "BuserVanVeldhuizen2025"){
    if (task == "CEPL") {
      rp <- c(5.634, 3.826, 2.685, 1.790, 1.000, 0.239, -0.559, -1.495, -2.839)
      if (choice == 1)  { out <- rp[9] }
      if (choice == 10) { out <- rp[1] }
      if (choice > 1 & choice < 10) { out <- runif(1, min = rp[11 - choice], max = rp[10 - choice]) }
    }
  }

  ## Fornwagner et al. 2023: Holt-Laury list with A = GBP 2.20 / 1.75 and
  ## B = 4.20 / 0.10, the high payoff with probability k/10 in row k. Indifference
  ## in row k gives rk[k] (CRRA, log at r = 0); choice = number of B choices
  ## (single switchers, 1 ... 10), as for Flambard2024.
  if (bibkey == "Fornwagner2023"){
    if (task == "HL") {
      rk <- c(2.725, 1.958, 1.498, 1.154, 0.867, 0.604, 0.342, 0.052, -0.339)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Chaturvedi and Kanjilal 2021: Holt-Laury list with A = INR 80 / 64 and
  ## B = 140 / 4, the high payoff with probability k/10 in row k; rk as for
  ## Fornwagner2023.
  if (bibkey == "Chaturvedi2021"){
    if (task == "HL") {
      rk <- c(3.061, 2.207, 1.696, 1.317, 1.000, 0.712, 0.428, 0.115, -0.301)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Mahmoud 2022: CE of a 50/50 lottery of CHF 5 or 0 from sure amounts CHF 0.50,
  ## 1, ..., 5; choice = number of sure amounts against which the lottery was
  ## taken (0 ... 9), so the CE lies in [0.5 choice, 0.5 (choice + 1)].
  ## choice 9 reaches CHF 5 and is coded at r(4.5).
  if (bibkey == "Mahmoud2022"){
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 0.5 * choice, hi = 0.5 * (choice + 1), X = 5,
                           top = log(0.5) / log(4.5 / 5))
    }
  }

  ## Kirchler et al. 2018 (students): CE of a 50/50 lottery of EUR 8 or 0 from
  ## sure amounts EUR 1, 2, ..., 7; choice = number of sure amounts against which
  ## the lottery was taken (0 ... 7), so the CE lies in [choice, choice + 1].
  ## choice 7 reaches EUR 8 and is coded at r(7).
  if (bibkey == "Kirchler2018"){
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = choice, hi = choice + 1, X = 8,
                           top = log(0.5) / log(7 / 8))
    }
  }

  ## Siddique and Vlassopoulos 2020: Gneezy-Potters, 20 taka, six times the amount
  ## invested or lost with 50%.
  if (bibkey == "Siddique2020"){
    if (task == "IG") { out <- ig_crra(choice, X = 20, k = 6) }
  }

  ## Schaap 2021: Gneezy-Potters, 6 points, tripled or lost with 50%.
  ## Zhang 2019: Gneezy-Potters, USD 5 in steps of 0.50, tripled or lost with 50%.
  if (bibkey == "Schaap2021"){
    if (task == "IG") { out <- ig_crra(choice, X = 6, k = 3) }
  }
  if (bibkey == "Zhang2019"){
    if (task == "IG") { out <- ig_crra(choice, X = 5, k = 3) }
  }

  ## Boschini et al. 2019: SEK 200 or 0 with 50% against sure SEK 40, 60, ..., 160;
  ## choice = number of rows with the lottery (single switchers, 0 ... 7), so the
  ## CE lies between the last sure amount refused and the first one taken:
  ## [0, 40] for choice 0, [40, 60] for 1, ..., [160, 200] for 7 (coded at r(160)).
  if (bibkey == "Boschini2019"){
    if (task == "CEPL") {
      ends <- c(0, 40, 60, 80, 100, 120, 140, 160, 200)
      out <- ce_stair_crra(lo = ends[choice + 1], hi = ends[choice + 2], X = 200,
                           top = log(0.5) / log(160 / 200))
    }
  }

  ## Gortner and van der Weele 2019: BRET with 36 boxes; collecting k boxes is
  ## optimal for r = k / (36 - k), as for the 100-box version.
  if (bibkey == "Gortner2019"){
    if (task == "BRET") { out <- choice / (36 - choice) }
  }

  ## Riyanto and Teh 2020: a sure 20 ECU (A) or 60 ECU with probability p (B),
  ## p = 0, 0.1, ..., 0.9 down ten rows, one switch from A to B. choice = number of
  ## B choices (1 ... 10), so s = 10 - choice rows of A and the switch lies at
  ## p* in ((s - 1)/10, s/10]. With u = x^r, 20^r = p 60^r gives r = log(p) / log(1/3),
  ## which falls as p rises. choice 9 (B from p = 0.1) is open above and coded at
  ## r(0.1); choice 0 (A even at p = 0.9) is drawn in [0, r(0.9)].
  if (bibkey == "Riyanto2020"){
    if (task == "CEPL") {
      s <- 10 - choice
      if (s == 1) { out <- log(0.1) / log(1/3) }
      if (s == 10) { out <- runif(1, min = 0, max = log(0.9) / log(1/3)) }
      if (s > 1 & s < 10) { out <- runif(1, min = log(s / 10) / log(1/3), max = log((s - 1) / 10) / log(1/3)) }
    }
  }

  if (bibkey == "Halim2025" | bibkey == "Halim2019"){
    if (task == "CEPL") {
      if (choice == 2)  { out <- log(10) / log(3) }
      if (choice == 11) { out <- log(10 / 9) / log(3) }
      if (choice > 2 & choice < 11) {
        out <- runif(1, min = log(10 / (choice - 1)) / log(3),
                        max = log(10 / (choice - 2)) / log(3))
      }
    }
  }

  if (bibkey == "DiFalco2022"){
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 0.5 * choice, hi = 0.5 * choice + 0.5, X = 20,
                           top = log(0.5) / log(19.5 / 20))
    }
  }

  ## Finger et al. 2023: Holt-Laury list with A = 105 / 84 and B = 200 / 6 CHF, the
  ## high outcome with probability k/10 in row k. Indifference in row k gives
  ## r_k = 2.747, 1.972, 1.504, 1.155, 0.860, 0.588, 0.316, 0.013, -0.399 (k = 1..9).
  ## choice = number of B choices (single switchers only, 1 ... 9): r between
  ## r_(11-choice) and r_(10-choice), as for Flambard2024.
  ## Marini Govigli et al. 2026: Holt-Laury list with A = 100 / 80 and B = 190 / 5
  ## tokens, the high prize with probability k/10 in row k. Indifference in row k
  ## gives rk[k] (u = x^r, log at 0, -x^r below)
  if (bibkey == "MariniGovigli2026"){
    if (task == "HL") {
      rk <- c(2.756, 1.979, 1.512, 1.164, 0.872, 0.604, 0.337, 0.040, -0.360)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Morrison & Oxoby 2022: 20 CAD for sure against 35 CAD with probability k/10,
  ## else 3.50 CAD, in row k. A is kept while 20^r >= p 35^r + (1 - p) 3.5^r;
  ## rk[k] is the r of indifference at p = k/10 (u = x^r, log at 0, -x^r below).
  ## choice = number of B choices, coded as a Holt-Laury count.
  if (bibkey == "Morrison2022"){
    if (task == "CEPL") {
      rk <- c(4.113, 2.866, 2.120, 1.566, 1.103, 0.680, 0.257, -0.213, -0.852)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Mesfin et al. 2023: 30 ETB, the invested amount doubles or halves with
  ## probability 1/2 (g = 1, l = 0.5)
  if (bibkey == "Mesfin2023"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 30, p = 0.5, g = 1, l = 0.5) }
  }

  ## Alfonso et al. 2025: hypothetical Holt-Laury list in six rows, A = 10 / 8 and
  ## B = 20 / 2 EUR, the high prize with probability (k - 1) / 5 in row k. rk holds
  ## the r of indifference at p = 0.2, 0.4, 0.6, 0.8 (u = x^r, log at 0, -x^r below);
  ## choice = number of B choices of a consistent subject (1 to 5)
  if (bibkey == "Alfonso2025"){
    if (task == "HL") {
      rk <- c(1.790, 0.909, 0.230, -0.535)
      if (choice >= 5) { out <- rk[1] }
      if (choice >= 2 & choice <= 4) { out <- runif(1, min = rk[6 - choice], max = rk[5 - choice]) }
      if (choice <= 1) { out <- rk[4] }
    }
  }

  ## Roig et al. 2025: BART with the explosion point uniform on 1 ... 116, so as
  ## for Frey2017 r = choice / (116 - choice); choice is the adjusted average.
  if (bibkey == "Roig2025"){
    if (task == "BART") { out <- choice/(116-choice) }
  }

  ## Kevane 2020: six 50/50 gambles in CFA francs, 1000/1000, 1300/900,
  ## 1600/800, 1900/600, 2200/500, 2500/100. CRRA r making neighbours equal:
  ## 1-2 -5.327, 2-3 -1.071, 3-5 0.359, 5-6 1.135. Gamble 4 is never best
  ## (3-4 at 0.559 lies above 4-5 at 0.166), so 3 is best on (-1.071, 0.359)
  ## and 5 on (0.359, 1.135); a choice of 4 is placed between the two, on
  ## (0.166, 0.559), the range where it is beaten by only one of them.
  ## Gamble 6 has a lower expected value than 5 and is coded at its bound.
  if (bibkey == "Kevane2020"){
    if (task == "EG") {
      if (choice == 1) { out <- -5.327 }
      if (choice == 2) { out <- runif(1, min = -5.327, max = -1.071) }
      if (choice == 3) { out <- runif(1, min = -1.071, max = 0.359) }
      if (choice == 4) { out <- runif(1, min = 0.166, max = 0.559) }
      if (choice == 5) { out <- runif(1, min = 0.359, max = 1.135) }
      if (choice == 6) { out <- 1.135 }
    }
  }

  ## Woerner et al. 2025: Gneezy-Potters investment, EUR 40, 2.5-fold.
  if (bibkey == "Woerner2025"){
    if (task == "IG") { out <- ig_crra(choice, X = 40, k = 2.5) }
  }

  ## Balafoutas et al. 2024: Gneezy-Potters investment, 100 units, the invested
  ## part returns three times its amount with probability 1/2.
  if (bibkey == "Balafoutas2024"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 3) }
  }

  ## Agranov and Buyalskaya 2022: first of the two investment tasks, 200 points,
  ## 2.5-fold with probability 1/2.
  if (bibkey == "Agranov2022"){
    if (task == "IG") { out <- ig_crra(choice, X = 200, k = 2.5) }
  }

  ## Corgnet et al. 2022: BRET with 49 boxes, so as for Crosetto2016 with N = 49;
  ## collecting all 49 (r infinite) would be coded at 10, but nobody did.
  if (bibkey == "Corgnet2022"){
    if (task == "BRET") {
      if (choice >= 49) { out <- 10 } else { out <- choice/(49-choice) }
    }
  }

  ## Duffy et al. 2024: Holt-Laury at twice the original stakes (A 4 / 3.20,
  ## B 7.70 / 0.20), so the original bounds apply; rk[k] is the r of
  ## indifference at p = k/10. choice = number of B choices.
  if (bibkey == "Duffy2024"){
    if (task == "HL") {
      rk <- c(2.713, 1.947, 1.487, 1.143, 0.854, 0.589, 0.324, 0.029, -0.368)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Beil et al. 2026: a fixed 500 + 500k ECU against 6,000 or 1,000 ECU at 1/2,
  ## k = 1 ... 10. b[j] is the r at which the fixed 1,000 + 500j equals the
  ## lottery (0.5 * 6000^r + 0.5 * 1000^r = s^r). choice = number of lottery
  ## choices, taken in the first rows: lottery at row choice and fixed at row
  ## choice + 1 put r between b[choice - 1] and b[choice]. Taking the lottery in
  ## every row is coded at the top bound, taking it only against the dominated
  ## 1,000 at the bottom one. A risk-neutral subject takes it five times, r 0.52
  ## to 1.
  if (bibkey == "Beil2026"){
    if (task == "CEPL") {
      b <- c(-1.564, -0.523, 0.051, 0.523, 1.000, 1.564, 2.359, 3.796, 7.966)
      if (choice >= 10) { out <- b[9] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = b[choice - 1], max = b[choice]) }
      if (choice <= 1) { out <- b[1] }
    }
  }

  ## Guo and Recalde 2023: a 50-50 lottery between 1 and 2 against 3 with
  ## probability q, q = 5, 10, 20, 25, 30, 40, 50, 60, 70, 75, 80, 90, 95% in rows
  ## 1-13. bq[j] solves 0.5 + 0.5 * 2^r = q_j * 3^r: B is taken in row j when
  ## r > bq[j]. choice = number of B choices, so the switch is at row 14 - choice
  ## and r lies between bq[14 - choice] and bq[13 - choice]. B in every row is
  ## coded at bq[1], never B at bq[13]. Risk neutrality switches at q = 50%.
  if (bibkey == "Guo2023"){
    if (task == "CEPL") {
      bq <- c(5.725, 4.108, 2.629, 2.196, 1.860, 1.361, 1.000, 0.720, 0.494,
              0.395, 0.304, 0.142, 0.069)
      if (choice >= 13) { out <- bq[1] }
      if (choice >= 1 & choice <= 12) { out <- runif(1, min = bq[14 - choice], max = bq[13 - choice]) }
      if (choice <= 0) { out <- bq[13] }
    }
  }

  ## Ifcher and Zarghamee 2024: USD 0 ... 10 for sure against 10 or 0 at 1/2.
  ## choice = the first sure amount taken, so the certainty equivalent is in
  ## (choice - 1, choice) and the staircase inversion applies; a switch at 10
  ## (CE between 9 and 10) is coded at the r of CE = 9, 6.579.
  if (bibkey == "Ifcher2024"){
    if (task == "CEPL") { out <- ce_stair_crra(lo = choice - 1, hi = choice, X = 10, p = 0.5, top = 6.579) }
  }

  ## Schwerter 2024: a sure 3 EUR against X_k with probability p_k, else 0,
  ## k = 1 ... 20 (3.40 at 97% ... 16.23 at 2%). b[k] = log(p_k) / log(3 / X_k)
  ## is the r at which 3^r = p_k X_k^r; the lottery is taken in row k when r >
  ## b[k]. choice = the row where the subject moves to the sure 3 EUR, so r lies
  ## between b[choice - 1] and b[choice]; moving at row 1 is coded at b[1],
  ## never moving (21) at b[20]. Risk neutrality moves at row 16.
  if (bibkey == "Schwerter2024"){
    if (task == "CEPL") {
      b <- c(0.243, 0.271, 0.302, 0.334, 0.368, 0.403, 0.440, 0.479, 0.522, 0.568,
             0.619, 0.676, 0.740, 0.813, 0.900, 1.005, 1.140, 1.324, 1.615, 2.317)
      if (choice <= 1) { out <- b[1] }
      if (choice >= 2 & choice <= 20) { out <- runif(1, min = b[choice - 1], max = b[choice]) }
      if (choice >= 21) { out <- b[20] }
    }
  }

  ## Hoyer et al. 2023: 10 EUR or 0 with probability 1/2 against 0, 1, ..., 10
  ## EUR for sure, the menu of Ifcher2024; choice = the first sure amount
  ## taken, so the certainty equivalent lies in (choice - 1, choice).
  if (bibkey == "Hoyer2023"){
    if (task == "CEPL") { out <- ce_stair_crra(lo = choice - 1, hi = choice, X = 10, p = 0.5, top = 6.579) }
  }

  ## Jaspersen et al. 2026: 20 EUR or 0 with probability 1/2 against a sure 1,
  ## 2, ..., 19 EUR; choice = the first sure amount taken, so the certainty
  ## equivalent lies in (choice - 1, choice). choice 20 (lottery in all 19 rows,
  ## CE above 19 EUR) is coded at r(19) = log(0.5) / log(19 / 20) = 13.513.
  if (bibkey == "Jaspersen2026"){
    if (task == "CEPL") { out <- ce_stair_crra(lo = choice - 1, hi = choice, X = 20, p = 0.5, top = 13.513) }
  }

  ## Kocher et al. 2019: 0.20 or 4.20 EUR with probability 1/2 against a sure
  ## 0.60, 1.00, ..., 4.20 EUR. b[j] is the r at which the certainty equivalent
  ## of the lottery, (0.5 * 0.2^r + 0.5 * 4.2^r)^(1/r), equals the sure amount of
  ## row j (j = 1 ... 9; row 5 is the expected value, r = 1). choice = the row
  ## of the first sure amount taken, so r lies in (b[choice - 1], b[choice]);
  ## the open ends, rows 1 and 10, take the bound.
  if (bibkey == "Kocher2019"){
    if (task == "CEPL") {
      b <- c(-0.386, 0.075, 0.386, 0.676, 1.000, 1.418, 2.054, 3.280, 6.926)
      if (choice <= 1) { out <- b[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = b[choice - 1], max = b[choice]) }
      if (choice >= 10) { out <- b[9] }
    }
  }

  ## Li et al. 2026: Gneezy-Potters with 5 SGD; the bet is lost with probability
  ## 2/3 and returned 2.5 times with probability 1/3; choice = SGD bet
  if (bibkey == "Li2026"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 5, p = 1/3, g = 2.5, l = 1) }
  }

  ## Chen et al. 2019: Holt-Laury list with A = 30 / 17 and B = 40 / 1 CNY, the
  ## high prize with probability k/10 in row k. rk[k] is the r of indifference at
  ## p = k/10 (u = x^r, log at 0, -x^r below); choice = number of B choices,
  ## coded as a Holt-Laury count. A risk-neutral subject switches between rows 6
  ## and 7.
  if (bibkey == "Chen2019"){
    if (task == "HL") {
      rk <- c(3.168, 2.424, 1.967, 1.617, 1.319, 1.042, 0.764, 0.455, 0.043)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Zheng & Zhou 2025: the price of a ticket paying 10 EUR with probability 1/2,
  ## else 0, at 0.50, 1.00, ..., 10.00 EUR; choice = the first row where the
  ## ticket was not bought, so the certainty equivalent lies in
  ## (0.5 (choice - 1), 0.5 choice). Row 20 (CE between 9.50 and 10) is coded at
  ## r(9.5) = log(0.5) / log(9.5 / 10) = 13.513.
  if (bibkey == "Zheng2025"){
    if (task == "CEPL") { out <- ce_stair_crra(lo = 0.5 * (choice - 1), hi = 0.5 * choice, X = 10, p = 0.5, top = 13.513) }
  }

  ## Maggian et al. 2020: static BRET with 100 boxes; stopping at k boxes is
  ## rationalised by r = k / (100 - k)
  if (bibkey == "Maggian2020"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## Diederich et al. 2022: Eckel-Grossman with the original amounts / 100,
  ## 0.28/0.28 ... 0.02/0.70 USD at 50/50; the same bounds as Charness2019 (the
  ## authors' CRRA categories 3.46, 1.16, 0.71, 0.50, 0 as r = 1 - rho). Gambles 5
  ## and 6 have the same expected value, so gamble 6 takes r = 1.
  if (bibkey == "Diederich2022"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.45 }
      if (choice == 2) { out <- runif(1, min = -2.45, max = -0.16)}
      if (choice == 3) { out <- runif(1, min = -0.16, max = 0.29)}
      if (choice == 4) { out <- runif(1, min = 0.29, max = 0.50)}
      if (choice == 5) { out <- runif(1, min = 0.50, max = 1)}
      if (choice == 6) { out <- 1}
    }
  }

  ## Baik, Chowdhury and Ramalingam 2021: not the Eckel-Grossman (2008) table
  ## but that table shifted down by 8 tokens, with a loss in the last gamble:
  ## 20/20, 16/28, 12/36, 8/44, 4/52, -2/58 tokens, 50/50 (Appendix,
  ## Instructions - Part 1, of the accepted manuscript, White Rose eprint
  ## 192123). Expected values 20, 22, 24, 26, 28, 28. Adding the largest loss,
  ## 2, as for the other EG_loss menus: 22/22, 18/30, 14/38, 10/46, 6/54, 0/60.
  ## Indifference between neighbours under u = x^r at -1.732, 0.081, 0.449,
  ## 0.624 and exactly 1 (gambles 5 and 6 have the same expected value).
  if (bibkey == "Baik2021"){
    if (task == "EG_loss") {
      bk <- c(-1.732, 0.081, 0.449, 0.624, 1)
      if (choice == 1) { out <- bk[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = bk[choice - 1], max = bk[choice]) }
      if (choice == 6) { out <- bk[5] }
    }
  }

  ## Jaspersen, Ragin & Sydnor 2022, table CP: a sure 2.00 USD against x with
  ## probability 0.2, else 1.00 USD, x = 2.50, 4.50, ..., 60 in 16 rows. rk[k] is
  ## the r at which the sure 2.00 and the lottery of row k are equally good
  ## (u = x^r, log at 0, -x^r below); the sure amount is kept while r < rk[k].
  ## choice = number of rows with the sure amount, so r lies in
  ## (rk[choice + 1], rk[choice]); never taking it is coded at rk[1], always
  ## taking it at rk[16]. Risk neutrality is indifferent in row 6 (x = 6).
  if (bibkey == "Jaspersen2022"){
    if (task == "CEPL") {
      rk <- c(7.188, 1.610, 1.465, 1.343, 1.148, 1.000, 0.883, 0.788, 0.643, 0.537,
              0.457, 0.341, 0.230, 0.122, 0.014, -0.102)
      if (choice <= 0) { out <- rk[1] }
      if (choice >= 1 & choice <= 15) { out <- runif(1, min = rk[choice + 1], max = rk[choice]) }
      if (choice >= 16) { out <- rk[16] }
    }
  }

  if (bibkey == "Finger2023"){
    if (task == "HL") {
      rk <- c(2.747, 1.972, 1.504, 1.155, 0.860, 0.588, 0.316, 0.013, -0.399)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Coerts et al. 2026: eleven 50/50 lotteries 28/28, 32/26, 36/24, 40/22, 44/20,
  ## 48/18, 52/16, 56/14, 60/12, 65/7, 70/2. Bounds make adjacent lotteries
  ## indifferent; lotteries 9, 10 and 11 share the expected value 36, hence the
  ## bounds of 1. Lottery 1 is coded at its bound, 10 and 11 at 1, as for Eckel2025.
  ## Priebe et al. 2024: six 50/50 gambles 130/130, 115/155, 100/180, 85/205, 70/230,
  ## 20/280 (thousand VND). Bounds make adjacent gambles indifferent; 5 and 6 share
  ## the expected value 150, hence the bound of 1. Gamble 1 is coded at its bound,
  ## 6 at 1, as for Coerts2026.
  if (bibkey == "Priebe2024"){
    if (task == "EG") {
      b <- c(-2.445, -0.152, 0.304, 0.506, 1)
      if (choice == 1) { out <- b[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = b[choice - 1], max = b[choice]) }
      if (choice == 6) { out <- 1 }
    }
  }

  if (bibkey == "Coerts2026"){
    if (task == "EG") {
      b <- c(-5.839, -1.262, -0.381, 0, 0.216, 0.358, 0.459, 0.537, 1)
      if (choice == 1) { out <- b[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = b[choice - 1], max = b[choice]) }
      if (choice >= 10) { out <- 1 }
    }
  }

  ## Wang et al. 2023: Holt-Laury list with A = 3 / 2 and B = 5 / 1 EUR, the high
  ## outcome with probability k/10 in row k. Indifference in row k gives
  ## r_k = 2.540, 1.705, 1.156, 0.710, 0.304, -0.099, -0.535, -1.063, -1.848 (k = 1..9).
  ## choice = number of B choices: r between r_(11-choice) and r_(10-choice); 10 is
  ## coded at r_1, 0 and 1 at r_9, as for Flambard2024.
  if (bibkey == "Wang2023"){
    if (task == "HL") {
      rk <- c(2.540, 1.705, 1.156, 0.710, 0.304, -0.099, -0.535, -1.063, -1.848)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Read et al. 2023: the Eckel-Grossman table 16/16, 24/12, 32/8, 40/4, 48/0,
  ## the same as for Crosetto2016 and Menkhoff_Sakha_2017, hence the same bounds.
  if (bibkey == "Read2023"){
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
  }
  ## Fisar et al. 2023: dynamic BRET on a 10x10 grid, 100 boxes
  ## Beaud et al. 2026: static BRET on a 10x10 grid, 100 boxes
  ## Fullbrunn et al. 2019: dynamic BRET, 100 boxes, EUR 0.10 each
  if (bibkey == "Fisar2023" | bibkey == "Beaud2026" | bibkey == "Buser2022" |
      bibkey == "Mittone2020" | bibkey == "Fullbrunn2019"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }
  if (bibkey == "Dannenberg2022"){
    if (task == "IG") { out <- ig_crra(choice, X = 1000, k = 3) }
  }
  if (bibkey == "Shachat2021"){
    if (task == "CEPL") {
      if (choice == 10) { out <- 7.96 }
      if (choice == 9) { out <- 7.96 }
      if (choice == 8) { out <- runif(1, min = 3.71, max = 7.96) }
      if (choice == 7) { out <- runif(1, min = 2.06, max = 3.71) }
      if (choice == 6) { out <- runif(1, min = 1, max = 2.06) }
      if (choice == 5) { out <- runif(1, min = 0.07, max = 1) }
      if (choice == 4) { out <- runif(1, min = -1, max = 0.07) }
      if (choice == 3) { out <- runif(1, min = -2.93, max = -1) }
      if (choice == 2) { out <- -2.93}
      if (choice == 1) { out <- -2.93 }
      }
  }
  if (bibkey == "Buser2021"){
    if (task == "IG") { out <- ig_crra(choice, X = 20, k = 2.5) }
  }

  if (bibkey == "Kessel2021"){
    if (task == "IG") { out <- ig_crra(choice, X = 10, k = 2.5) }
  }
  if (bibkey == "Veldhuizen2022"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.46 } 
      if (choice == 2) { out <- runif(1, min = -2.46, max = -0.16)}
      if (choice == 3) { out <- runif(1, min = -0.16, max = 0.29)}
      if (choice == 4) {out <- runif(1, min = 0.29, max = 0.5)}
      if (choice == 5) { out <- runif(1, min = 0.5, max = 1)} 
      if (choice == 6) { out <- 1 } 
    }
    if (task == "HL") {
      if (choice == 10) { out <- 2.75 }
      if (choice == 9) { out <- runif(1, min = 1.97, max = 2.75) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.97) }
      if (choice == 7) { out <- runif(1, min = 1.12, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.81, max = 1.12) }
      if (choice == 5) { out <- runif(1, min = 0.51, max = 0.81) }
      if (choice == 4) { out <- runif(1, min = 0.21, max = 0.51) }
      if (choice == 3) { out <- runif(1, min = -0.13, max = 0.21) }
      if (choice == 2) { out <- runif(1, min = -0.61, max = -0.13) }
      if (choice == 1) { out <- -0.61 }
      if (choice == 0) { out <- -0.61 }
    }
  } 
  if (bibkey == "Rommel2019"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    } 
  } 
  
  if (bibkey == "Erkal2018" | bibkey == "Erkal2022"){
    if (task == "IG") { out <- ig_crra(choice, X = 50, k = 3) }
  }
  if (bibkey == "Erkal2020"){
  if (task == "CEPL") {
    if (choice == 1) { out <- 3.32 }
    if (choice == 2) { out <- runif(1, min = 2.32, max = 3.32) }
    if (choice == 3) { out <- runif(1, min = 1.74, max = 2.32) }
    if (choice == 4) { out <- runif(1, min = 1.32, max = 1.74) }
    if (choice == 5) { out <- runif(1, min = 1, max = 1.32) }
    if (choice == 6) { out <- runif(1, min = 0.74, max = 1) }
    if (choice == 7) { out <- runif(1, min = 0.51, max = 0.74) }
    if (choice == 8) { out <- runif(1, min = 0.32, max = 0.51) }
    if (choice == 9) { out <- runif(1, min = 0.15, max = 0.32)  }
  }
}
  ## Humphrey and Meickmann 2026: ten-row Holt-Laury list, option A pays EUR 12.00
  ## or 9.50, option B pays EUR 23.00 or 0.50, probability of the high payoff
  ## rising from 10% to 100%. Bounds are the CRRA values that make each row
  ## indifferent, computed the same way as the standard list above (which this
  ## procedure reproduces exactly: 2.71, 1.95, 1.49, 1.15, 0.85, 0.59, 0.32,
  ## 0.03, -0.37). The payoffs are close to a six-fold scaling of Holt and
  ## Laury's, so the bounds sit close to the standard ones; risk neutrality
  ## (r = 1) falls in choice == 6, which matches the expected-value switch
  ## between rows 4 and 5.
  if (bibkey == "Humphrey2026"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.70 }
      if (choice == 9) { out <- runif(1, min = 1.94, max = 2.70) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.94) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.86, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.60, max = 0.86) }
      if (choice == 4) { out <- runif(1, min = 0.35, max = 0.60) }
      if (choice == 3) { out <- runif(1, min = 0.06, max = 0.35) }
      if (choice == 2) { out <- runif(1, min = -0.32, max = 0.06) }
      if (choice == 1) { out <- -0.32 }
      if (choice == 0) { out <- -0.32 }
    }
  }
  ## Chlass and Miettinen 2026: ten rows pitching a certain 2.5 ECU against a
  ## lottery paying 3.5 ECU with probability row/10 and 1.5 ECU otherwise.
  ## Bounds solve 2.5^r = p*3.5^r + (1-p)*1.5^r at each row, the same procedure
  ## used for the Holt and Laury lists above; the control is row 5, where the
  ## lottery has an expected value of exactly 2.5 and the root comes out at
  ## r = 1 to six decimals. choice is the number of risky choices, 11 - S.
  ##
  ## The intervals are much wider than on an HL list because the three payoffs
  ## sit close together (1.5, 2.5, 3.5), so one step of ten percentage points in
  ## probability moves the indifferent r a long way. Read on the usual scale
  ## r = 1 - RRA, the modal subject here lands at an RRA between 1 and 2, which
  ## is ordinary; it is this task's narrow spread, not the subjects, that pushes
  ## the numbers below the range an HL list produces.
  if (bibkey == "Chlass2026"){
    if (task == "CEPL") {
      if (choice == 10) { out <- 6.76 }
      if (choice == 9) { out <- runif(1, min = 4.54, max = 6.76) }
      if (choice == 8) { out <- runif(1, min = 3.12, max = 4.54) }
      if (choice == 7) { out <- runif(1, min = 2.00, max = 3.12) }
      if (choice == 6) { out <- runif(1, min = 1.00, max = 2.00) }
      if (choice == 5) { out <- runif(1, min = 0.03, max = 1.00) }
      if (choice == 4) { out <- runif(1, min = -1.00, max = 0.03) }
      if (choice == 3) { out <- runif(1, min = -2.22, max = -1.00) }
      if (choice == 2) { out <- runif(1, min = -3.98, max = -2.22) }
      if (choice == 1) { out <- -3.98 }
      if (choice == 0) { out <- -3.98 }
    }
  }
  ## Balart et al. 2022: ordered lottery selection of six 50/50 options added to a
  ## 120 euro base -- 28/28, 24/34, 20/40, 16/46, 12/52, 2/62 euros -- plus a
  ## 100-box bomb risk task. Bounds are the CRRA values that make adjacent
  ## options indifferent, computed on the lottery amounts alone, as for every
  ## other EG paper here; options 5 and 6 share an expected value of 32, hence
  ## the bound of 1. Taking the 120 euro base into the utility instead would put
  ## the bounds at -3.04, -1.44 and -0.75, which is not comparable with the rest
  ## of the EG pool, so the site convention is kept.
  if (bibkey == "Balart2022"){
    if (task == "EG") {
      if (choice == 1) { out <- -1.33 }
      if (choice == 2) { out <- runif(1, min = -1.33, max = 0.22)}
      if (choice == 3) { out <- runif(1, min = 0.22, max = 0.54)}
      if (choice == 4) { out <- runif(1, min = 0.54, max = 0.68)}
      if (choice == 5) { out <- runif(1, min = 0.68, max = 1)}
      if (choice == 6) { out <- 1}
    }
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }
  ## Bajoori, Peeters and Wolk 2024: dynamic bomb risk elicitation task on a
  ## 10-by-10 field, so the same hundred-box rule as Nielsen 2019 above.
  if (bibkey == "Bajoori2024"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }
  ## Rentschler and Samad 2025: bomb risk elicitation task with a hundred boxes
  ## at five cents each, so the same rule as Nielsen 2019 above.
  if (bibkey == "Rentschler2025"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }
  ## Jiang and Villeval 2024: Eckel and Grossman list of six 50/50 gambles --
  ## (56, 56), (48, 72), (40, 88), (32, 104), (24, 120), (4, 140) tokens, from
  ## the code book in the replication package. Options 5 and 6 share an expected
  ## value of 72, hence the bound of 1. This is the Charness et al. 2019 set
  ## times eight and the bounds agree with that block above to two decimals.
  if (bibkey == "Jiang2024"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.46 }
      if (choice == 2) { out <- runif(1, min = -2.46, max = -0.16)}
      if (choice == 3) { out <- runif(1, min = -0.16, max = 0.29)}
      if (choice == 4) { out <- runif(1, min = 0.29, max = 0.50)}
      if (choice == 5) { out <- runif(1, min = 0.50, max = 1)}
      if (choice == 6) { out <- 1}
    }
  }
  ## Pin and Rotesi 2023, three tasks on the same subjects. All parameters come
  ## from the online supplementary material shipped with the data.
  ##   IG  -- "Risky Project 50%": 400 cents, half chance of 2.5 times the
  ##          amount invested, otherwise it is lost. The original Gneezy-Potters.
  ##   EG  -- six 50/50 gambles, 4.65/4.65, 4/6, 3.4/7.2, 2.7/8.6, 2/10, 0.5/11.5
  ##          euros; the last two share an expected value of 6, hence the bound
  ##          of 1.
  ##   HL  -- nine rows, safe 4/5 against risky 0.25/9.6, probability of the high
  ##          outcome rising from 0.1 to 0.9. The bounds come out within 0.01 of
  ##          the standard Holt and Laury table used elsewhere in this file,
  ##          which is a useful check; choice is the number of risky choices,
  ##          so it runs 0 to 9 rather than 0 to 10.
  if (bibkey == "Pin2023"){
    if (task == "IG") { out <- ig_crra(choice, X = 400, k = 2.5) }
    if (task == "EG") {
      if (choice == 1) { out <- -2.66 }
      if (choice == 2) { out <- runif(1, min = -2.66, max = -0.20)}
      if (choice == 3) { out <- runif(1, min = -0.20, max = 0.27)}
      if (choice == 4) { out <- runif(1, min = 0.27, max = 0.50)}
      if (choice == 5) { out <- runif(1, min = 0.50, max = 1)}
      if (choice == 6) { out <- 1}
    }
    if (task == "HL") {
      if (choice == 9) { out <- 2.72 }
      if (choice == 8) { out <- runif(1, min = 1.95, max = 2.72) }
      if (choice == 7) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 6) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 5) { out <- runif(1, min = 0.86, max = 1.15) }
      if (choice == 4) { out <- runif(1, min = 0.59, max = 0.86) }
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.59) }
      if (choice == 2) { out <- runif(1, min = 0.03, max = 0.33) }
      if (choice == 1) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 0) { out <- -0.37 }
    }
  }
  ## McGee and McGee 2024: the standard Holt and Laury low-stakes list quoted in
  ## their instructions -- option A 200/160 pennies, option B 385/10 -- so the
  ## canonical bounds used elsewhere in this file apply unchanged.
  if (bibkey == "McGee2024"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }

  ## Staebler 2025: ten-row certainty-equivalent price list (Table A.14 of the
  ## author's Mannheim dissertation, Table 15 of the published paper). Every row
  ## offers the same lottery -- 50% of 0 cents, 50% of 50 cents -- against a sure
  ## payment that rises 5, 10, ..., 50 cents down the list, so the switch row
  ## brackets the certainty equivalent in (5*(choice - 1), 5*choice). choice is
  ## the first row in which the sure payment was preferred, which is
  ## 11 - risk_aversion in the author's coding. Inverting
  ##     0.5 * u(50) = u(CE)   with   u(w) = w^r / r
  ## gives r = log(0.5) / log(CE / 50) at both ends. Risk neutrality (r = 1) is
  ## CE = 25, exactly the sure payment of row 5, so it falls on the boundary
  ## between choice == 5 and choice == 6 -- the two modal answers. The top row
  ## reaches the prize itself, so following Aydogan2024 it is coded at the r of
  ## its lower end, log(0.5) / log(45 / 50) = 6.58.
  if (bibkey == "Staebler2025"){
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 5 * (choice - 1), hi = 5 * choice, X = 50,
                           top = log(0.5) / log(45 / 50))
    }
  }

  ## Friedl et al. 2020: Eckel-Grossman task in six pairs of cards, each pair a
  ## 50/50 gamble, shown to German students in euro and to Teop participants in
  ## Papua New Guinea in kina. The German pairs are 2.50/2.50, 3.50/2.00,
  ## 4.50/1.50, 5.50/1.00, 6.50/0.50 and 7.00/0.00 (Table 1) and the kina pairs
  ## 5/5, 7/4, 9/3, 11/2, 13/1 and 14/0 (Table A3) -- exactly twice the euro
  ## amounts -- so the CRRA bounds, being scale invariant, are the same set and
  ## one block serves both samples. The bounds are the r that make consecutive
  ## gambles indifferent under u(w) = w^r / r. Gambles 5 and 6 share an expected
  ## payoff of 3.50 and differ only in variance, so the last boundary is exactly
  ## r = 1: only a risk neutral or risk loving subject picks gamble 6, which is
  ## what the paper says of that pair.
  if (bibkey == "Friedl2020"){
    if (task == "EG") {
      if (choice == 1) { out <- -1.49 }
      if (choice == 2) { out <- runif(1, min = -1.49, max = 0.16) }
      if (choice == 3) { out <- runif(1, min = 0.16, max = 0.50) }
      if (choice == 4) { out <- runif(1, min = 0.50, max = 0.67) }
      if (choice == 5) { out <- runif(1, min = 0.67, max = 1) }
      if (choice == 6) { out <- 1 }
    }
  }

  ## Chang et al. 2024: eleven-row probability list run alongside the stag hunt
  ## game and deliberately built from the same payoffs, so the list is 40 points
  ## for sure against 60 points with probability p and 0 otherwise, with p
  ## running 0, 0.1, ... 1.0 down the rows. choice is the author's risk_loving,
  ## the number of rows in which the gamble was taken, so the switch happens at
  ## p = (11 - choice)/10 and the indifference probability lies in
  ## ((10 - choice)/10, (11 - choice)/10]. Solving p*u(60) = u(40) under
  ## u(w) = w^r / r gives r = log(p) / log(2/3) at both ends.
  ##
  ## Risk neutrality is p = 2/3, which falls inside choice == 4 -- and that is
  ## the modal answer, 94 of the 291 subjects used here. The two corner answers
  ## are dominated rather than extreme: choice == 0 refuses 60 for sure over 40
  ## for sure and choice == 11 takes a certain 0 over 40, so clean_data.R drops
  ## them along with the thirteen multiple switchers the paper also drops.
  ## The top row only bounds r from below, so it is coded at log(0.1)/log(2/3).
  if (bibkey == "Chang2024"){
    if (task == "HL") {
      if (choice == 1) { out <- runif(1, min = 0, max = 0.260) }
      if (choice == 2) { out <- runif(1, min = 0.260, max = 0.550) }
      if (choice == 3) { out <- runif(1, min = 0.550, max = 0.880) }
      if (choice == 4) { out <- runif(1, min = 0.880, max = 1.260) }
      if (choice == 5) { out <- runif(1, min = 1.260, max = 1.710) }
      if (choice == 6) { out <- runif(1, min = 1.710, max = 2.260) }
      if (choice == 7) { out <- runif(1, min = 2.260, max = 2.969) }
      if (choice == 8) { out <- runif(1, min = 2.969, max = 3.969) }
      if (choice == 9) { out <- runif(1, min = 3.969, max = 5.679) }
      if (choice == 10) { out <- 5.679 }
    }
  }

  ## Kloosterman and Troyan 2026: Holt-Laury list stretched to fifty rows to
  ## match the fifty rows of the twenty valuation tasks that precede it. Every
  ## row is lottery A, $24.00 with x% and $20.00 otherwise, against lottery B,
  ## $38.00 with x% and $12.00 otherwise, with x rising 2, 4, ..., 100 percent.
  ## The subject names the last row in which A was preferred, which is the
  ## stored LotterySwitchProb, so the indifference probability lies in
  ## (2*choice/100, (2*choice + 2)/100] and the two ends are found by solving
  ##     p*u(24) + (1-p)*u(20) = p*u(38) + (1-p)*u(12)
  ## for rho under u(w) = w^(1-rho)/(1-rho), as hl_switch_crra does for the
  ## usual one-point steps. Expected value is equal at p = 8/22 = 0.3636, and
  ## r_at of that probability comes back as exactly 1.
  ##
  ## The last row has x = 100, where B pays $38 for sure against A's $24, so no
  ## rho makes them indifferent: choice == 49 only bounds r from above and is
  ## coded at r_at(0.98) = -5.59, and choice == 50, which prefers a certain $24
  ## to a certain $38, is dropped in clean_data.R.
  if (bibkey == "Kloosterman2026"){
    if (task == "HL") {
      u <- function(w, rho) if (abs(rho - 1) < 1e-12) log(w) else w^(1 - rho) / (1 - rho)
      r_at <- function(p) {
        f <- function(rho) p * u(24, rho) + (1 - p) * u(20, rho) -
                           p * u(38, rho) - (1 - p) * u(12, rho)
        1 - uniroot(f, c(-200, 200), tol = 1e-10)$root
      }
      if (choice == 49) { out <- r_at(0.98) }
      if (choice <= 48) {
        out <- runif(1, min = r_at((2 * choice + 2) / 100), max = r_at(2 * choice / 100))
      }
    }
  }

  ## Baier et al. 2024: bomb risk elicitation task of Crosetto and Filippin
  ## (2013) run in the last stage of the experiment. choice is the stored bomb
  ## variable, the number of the 100 boxes the subject chose to collect, so the
  ## usual inversion applies: collecting c boxes is optimal under
  ## u(w) = w^r / r when r = c / (100 - c), which puts risk neutrality at 50,
  ## and the authors' own risk-averse dummy is boxes < 50, the same cut. Two
  ## subjects collected all 100 boxes, which guarantees the bomb and so pays
  ## nothing; as elsewhere in this file that corner is coded at 10.
  if (bibkey == "Baier2024"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice / (100 - choice) }
    }
  }

  ## Kovenock, Song and Trevisan 2026: the paper calls the last task a Holt and
  ## Laury (2002) elicitation and the appendix note describes the measure as
  ## "the number of lotteries subjects refuse to play", but neither prints the
  ## menu. The realised part 2 payoffs in the data recover it: everyone who
  ## refused was paid exactly 1.50, everyone who played and won 3.00, and
  ## everyone who played and lost 0.10. So each of the ten rows is a sure 1.50
  ## against a lottery paying 3.00 with probability p and 0.10 otherwise, and
  ## the share of subjects taking the lottery climbs over the stored row order
  ## from 0.08 to 0.85, so p rises down the list and the rows are 0.1, ..., 1.0.
  ##
  ## choice is the number of rows in which the lottery was taken, 10 minus the
  ## stored riskaversion, so the switch is at p = (11 - choice)/10 and the
  ## indifference probability lies in ((10 - choice)/10, (11 - choice)/10].
  ## Solving p*u(3) + (1-p)*u(0.1) = u(1.5) for rho under
  ## u(w) = w^(1-rho)/(1-rho) gives the two ends. Expected value is equal at
  ## p = 1.4/2.9 = 0.483, and r_at of that probability comes back as exactly 1,
  ## which lands inside choice == 6 -- one of the three modal answers, and the
  ## row where the acceptance share jumps from 0.12 to 0.33.
  ##
  ## The bounds sit close to the canonical Holt-Laury ones but are not them,
  ## because option A here is a sure amount rather than the 2.00/1.60 lottery.
  ## The last row pays 3.00 for sure against 1.50 for sure, so it bounds r only
  ## from above: choice == 1 is coded at r_at(0.9), and choice == 0, which
  ## refuses that row too, is dropped in clean_data.R.
  if (bibkey == "Kovenock2026"){
    if (task == "HL") {
      if (choice == 10) { out <- 3.322 }
      if (choice == 9) { out <- runif(1, min = 2.320, max = 3.322) }
      if (choice == 8) { out <- runif(1, min = 1.728, max = 2.320) }
      if (choice == 7) { out <- runif(1, min = 1.296, max = 1.728) }
      if (choice == 6) { out <- runif(1, min = 0.943, max = 1.296) }
      if (choice == 5) { out <- runif(1, min = 0.627, max = 0.943) }
      if (choice == 4) { out <- runif(1, min = 0.320, max = 0.627) }
      if (choice == 3) { out <- runif(1, min = -0.014, max = 0.320) }
      if (choice == 2) { out <- runif(1, min = -0.456, max = -0.014) }
      if (choice == 1) { out <- -0.456 }
    }
  }

  ## De Giorgi, Omar and Post 2026: a bracketing study at the HSG Behavioral Lab
  ## in which each subject answers twelve lotteries under three framings. Only
  ## the Narrow framing is an individual risk elicitation: there the subject
  ## holds one ticket on a single binomial gamble, and a slider picks how many
  ## of twenty gambles, ordered from the smallest loss to the largest, they
  ## accept. The round carries an endowment equal to the largest loss in it, so
  ## final wealth is never negative, and acceptance of gamble k solves
  ##     p*u(W + g) + (1-p)*u(W - l_k) = u(W)
  ## under u(w) = w^r / r. r rises with the number accepted, so accepting the
  ## first s gambles puts r in [t_s, t_{s+1}) for the thresholds below.
  ##
  ## Only the four rounds with p = 0.4 are used, and only the Balanced Gamble
  ## treatment. They are the same list at four scales -- gain 1000, 2000, 3000
  ## and 4000 against endowments 682, 1364, 2046 and 2729 -- and being scale
  ## invariant their thresholds agree to within 0.005, so choice is the mean of
  ## the four answers, rounded, and one set of bounds serves all four.
  ##
  ## Why only those rounds: the p = 0.5 and p = 0.6 rounds top out at r = 0.94
  ## and 0.865, and every round of the Skewed Gamble treatment spans no more
  ## than r in (0.09, 0.52) with about 30% of subjects at the ceiling, so none
  ## of them brackets risk neutrality at all. The p = 0.4 list does: gamble 19
  ## has an expected value of 0.4*1000 - 0.6*593 = +44 and gamble 20 one of
  ## 0.4*1000 - 0.6*682 = -9, so a risk neutral subject accepts exactly 19 of
  ## the 20, and the interval for choice == 19 is [0.904, 1.015), which holds
  ## r = 1.
  if (bibkey == "DeGiorgi2026"){
    if (task == "PV") {
      thr <- c(-1.876, -1.710, -1.540, -1.386, -1.215, -1.034, -0.860, -0.684,
               -0.500, -0.315, -0.168, -0.032, 0.099, 0.239, 0.372, 0.510,
               0.647, 0.779, 0.904, 1.015)
      if (choice == 0) { out <- thr[1] }
      if (choice == 20) { out <- thr[20] }
      if (choice >= 1 && choice <= 19) {
        out <- runif(1, min = thr[choice], max = thr[choice + 1])
      }
    }
  }

  ## Porter et al. 2025: ten-row certainty-equivalent price list run with food
  ## processing SMEs at Community of Practice meetings in Kenya. Every row puts
  ## the same lottery -- 50% of 500 Kenyan shillings, 50% of nothing -- against
  ## a sure payment that rises down the list, and the paper pins the step by
  ## saying that the average switch row of 6 is a certainty equivalent of 300
  ## KES, so the sure payments are 50, 100, ..., 500. choice is the row where
  ## the subject first took the sure payment, which brackets the certainty
  ## equivalent in (50*(choice - 1), 50*choice].
  ##
  ## This is the same shape as the Staebler list -- sure payments running from
  ## a tenth of the prize to the prize itself against a half chance of it -- so
  ## the bounds come out as the same set. Risk neutrality is a certainty
  ## equivalent of 250, the sure payment of row 5, so r = 1 sits on the
  ## boundary between choice == 5 and choice == 6, the two modal answers
  ## (15 and 13 of the 56 subjects used). The last row offers 500 for sure
  ## against a half chance of 500, so it only bounds r from below and is coded
  ## at log(0.5) / log(450 / 500) = 6.58.
  if (bibkey == "Porter2025"){
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 50 * (choice - 1), hi = 50 * choice, X = 500,
                           top = log(0.5) / log(450 / 500))
    }
  }

  ## Cortes et al. 2023: twelve-row certainty-equivalent price list run after
  ## the job search task with Arizona State undergraduates. Every row puts the
  ## same lottery -- 50% of $30, 50% of nothing -- against a certain payment
  ## rising $6, $7, ..., $17. Everyone also has a $5 show-up fee, so final
  ## wealth is $35 or $5 under the lottery and $5 + CE under the certain
  ## payment, which is how the authors write the indifference condition.
  ## choice is the first certain payment chosen, so the certainty equivalent
  ## lies in (choice - 1, choice], and the ends come from solving
  ##     (5 + CE)^r = 0.5 * (35^r + 5^r)
  ## under u(w) = w^r / r. The authors report the same inversion in the
  ## relative risk aversion scale, and 1 minus their stored coefficient matches
  ## the midpoint of each interval here to within 0.006.
  ##
  ## Risk neutrality is CE = 15, since 0.5*(35 + 5) = 5 + 15, so r = 1 is the
  ## top end of choice == 15 -- and $15 is the modal answer. The two corners
  ## are the authors' own codes: choice == 6 means the certain payment was
  ## taken in every row, which only bounds r from above, and choice == 18 that
  ## the lottery was taken in every row, which only bounds it from below.
  if (bibkey == "Cortes2023"){
    if (task == "CEPL") {
      thr <- c(-0.3995, -0.2074, -0.0369, 0.1200, 0.2685, 0.4124,
               0.5550, 0.6987, 0.8461, 1.0000, 1.1633, 1.3395)
      if (choice == 6) { out <- thr[1] }
      if (choice == 18) { out <- thr[12] }
      if (choice >= 7 && choice <= 17) {
        out <- runif(1, min = thr[choice - 6], max = thr[choice - 5])
      }
    }
  }

  ## Hamman and Martinez-Carrasco 2023: Eckel-Grossman gamble choice run after
  ## the main task, five 50-50 gambles read off the decision screen in the
  ## repository's experimental materials and confirmed by the realised payoffs
  ## stored in the data: 50/50, 90/30, 130/10, 170/-10, 210/-30 ECU. Expected
  ## values rise linearly 50, 60, 70, 80, 90 and the last two gambles can lose,
  ## in which case the loss was taken out of the subject's earnings so far.
  ##
  ## This is the same menu as the loss version in Menkhoff_Sakha_2017, down to
  ## the numbers, so it is filed as EG_loss and takes the same bounds: adding
  ## the largest possible loss of 30 makes the final payoffs 80/80, 120/60,
  ## 160/40, 200/20, 240/0, which is the canonical Eckel-Grossman table times
  ## five and therefore leaves the canonical bounds unchanged. Treating the
  ## worst outcome as zero wealth is the convention this file already uses for
  ## that menu; here the subjects' accumulated earnings were in fact larger,
  ## which the bounds do not take into account.
  ## Zheng et al. 2021: hypothetical 100/100, 180/60, 260/20, 340/-20, 420/-60
  ## yuan; plus 60 it is the canonical table times 40, so the same bounds.
  if (bibkey == "Hamman2023" | bibkey == "Zheng2021"){
    if (task == "EG_loss") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33) }
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62) }
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80) }
      if (choice == 5) { out <- 1 }
    }
  }

  ## Zhao 2026: the paper calls the pre-market task "a classic multiple price
  ## list (Holt and Laury, 2002)" without printing the menu, but the oTree
  ## exports in df_mpl store, for each subject, the row drawn for payment, the
  ## option they had chosen there and the amount paid. Collecting those
  ## realisations gives option A paying 2.00 or 1.60 and option B paying 3.85
  ## or 0.10, with the share of the high payoff rising down the rows -- the
  ## Holt-Laury table itself -- so the canonical bounds used elsewhere in this
  ## file apply unchanged. choice is the number of risky choices, which is
  ## 10 minus the stored num_safe_choices.
  if (bibkey == "Zhao2026"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }

  ## Grimalda et al. 2026: the Trustlab gamble choice, six 50-50 gambles read
  ## off the instructions in the repository (identical in both waves):
  ## 8/8, 7/10, 6/12, 5/14, 4/16 and 1/19 dollars. choice = gamble number,
  ## which is the stored risk_game plus one. Expected values rise 8, 8.5, 9,
  ## 9.5, 10, 10: the last two are equal, so gamble 6 is a mean preserving
  ## spread of gamble 5 and the boundary between them is exactly r = 1, which
  ## the numerical inversion returns to four decimals. The other bounds are the
  ## r that make consecutive gambles indifferent under u(w) = w^r / r.
  if (bibkey == "Grimalda2026"){
    if (task == "EG") {
      if (choice == 1) { out <- -2.94 }
      if (choice == 2) { out <- runif(1, min = -2.94, max = -0.32) }
      if (choice == 3) { out <- runif(1, min = -0.32, max = 0.19) }
      if (choice == 4) { out <- runif(1, min = 0.19, max = 0.43) }
      if (choice == 5) { out <- runif(1, min = 0.43, max = 1) }
      if (choice == 6) { out <- 1 }
    }
  }

  ## Chugunova, Nicklisch and Schnapp 2025: Gneezy-Potters investment game
  ## played at the very start of the study, before the real-effort and donation
  ## parts. Endowment 20 pence, any share can be invested, the investment
  ## returns 2.5 times itself with probability 0.5 and is lost otherwise, and
  ## the rest is kept. choice is the amount invested in pence, so the standard
  ## inversion applies with X = 20 and k = 2.5. The realised payoffs in the
  ## data confirm the parameters: winners of the first lottery are credited
  ## 2.5 times their stake on top of what they kept, and in the second lottery,
  ## played with earned money, the stored outcome is +1.5 times the stake when
  ## won and -1 times it when lost; both were won about half the time.
  ## Investing everything is optimal from r = 1 on, which ig_crra codes as 1.
  if (bibkey == "Chugunova2025"){
    if (task == "IG") { out <- ig_crra(choice, X = 20, k = 2.5) }
  }

  ## Chopra, Nguyen and Vossler 2025: ten-row lottery list run before the group
  ## contest. Each row offers $2 for sure against $4 with probability p and
  ## nothing otherwise; the data store the ten row answers and, unusually, the
  ## ten probabilities themselves, which are 0.1, 0.2, ..., 1.0. choice is the
  ## number of rows in which the lottery was taken, so the switch is at
  ## p = (11 - choice)/10 and the indifference probability lies in
  ## ((10 - choice)/10, (11 - choice)/10]. Solving p*u(4) = u(2) under
  ## u(w) = w^r / r gives p = (1/2)^r, so r = log(p) / log(0.5) at both ends.
  ##
  ## Expected values are equal at p = 0.5, so a risk neutral subject takes the
  ## lottery from row 5 on and makes four safe choices: r = 1 is the bottom end
  ## of choice == 6. That matches the authors' own cut, which calls a subject
  ## risk averse at six or more safe choices, one step past risk neutrality.
  ## The last row pays $4 for sure against $2 for sure, so choice == 0 is
  ## dominated and is dropped in clean_data.R.
  if (bibkey == "Chopra2025"){
    if (task == "HL") {
      if (choice == 10) { out <- 3.322 }
      if (choice == 9) { out <- runif(1, min = 2.322, max = 3.322) }
      if (choice == 8) { out <- runif(1, min = 1.737, max = 2.322) }
      if (choice == 7) { out <- runif(1, min = 1.322, max = 1.737) }
      if (choice == 6) { out <- runif(1, min = 1.000, max = 1.322) }
      if (choice == 5) { out <- runif(1, min = 0.737, max = 1.000) }
      if (choice == 4) { out <- runif(1, min = 0.515, max = 0.737) }
      if (choice == 3) { out <- runif(1, min = 0.322, max = 0.515) }
      if (choice == 2) { out <- runif(1, min = 0.152, max = 0.322) }
      if (choice == 1) { out <- runif(1, min = 0, max = 0.152) }
    }
  }

  ## Gruener et al. 2022: the Holt and Laury list exactly as published --
  ## option A pays EUR 2.00 or 1.60, option B 3.85 or 0.10, the high payoff
  ## with probability 10%, 20%, ... down the ten rows (the wording is printed
  ## in Appendix S2 of the paper). The canonical bounds therefore apply
  ## unchanged. choice is the number of rows in which the risky option B was
  ## taken, which is 10 minus the authors' sum_hl.
  if (bibkey == "Gruener2022"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }

  ## Chen and He 2021: the Holt and Laury list run after the school choice game.
  ## The instructions in the online appendix print the table in full: option A
  ## pays 200 points if the ten-sided die falls in the winning range and 160
  ## otherwise, option B 385 or 10, with the winning range growing from "die is
  ## 1" in row 1 to "die is 1-10" in row 10. That is the canonical Holt-Laury
  ## table times one hundred, so the canonical bounds apply unchanged. choice is
  ## the number of rows in which option B was taken.
  if (bibkey == "ChenHe2021"){
    if (task == "HL") {
      if (choice == 10) { out <- 2.71 }
      if (choice == 9) { out <- runif(1, min = 1.95, max = 2.71) }
      if (choice == 8) { out <- runif(1, min = 1.49, max = 1.95) }
      if (choice == 7) { out <- runif(1, min = 1.15, max = 1.49) }
      if (choice == 6) { out <- runif(1, min = 0.85, max = 1.15) }
      if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
      if (choice == 4) { out <- runif(1, min = 0.32, max = 0.59) }
      if (choice == 3) { out <- runif(1, min = 0.03, max = 0.32) }
      if (choice == 2) { out <- runif(1, min = -0.37, max = 0.03) }
      if (choice == 1) { out <- -0.37 }
      if (choice == 0) { out <- -0.37 }
    }
  }

  ## Vieider et al. 2015: certainty equivalent of the 50/50 prospect paying 20 or
  ## 0 PPP euros (task 3 of 44), elicited with a list of sure amounts from 0 to 20
  ## in steps of 0.5; the CE is the midpoint of the switching interval, so
  ## choice = number of the interval (0 ... 39) and the CE lies in
  ## [0.5 choice, 0.5 choice + 0.5]. Same prospect and same list as DiFalco2022.
  if (bibkey == "Vieider2015"){
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = 0.5 * choice, hi = 0.5 * choice + 0.5, X = 20,
                           top = log(0.5) / log(19.5 / 20))
    }
  }

  ## Hermann et al. 2019: Eckel-Grossman task extended to nine 50/50 gambles, so
  ## that it also separates risk neutral from risk seeking subjects. The menu is
  ## the one in table 2 of Hermann & Musshoff (2019, Journal of Risk Research),
  ## by the same group, who built it to span the same CRRA ranges as Holt-Laury:
  ##   1 (170, 170), 2 (135.5, 217.7), 3 (105, 279), 4 (78.4, 340), 5 (63, 370),
  ##   6 (48, 390), 7 (41, 395), 8 (35.7, 396.7), 9 (19, 398).
  ## Indifference between gamble k and k + 1 under u = x^(1-rho)/(1-rho) gives
  ## rho = 1.365, 0.962, 0.681, 0.413, 0.149, -0.155, -0.487, -0.954, which
  ## reproduces the authors' own table (1.37, 0.97, 0.68, 0.41, 0.15, -0.15,
  ## -0.49, -0.95), the one shipped in their data file. rk holds these on the
  ## site's scale r = 1 - rho. CRRA bounds do not move with the scale of the
  ## payoffs, so the smaller amounts of this experiment give the same numbers.
  ## choice = the gamble picked (1 = safest, 9 = riskiest); the two open-ended
  ## categories are coded at their finite end.
  if (bibkey == "Hermann2019"){
    if (task == "EG") {
      rk <- c(-0.365, 0.038, 0.320, 0.587, 0.851, 1.155, 1.487, 1.954)
      if (choice <= 1) { out <- rk[1] }
      if (choice >= 2 & choice <= 8) { out <- runif(1, min = rk[choice - 1], max = rk[choice]) }
      if (choice >= 9) { out <- rk[8] }
    }
  }

  ## Fochmann et al. 2021: the Holt and Laury (2002) menu itself, run in euros
  ## instead of dollars (safe 2.00 / 1.60, risky 3.85 / 0.10, the high outcome
  ## with probability k/10 in row k). The scale does not move CRRA bounds, so the
  ## canonical table applies: indifference in row k gives r_k = 2.713, 1.947,
  ## 1.487, 1.143, 0.854, 0.589, 0.324, 0.029, -0.368 (k = 1..9).
  ## choice = number of lottery B (risky) choices, the authors' own measure.
  if (bibkey == "Fochmann2021"){
    if (task == "HL") {
      rk <- c(2.713, 1.947, 1.487, 1.143, 0.854, 0.589, 0.324, 0.029, -0.368)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Aschenwald et al. 2024: hypothetical Eckel-Grossman menu of six 50/50
  ## gambles decided by a coin toss, read off the oTree template of the
  ## experiment (Preferences/templates/Preferences/RiskPreference.html):
  ##   1 (10, 10), 2 (8, 13), 3 (6, 16), 4 (4, 19), 5 (2, 22), 6 (0, 24) EUR.
  ## Expected values rise 10, 10.5, 11, 11.5, 12, 12, so gambles 5 and 6 pay the
  ## same on average and only a risk seeking subject takes 6. Maximising
  ## expected utility over the menu cuts the line at r = -0.669, 0.445, 0.678,
  ## 0.791 and exactly 1 (where 5 and 6 tie); the two open ends are coded at
  ## their finite bound. choice = the gamble picked (1 = the sure amount).
  if (bibkey == "Aschenwald2024"){
    if (task == "EG") {
      ek <- c(-0.669, 0.445, 0.678, 0.791, 1.000)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 6) { out <- ek[5] }
    }
  }

  ## Bonnier et al. 2019: price list of ten choices between two coin-flip
  ## lotteries. The safer one always pays 30 or 50 DKK; the riskier one pays 5 or
  ## a high prize that grows down the list: 60, 70, 80, 90, 100, 110, 120, 140,
  ## 170, 220 (appendix D3.2 of the paper; in Valencia every amount was divided
  ## by ten and paid in euros, which leaves CRRA bounds untouched). So this is a
  ## Holt-Laury price list that moves the prize instead of the probability.
  ## Indifference in row k under u = x^(1-rho)/(1-rho) gives, on the site's scale
  ## r = 1 - rho, rk = 1.787, 1.170, 0.872, 0.688, 0.562, 0.469, 0.397, 0.292,
  ## 0.190, 0.089. choice = number of risky choices.
  ## Control: the risky lottery's expected value passes the safe one's 40 exactly
  ## between the high prizes 70 and 80, so a risk neutral subject takes the risky
  ## side in the last eight rows; choice 8 spans (0.872, 1.170), which brackets 1.
  if (bibkey == "Bonnier2019"){
    if (task == "HL") {
      rk <- c(1.787, 1.170, 0.872, 0.688, 0.562, 0.469, 0.397, 0.292, 0.190, 0.089)
      if (choice >= 10) { out <- rk[1] }
      if (choice >= 1 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 0) { out <- rk[10] }
    }
  }

  ## Aoyagi et al. 2024: the bomb task of Crosetto and Filippin (2013) with 100
  ## boxes and one bomb, as the paper's own cap on earnings confirms ("maximal
  ## ECU earnings from the bomb task were 99"). choice = boxes collected, so the
  ## usual inversion r = choice / (100 - choice) applies; nobody collected all
  ## 100, so the 100 branch never fires but is kept for symmetry with the other
  ## BRET papers on the site.
  if (bibkey == "Aoyagi2024"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## Snowberg & Yariv 2021: the same survey run on four pools, with two of its
  ## three risk elicitations usable here.
  ## IG is the first risky project, "following Gneezy and Potters (1997)": an
  ## endowment of 100 tokens split between keeping and a project that returns
  ## 3 tokens per token invested with probability 0.35, nothing otherwise. In the
  ## site's parameters that is a gain of g = 2 per token invested against a loss
  ## of the token itself. The project pays 0.05 per token in expectation, so a
  ## risk neutral subject invests everything, which ig_crra_pgl codes at r = 1.
  ## CEPL is the first risky urn: 20 balls, 10 of the colour the subject picked,
  ## paying 100 tokens, offered against sure amounts in steps of 10. The form
  ## forced the lottery at a sure 0 and the sure amount at 100 and allowed a
  ## single crossing, and riskyUrn20MaxValue runs over 10 ... 100 with no zero,
  ## which identifies it as the lowest sure amount the subject took over the
  ## lottery: the certainty equivalent then lies in (choice - 10, choice].
  ## An answer of 100 means the subject never took a sure amount below the
  ## forced top row, so it is coded at the r of a certainty equivalent of 90.
  if (bibkey == "Snowberg2021"){
    if (task == "IG")   { out <- ig_crra_pgl(choice, X = 100, p = 0.35, g = 2, l = 1) }
    if (task == "CEPL") {
      out <- ce_stair_crra(lo = choice - 10, hi = choice, X = 100,
                           top = log(0.5) / log(90 / 100))
    }
  }

  ## Riley 2024: Gneezy-Potters investment task, quoted verbatim from the
  ## project's own baseline questionnaire: "You have USH 8000 to invest or keep.
  ## If you invest an amount, with probably 1/2 the amount will be multiplied by
  ## 4 and with probability 1/2 you will get nothing." So the endowment is 8000
  ## UGX, the invested amount gains 3 per unit with probability 1/2 and is lost
  ## otherwise. The gamble is favourable (half of three times the stake beats
  ## half of losing it), so a risk neutral subject invests the whole endowment,
  ## which ig_crra_pgl codes at exactly r = 1; 363 of 2,959 did that.
  ## choice = amount invested, in shillings.
  if (bibkey == "Riley2024"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 8000, p = 0.5, g = 3, l = 1) }
  }

  ## Belot et al. 2025: an Eckel-Grossman menu of six coin-flip options, taken
  ## verbatim from the levels of risk_preference in the authors' own file:
  ##   1 a sure 2.80, 2 (2.40, 3.60), 3 (2.00, 4.40), 4 (1.60, 5.20),
  ##   5 (1.20, 6.00), 6 (0.20, 7.00) pounds.
  ## Expected values are 2.80, 3.00, 3.20, 3.40, 3.60, 3.60: rising and then
  ## flat, which is the Eckel-Grossman design, so only a risk seeking subject
  ## takes the sixth. Maximising expected utility over the menu cuts the line at
  ## r = -2.460, -0.161, 0.294, 0.501 and exactly 1 (where 5 and 6 tie); the two
  ## open ends are coded at their finite bound.
  ## choice = the option picked, 1 = the sure amount.
  if (bibkey == "Belot2025"){
    if (task == "EG") {
      ek <- c(-2.460, -0.161, 0.294, 0.501, 1.000)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 6) { out <- ek[5] }
    }
  }

  ## Drouvelis & Pearce 2025: a close replication of Proto, Rustichini and
  ## Sofianos, and the paper states the risk task is "a Holt and Laury (2002)
  ## multiple price list", so the canonical bounds of the Proto2018 block apply.
  ## choice = number of risky choices.
  if (bibkey == "DrouvelisPearce2025"){
    if (task == "HL") {
      rk <- c(2.713, 1.947, 1.487, 1.143, 0.854, 0.589, 0.324, 0.029, -0.368)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Horvath 2025: Gneezy-Potters investment task asked in the closing survey.
  ## The wording is quoted verbatim from the oTree page shipped with the package
  ## (Experimental software in oTree/N5_LowCost/Survey3.html): "Imagine you have
  ## 100 points. You can invest some of it in a risky investment. If you invest
  ## Y in the risky investment, the investment return will be either 2.5*Y or 0
  ## with equal probability." So the endowment is 100, the invested amount pays
  ## 2.5 times itself with probability 1/2 (a net gain of 1.5 per point) and is
  ## lost otherwise. The gamble is favourable, so a risk neutral subject invests
  ## everything, which ig_crra_pgl codes at exactly r = 1; 54 of 420 did that.
  ## choice = points invested.
  if (bibkey == "Horvath2025"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 100, p = 0.5, g = 1.5, l = 1) }
  }

  ## Agranov et al. 2025: Gneezy-Potters investment task, quoted verbatim from
  ## the instructions shipped with the package (instructions/instructionsRisk.
  ## docx): "You are endowed with 200 tokens ($2). You can choose to invest any
  ## number of tokens in a risky project. ... The risky project has a 50% chance
  ## of success. If the project is successful, you will receive 2.5 times the
  ## amount of tokens you chose to invest. If the project is unsuccessful, you
  ## will lose the amount invested." So the invested amount gains 1.5 per token
  ## with probability 1/2 and is lost otherwise. A second question repeats it at
  ## a 40% chance and a payout of 3 times the stake; only the first is used,
  ## since the site holds one coefficient per subject per task.
  ## The gamble is favourable, so a risk neutral subject invests all 200, which
  ## ig_crra_pgl codes at exactly r = 1; 18 of 49 did that.
  ## choice = tokens invested.
  if (bibkey == "Agranov2025"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 200, p = 0.5, g = 1.5, l = 1) }
  }

  ## Agranov and Ortoleva 2025: the body of the experiment is about randomizing
  ## inside price lists and is not usable here, but the session closed with two
  ## Gneezy-Potters investment tasks, as the paper states ("subjects completed
  ## two investment tasks (Gneezy & Potters, 1997)"). The wording is quoted
  ## verbatim from the header of the raw Qualtrics export: "You are endowed with
  ## 100 points. Each point is worth 10 cents, so you are endowed with $10. You
  ## can choose to invest any amount between 0 and 100 points in a risky
  ## project. ... The risky project has a 50% chance of success: If the project
  ## is successful, you will receive 2.5 times the amount you chose to invest.
  ## If the project is unsuccessful, you will lose the amount invested." So the
  ## invested amount gains 1.5 per point with probability 1/2 and is lost
  ## otherwise -- the same rule as Horvath above. The second task repeats the
  ## question with each point worth 2 cents instead of 10; only the first is
  ## used, since the site holds one coefficient per subject per task.
  ## The gamble is favourable, so a risk neutral subject invests all 100, which
  ## ig_crra_pgl codes at exactly r = 1; 11 of 165 did that.
  ## choice = points invested.
  if (bibkey == "AgranovOrtoleva2025"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 100, p = 0.5, g = 1.5, l = 1) }
  }

  ## Chew, Miao and Zhong 2023, Experiment 1. Decision Sheet A1 of the printed
  ## instructions (Appendix B of the paper) is a plain certainty equivalent
  ## list: Option A is "50% of receiving $60, 50% of receiving $0" and Option B
  ## is a sure amount rising down the ten rows -- 15, 19, 23, 25, 27, 29, 30,
  ## 31, 33, 35. The other fifteen sheets of the same shape replace the known
  ## urn with an unknown one, a compound one or a natural event, which is
  ## ambiguity rather than risk, so only A1 is used.
  ##
  ## a1 is the NUMBER OF ROWS in which the subject took the lottery, 0 to 10.
  ## That reading is fixed by the authors' own Experiment 2 code, where the
  ## same list runs 21 rows and risk neutrality is coded at the count 11, the
  ## middle; and the data agree, the mode here being 6 -- the last row whose
  ## sure amount, 29, is still below the expected value of 30. So the certainty
  ## equivalent lies between the k-th sure amount and the next one.
  ##
  ## Taking the lottery in every row means a certainty equivalent above the
  ## highest sure amount of 35; those 217 subjects are coded at r(35) = 1.286.
  ## Taking the sure amount in every row leaves the equivalent anywhere below
  ## 15, which starts at r = 0.
  ##
  ## Only the count is published, so a subject who switched back and forth
  ## cannot be told from a single switcher.
  if (bibkey == "Chew2023"){
    if (task == "CEPL") {
      ck <- c(15, 19, 23, 25, 27, 29, 30, 31, 33, 35)
      lo <- if (choice <= 0) 0 else ck[choice]
      hi <- if (choice >= 10) 60 else ck[choice + 1]
      out <- ce_stair_crra(lo = lo, hi = hi, X = 60,
                           top = log(0.5) / log(35 / 60))
    }
  }

  ## Hillenbrand and Winter 2018: the bomb task of Crosetto and Filippin on an
  ## 8 by 8 grid, so 64 boxes -- the bomb_location field in the package runs
  ## row 1 to 8 and column 1 to 8, and the largest number of boxes collected is
  ## exactly 64. Incentivized, up to 3.15 EUR, which is about 5 cents a box.
  ## Same inversion as the other static BRETs here: stopping at k of n boxes is
  ## rationalised by k/(n - k), and taking the whole grid is capped.
  if (bibkey == "Hillenbrand2018"){
    if (task == "BRET") {
      if (choice == 64) { out <- 10 }
      if (choice != 64) { out <- choice / (64 - choice) }
    }
  }

  ## Holmen et al. 2023: Eckel-Grossman menu of six 50/50 gambles, taken from
  ## the oTree app shipped with the project (t3_rls/models.py), where the list
  ## called 'risk' is written out as low and high outcomes in SEK:
  ##   1 (96, 96), 2 (80, 128), 3 (64, 160), 4 (48, 192), 5 (32, 224),
  ##   6 (16, 240).
  ## The package's own documentation of the task says "Lottery choice task a la
  ## Eckel/Grossman (2002)" and "choice: id of the chosen lottery (1 - 6)".
  ## Expected values rise 96, 104, 112, 120, 128, 128, so gambles 5 and 6 pay
  ## the same on average and only a risk seeking subject takes 6 -- the same
  ## shape as Aschenwald et al. 2024. Maximising expected utility over the menu
  ## cuts the line at r = -1.975, 0 (exactly), 0.396, 0.582 and exactly 1, and
  ## the two open ends are coded at their finite bound.
  if (bibkey == "Holmen2023"){
    if (task == "EG") {
      ek <- c(-1.975, 0.000, 0.396, 0.582, 1.000)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 6) { out <- ek[5] }
    }
  }

  ## Chowdhury, Sutter and Zimmermann 2022: the six gambles of Binswanger
  ## (1980), printed in Table 3 of the paper. The payoffs are age contingent,
  ## but every menu is the same list scaled down -- the parents' low payoffs
  ## are 125, 110, 100, 75, 25, 0 taka against high payoffs 125, 240, 300, 375,
  ## 475, 500, and the 10-11 year olds get exactly a fifth of each, the 6-7
  ## year olds a tenth, and so on. CRRA bounds are scale invariant, so one set
  ## of cuts serves all seven age groups.
  ##
  ## Expected values rise 125, 175, 200, 225, 250, 250: gambles 5 and 6 pay the
  ## same on average and only a risk seeking subject takes 6, the same shape as
  ## Aschenwald et al. 2024 and Holmen et al. 2023. Maximising expected utility
  ## cuts the line at r = -5.298, -0.907, 0.188, 0.685 and exactly 1, and the
  ## two open ends are coded at their finite bound.
  ##
  ## choice = the gamble picked, 1 to 6; the paper says "higher numbers are
  ## associated with a higher willingness to take risks".
  if (bibkey == "Chowdhury2022"){
    if (task == "EG") {
      ek <- c(-5.298, -0.907, 0.188, 0.685, 1.000)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 6) { out <- ek[5] }
    }
  }

  ## ---- Papers added 26.10.2026 --------------------------------------------
  ## Every Eckel-Grossman cut below was found by maximising expected utility
  ## u = x^r over the menu (the site's scale, r = 1 - rho); each set reproduces
  ## the CRRA ranges the paper itself prints, and the same routine returns the
  ## Holmen2023 cuts above to three decimals.

  ## Banerjee et al. 2021 and Pitts et al. 2025: the original five-gamble
  ## Eckel-Grossman (2002) table. Banerjee pays $4/4, 3/6, 2/8, 1/10, 0/12
  ## (z-Tree program in the package); Pitts scales 16/16 ... 0/48 to MXN 10000/
  ## 10000, 7500/15000, 5000/20000, 2500/25000, 0/30000 (Table 3). Same bounds
  ## as Crosetto2016 and Menkhoff_Sakha_2017 above, and the same convention for
  ## the two ends.
  if (bibkey == "Banerjee2021" | bibkey == "Pitts2025"){
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
  }

  ## Ihli et al. 2022 (RWF 2800/2800, 2400/3600, 2000/4400, 1600/5200,
  ## 1200/6000, 200/7000) and Charness et al. 2023 (points 28/28, 24/36, 20/44,
  ## 16/52, 12/60, 2/66). Both are the Dave et al. (2010) six-gamble menu with a
  ## different last row. The first four cuts coincide, -2.460, -0.161, 0.294,
  ## 0.501; the last one is 1 exactly for Ihli (gambles 5 and 6 have the same
  ## expected value) and 1.225 for Charness, whose sixth gamble gives up
  ## expected value (the paper: rho < -0.22). The open ends take the bound.
  ## Dai et al. 2018 used Ihli's menu in euros (28/28 ... 12/60, 2/70), and
  ## Capitan et al. 2026 the same menu in dollars (hypothetical).
  if (bibkey == "Ihli2022" | bibkey == "Charness2023" | bibkey == "Dai2018" | bibkey == "Capitan2026"){
    if (task == "EG") {
      ek <- c(-2.460, -0.161, 0.294, 0.501, if (bibkey == "Charness2023") 1.225 else 1.000)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 6) { out <- ek[5] }
    }
    ## Dai et al. 2018, loss set: EUR 40 endowment, then -12/-12, -16/-4,
    ## -20/4, -24/12, -28/20, -38/30 (online appendix, period 2 of part 1).
    ## Plus the 40 these are the gain menu exactly, so the same bounds.
    if (task == "EG_loss" & bibkey == "Dai2018") {
      ek <- c(-2.460, -0.161, 0.294, 0.501, 1.000)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 6) { out <- ek[5] }
    }
  }

  ## Hernandez-Arenaz and Iriberri 2023: eight 50/50 options read off the
  ## z-Tree program 3_Controles_withSVO.ztt (Payment_Risk by Risk_Pref), in
  ## euros: 1.5/1.5, 1.3/1.8, 1.1/2.1, 0.9/2.4, 0.7/2.7, 0.6/2.8, 0.4/2.9, 0/3.
  ## Expected values 1.50, 1.55, 1.60, 1.65, 1.70, 1.70, 1.65, 1.50: options 6
  ## to 8 are taken only by risk lovers, and 7 and 8 only by strong ones. Cuts
  ## -1.496, 0.165, 0.501, 0.651, exactly 1, 1.397, 1.493.
  if (bibkey == "HernandezArenaz2023"){
    if (task == "EG") {
      ek <- c(-1.496, 0.165, 0.501, 0.651, 1.000, 1.397, 1.493)
      if (choice <= 1) { out <- ek[1] }
      if (choice >= 2 & choice <= 7) { out <- runif(1, min = ek[choice - 1], max = ek[choice]) }
      if (choice >= 8) { out <- ek[7] }
    }
  }

  ## Dalton et al. 2020: Gneezy-Potters with VND 30,000; the amount invested is
  ## tripled with probability 1/2, so X + 2x or X - x ("participants could gain
  ## up to VND 90,000"). choice = VND invested.
  if (bibkey == "Dalton2020"){
    if (task == "IG") { out <- ig_crra(choice, X = 30000, k = 3) }
  }

  ## Haile et al. 2020: five choices between a sure 20, 15, 10, 6 or 2 ETB and
  ## a coin toss for 20 or 0 (Table 1 of the paper; the first row is the
  ## rationality check). choice = number of rows where the sure amount was
  ## taken, 1 to 5, so the certainty equivalent lies in [15, 20], [10, 15],
  ## [6, 10], [2, 6] or [0, 2]. r = log(0.5) / log(CE / 20) gives 2.409, 1,
  ## 0.576 and 0.301 at the inner ends; the top interval reaches the prize and
  ## is coded at its lower end, as ce_stair_crra does.
  if (bibkey == "Haile2020"){
    if (task == "CEPL") {
      lo <- c(15, 10, 6, 2, 0)[choice]
      hi <- c(20, 15, 10, 6, 2)[choice]
      out <- ce_stair_crra(lo, hi, X = 20, p = 0.5, top = log(0.5) / log(15 / 20))
    }
  }

  ## Georgalos, Paya and Peel 2023: tasks 5-9 are a five-row Holt-Laury list,
  ## option B 10 or 8, option A 19 or 1, chance of the high prize 10, 30, 50,
  ## 70, 90 percent. Indifference p*u(19) + (1-p)*u(1) = p*u(10) + (1-p)*u(8)
  ## with u = x^r gives r* = 2.753, 1.488, 0.808, 0.212, -0.608 for the five
  ## rows; the same routine returns the standard HL bounds (1.49, 0.85, 0.32,
  ## -0.37 at 30, 50, 70, 90 percent). choice = number of risky choices, all
  ## at the top of the list; the open ends are coded at their bound, as the
  ## standard HL block does.
  if (bibkey == "Georgalos2023"){
    if (task == "HL") {
      rk <- c(2.753, 1.488, 0.808, 0.212, -0.608)
      if (choice <= 0) { out <- rk[5] }
      if (choice >= 1 & choice <= 4) { out <- runif(1, min = rk[6 - choice], max = rk[5 - choice]) }
      if (choice >= 5) { out <- rk[1] }
    }
  }

  ## Kahsay et al. 2022: eight choices between a sure 50, 37.5, 30, 25, 20, 15,
  ## 10 or 5 ETB and a coin toss for 50 or 0 (Table 1). choice = number of rows
  ## where the sure amount was taken, 1 to 8, so the certainty equivalent lies
  ## in [37.5, 50], [30, 37.5], [25, 30], [20, 25], [15, 20], [10, 15],
  ## [5, 10] or [0, 5]. r = log(0.5) / log(CE / 50); the top interval reaches
  ## the prize and is coded at its lower end (2.409), as for Haile2020.
  if (bibkey == "Kahsay2022"){
    if (task == "CEPL") {
      lo <- c(37.5, 30, 25, 20, 15, 10, 5, 0)[choice]
      hi <- c(50, 37.5, 30, 25, 20, 15, 10, 5)[choice]
      out <- ce_stair_crra(lo, hi, X = 50, p = 0.5, top = log(0.5) / log(37.5 / 50))
    }
  }

  ## Crockett and Crockett 2019: the Holt-Laury payoffs times seven (A 11.20 or
  ## 14, B 0.70 or 26.95 dollars) on a 21-row list whose high-state
  ## probability rises 0, 0.05, ..., 1 (Table 2 of the paper). Indifference at
  ## p = 0.05 ... 0.95 gives the cuts below (the same routine returns the
  ## standard HL cuts 2.713, 1.487, 0.854, 0.324, -0.368 at p = .1, .3, .5,
  ## .7, .9). choice = number of B choices, 1 to 20 for a single switcher; B
  ## in row k means r above the cut of row k. The open ends take the bound.
  if (bibkey == "Crockett2019"){
    if (task == "HL") {
      ck <- c(3.477, 2.713, 2.266, 1.947, 1.696, 1.487, 1.305, 1.143, 0.994, 0.854,
              0.720, 0.589, 0.458, 0.324, 0.183, 0.029, -0.147, -0.368, -0.701)
      ## ck[j] is the cut at p = 0.05 * j; with n B choices the lowest B row has
      ## p = 0.05 * (21 - n) and the highest A row p = 0.05 * (20 - n)
      if (choice <= 1) { out <- ck[19] }
      if (choice >= 2 & choice <= 19) { out <- runif(1, min = ck[21 - choice], max = ck[20 - choice]) }
      if (choice >= 20) { out <- ck[1] }
    }
  }

  ## Adema, Nikolka, Poutvaara and Sunde 2022: 100 euros, the invested part
  ## is lost or returned 2.5 times with equal chance, so X + 1.5x or X - x --
  ## the Gneezy-Potters setting with k = 2.5. choice = euros invested.
  if (bibkey == "Adema2022"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 2.5) }
  }

  ## Chakraborty & Kendall 2026, lottery task 1: of $1.00, the amount withdrawn
  ## pays 1.5 per dollar and the c dollars left invested pay 2.2 or 1 with equal
  ## chance. Relative to withdrawing everything (1.50 for sure) each invested
  ## dollar gains 0.70 or loses 0.50, so this is ig_crra_pgl with wealth 1.5,
  ## g = 0.7 and l = 0.5; choice = cents invested. Investing everything (2.20 or
  ## 1.00) is coded at its bound, r = 0.573, as for the other assets with l < 1.
  if (bibkey == "Chakraborty2026"){
    if (task == "IG") { out <- ig_crra_pgl(choice / 100, X = 1.5, p = 0.5, g = 0.7, l = 0.5) }
  }

  ## Crosetto and Filippin 2023 (JRU, "Safe options and gender differences").
  ## HL baseline: the standard table (4/3.2 vs 7.7/0.2 euro), so the standard
  ## HL bounds. HLsafe (coded CEPL): option A is a sure 3.3, 3.4, 3.5, 3.5, 3.6,
  ## 3.7, 3.7, 3.8, 3.9, 4 euro (Table 3) against the same option B; hk[k] is
  ## the r = 1 - rho at which the sure amount in row k and option B are equally
  ## good, solved from the table. choice = number of risky (B) choices.
  ## EG and EGnosafe: 4/4, 6/3, 8/2, 10/1, 12/0 euro, and in EGnosafe lottery 1
  ## is 4.5/3.6 (Table 6), built so that the switch between lotteries 1 and 2
  ## stays at rho = 2; so both use the Crosetto2016 EG bounds.
  ## BRET and BRETsafe: 100 boxes; in BRETsafe the bomb is never in boxes 1-25,
  ## so for k >= 25 the expected utility is the baseline one times 100/75 and
  ## r = k/(100 - k) still holds; k = 25, the largest safe choice, is coded at
  ## its bound 1/3. Collecting all 100 boxes is coded at 10.
  if (bibkey == "Crosetto2023"){
    if (task == "HL") {
      rk <- c(2.71, 1.95, 1.49, 1.15, 0.85, 0.59, 0.32, 0.03, -0.37)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
    if (task == "CEPL") {
      hk <- c(2.717, 1.965, 1.515, 1.132, 0.855, 0.598, 0.310, 0.023, -0.370)
      if (choice == 10) { out <- hk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = hk[11 - choice], max = hk[10 - choice]) }
      if (choice <= 1) { out <- hk[9] }
    }
    if (task == "EG") {
      if (choice == 1) { out <- -1 }
      if (choice == 2) { out <- runif(1, min = -1, max = 0.33)}
      if (choice == 3) { out <- runif(1, min = 0.33, max = 0.62)}
      if (choice == 4) { out <- runif(1, min = 0.62, max = 0.80)}
      if (choice == 5) { out <- 1}
    }
    if (task == "BRET") {
      if (choice >= 100) { out <- 10 } else { out <- choice/(100-choice) }
    }
  }

  ## Zakharov and Bondarenko 2021: the Holt-Laury table times 12.5 (50/40 vs
  ## 96.25/2.5 RUR), so the standard HL bounds. choice = number of risky choices.
  if (bibkey == "Zakharov2021"){
    if (task == "HL") {
      rk <- c(2.71, 1.95, 1.49, 1.15, 0.85, 0.59, 0.32, 0.03, -0.37)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Dezso, Alm and Kirchler 2022: six 50/50 gambles in HUF, 2000/2000,
  ## 1700/2700, 1400/3400, 1100/4100, 800/4800, 100/5500 (Table 1). The paper's
  ## implied CRRA ranges (3.74, 1.25, 0.77, 0.55, 0) are relative risk aversion,
  ## so r = 1 - rho; the bounds are solved from the table. Gamble 6 has the same
  ## expected value as 5 and is coded at r = 1, as for Charness2019.
  if (bibkey == "Dezso2022"){
    if (task == "EG") {
      dk <- c(-2.737, -0.254, 0.230, 0.453, 1)
      if (choice == 1) { out <- dk[1] }
      if (choice >= 2 & choice <= 5) { out <- runif(1, min = dk[choice - 1], max = dk[choice]) }
      if (choice == 6) { out <- 1 }
    }
  }

  ## Forteza, Mussio and Pereyra 2024: a Holt-Laury list with option A $20 or
  ## $16 and option B $39 or $1 (Uruguayan pesos), so not quite the HL table
  ## times 10 (B would be 38.5 / 1); fk are the r = 1 - rho at the nine
  ## switching rows, solved from this table. choice = number of B choices.
  if (bibkey == "Forteza2024"){
    if (task == "HL") {
      fk <- c(2.672, 1.916, 1.462, 1.122, 0.836, 0.574, 0.311, 0.019, -0.376)
      if (choice == 10) { out <- fk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = fk[11 - choice], max = fk[10 - choice]) }
      if (choice <= 1) { out <- fk[9] }
    }
  }

  ## Angrisani et al. 2026: the BRET with 100 boxes, 1 to 99 may be collected,
  ## so r = k/(100 - k).
  if (bibkey == "Angrisani2026"){
    if (task == "BRET") { out <- choice/(100-choice) }
  }

  ## Campos-Mercade et al. 2021: 100 kr, invest 0, 20, ..., 100 kr, which is
  ## lost with probability 1/2 or returned 2.5 times; choice = kr invested.
  if (bibkey == "CamposMercade2021"){
    if (task == "IG") { out <- ig_crra(choice, X = 100, k = 2.5) }
  }

  ## Gibson et al. 2019 (LTIMS, Tonga and New Zealand; LOCAL ONLY until the
  ## World Bank agrees): eight 50/50 "businesses" in pa'anga, A 10/10, B 9/19,
  ## C 8/24, D 7/25, E 6/30, F 4/32, G 2/38, H 0/40. Solved from the table with
  ## u = x^r, the options that are best for some r are A (r < -6.506), B
  ## (-6.506, -0.743), C (-0.743, 0.188), E (0.188, 0.685), G (0.685, 1) and H
  ## (r > 1). D and F are mean-preserving spreads of C and E (same expected value,
  ## the authors' "inefficient" choices) and are best for no r; they are coded
  ## at the switch point next to them, D at C|E and F at E|G. Open ends take
  ## the bound.
  if (bibkey == "Gibson2019"){
    if (task == "EG") {
      if (choice == 1) { out <- -6.506 }
      if (choice == 2) { out <- runif(1, min = -6.506, max = -0.743) }
      if (choice == 3) { out <- runif(1, min = -0.743, max = 0.188) }
      if (choice == 4) { out <- 0.188 }
      if (choice == 5) { out <- runif(1, min = 0.188, max = 0.685) }
      if (choice == 6) { out <- 0.685 }
      if (choice == 7) { out <- runif(1, min = 0.685, max = 1) }
      if (choice == 8) { out <- 1 }
    }
  }

  ## Morais et al. 2023: Gneezy-Potters design, 100 units per round, 1/3 chance
  ## of gaining 2.5 times the bet, 2/3 chance of losing it; choice = units bet
  if (bibkey == "Morais2023"){
    if (task == "IG") { out <- ig_crra_pgl(choice, X = 100, p = 1/3, g = 2.5, l = 1) }
  }

  ## Barreiro-Hurle and Rommel 2025: static BRET, 100 boxes, 1 to 100 may be
  ## collected, so r = k/(100 - k); collecting all 100 is coded at 10.
  if (bibkey == "BarreiroHurle2025"){
    if (task == "BRET") {
      if (choice >= 100) { out <- 10 } else { out <- choice/(100-choice) }
    }
  }

  ## Holden et al. 2025: certainty-equivalent list, a sure amount in one week
  ## against 30,000 MWK with probability 0.75 in one week; the CE lies between
  ## grid[choice] and grid[choice + 1] (MWK 0, 100, 200, 400, 1000, 3000, 6000,
  ## ..., 30000). With u = x^r, CE = 30000 * 0.75^(1/r). The interval ending at
  ## 30,000 is coded at its lower end (r = 2.730); keeping the lottery against a
  ## sure 30,000 (choice 15) is dominated and coded at the ceiling.
  if (bibkey == "Holden2025"){
    if (task == "CEPL") {
      grid <- c(0, 100, 200, 400, 1000, seq(3000, 30000, by = 3000))
      if (choice <= 14) {
        out <- ce_stair_crra(lo = grid[choice], hi = grid[choice + 1], X = 30000,
                             p = 0.75, top = log(0.75) / log(27000 / 30000))
      }
      if (choice == 15) { out <- 10 }
    }
  }

  ## Ugur and Doganay 2024: 10 chocolates, the invested part is tripled or lost
  ## on a coin toss; choice = chocolates invested.
  if (bibkey == "Ugur2024"){
    if (task == "IG") { out <- ig_crra(choice, X = 10, k = 3) }
  }

  ## Hussam et al. 2022: a probability list, Tk 100 for sure against Tk 300 with
  ## probability p (else 0), p = 0.1, 0.2, ..., 0.9 down the rows. As for
  ## Chang2024, u = x^r gives r = log(p) / log(100/300) at the indifference p.
  ## choice = rows with the sure Tk 100 (0-9): the switch lies between
  ## p = choice/10 and (choice + 1)/10. choice 0 (the gamble already at 10%)
  ## only bounds r from below and is coded at the bound; choice 9 (the sure
  ## amount up to 90%) lies between 0 and the 90% bound.
  if (bibkey == "Hussam2022"){
    if (task == "HL") {
      pk <- c(2.096, 1.465, 1.096, 0.834, 0.631, 0.465, 0.325, 0.203, 0.096)
      if (choice == 0) { out <- pk[1] }
      if (choice >= 1 & choice <= 8) { out <- runif(1, min = pk[choice + 1], max = pk[choice]) }
      if (choice == 9) { out <- runif(1, min = 0, max = pk[9]) }
    }
  }

  ## Halko, Lappalainen and Saaksvuori 2021: the original Holt-Laury table in
  ## euros, so the standard bounds. choice = number of B choices.
  if (bibkey == "Halko2021"){
    if (task == "HL") {
      rk <- c(2.71, 1.95, 1.49, 1.15, 0.85, 0.59, 0.32, 0.03, -0.37)
      if (choice == 10) { out <- rk[1] }
      if (choice >= 2 & choice <= 9) { out <- runif(1, min = rk[11 - choice], max = rk[10 - choice]) }
      if (choice <= 1) { out <- rk[9] }
    }
  }

  ## Cust et al. 2024: 3000 FCFA, the invested amount is lost or returned 2.5
  ## times on a coin toss; choice = FCFA invested.
  if (bibkey == "Cust2024"){
    if (task == "IG") { out <- ig_crra(choice, X = 3000, k = 2.5) }
  }

  ## Vieider 2024: EUR 32 with 0.58 (else 0) against sure amounts 6 ... 25 in
  ## randomised binary choices; choice = the counted certainty equivalent (5.5
  ## ... 25.5, see clean_data.R), so r = log(0.58) / log(CE / 32) at that point.
  if (bibkey == "Vieider2024"){
    if (task == "CEPL") { out <- log(0.58) / log(choice / 32) }
  }

  ## Casal and Filippin 2024: static BRET, 10 x 10 boxes (99 pay 1 ECU, one
  ## bomb); choice = boxes collected, so r = k / (100 - k) as for Nielsen2019.
  ## Botchway and Filippin 2026: the same static BRET on paper, 100 steps of
  ## 0.5 cedi with one bomb; choice = steps taken.
  if (bibkey == "Casal2024" | bibkey == "Botchway2026"){
    if (task == "BRET") {
      if (choice == 100) { out <- 10 }
      if (choice != 100) { out <- choice/(100-choice) }
    }
  }

  ## A single ceiling and floor for the whole file, applied last.
  ##
  ## Several tasks inverted here are unbounded near a corner: the BRET and the
  ## static BART divide by the boxes left unopened, so 99 of 100 boxes gives
  ## r = 99; the Gneezy-Potters inversion divides by log(X + g*c) - log(X - l*c),
  ## which goes to zero as the investment does, so one hundredth of the
  ## endowment gives r = -129; and a certainty-equivalent interval that reaches
  ## the prize is coded at the r of its lower end, which can be 27.
  ##
  ## The file already names 10 as the value for such a corner -- the 100-box
  ## BRET and the 64-pump BART both say so in as many words -- but it only ever
  ## applied it at the exact corner, so the choices just short of it escaped.
  ## Clamping both ends at 10 applies that convention everywhere and leaves
  ## everything inside untouched. It is the last thing get_r does, so no draw
  ## from runif is affected and every value already within the range is
  ## reproduced unchanged.
  ##
  ## r = 10 is a relative risk aversion of -9 and r = -10 one of 11; past those
  ## the number is a property of the inversion, not of the subject.
  if (!is.na(out)) { out <- max(-10, min(10, out)) }
out
}
