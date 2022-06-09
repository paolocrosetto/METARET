## function that translates choices into each different task
## into an 'r' risk parameter of a CRRA x utility funtion

### Comment calculer les bornes? 

## https://economics.stackexchange.com/questions/33003/how-to-calculate-crra-bounds-from-holt-and-laury-2002-type-lottery
## https://www.wolframalpha.com/input?i=1.11369
## ex. 16 ^ r * 0.5 + 72 ^  r * 0.5 = 0 ^ r * 0.5 + 84 ^ r * 0.5

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
    if (task == "IG") {
      if (choice == 8) { out <- 1  }
      if (choice == 0) { out <- -1  }
      if (choice != 8 & choice != 0) { out <- (-0.405465 -log(8 - choice) + log(8 + 1.5*choice))/(-log(8-choice) + log(8 + 1.5*choice))  }
    } 
    
    if (task != "HL" & task != "EG" & task != "IG") { out <- NA }
  }
  
  if (bibkey == "Crosetto2016") {
    
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
    
    if (task == "IG") {
      if (choice == 4) { out <- 1  }
      if (choice != 4) { out <- (log(4-choice) - log(4+3*choice) + log(3))/(log(4-choice) +log(2) - log(4+3*choice))  }
    }
    
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
    
    ## this is a bit iffy, to be changed
    if (task == "EG_loss") {
      if (choice == 1) { out <- -0.25 }
      if (choice == 2) { out <- runif(1, min = -0.25, max = 0.60)}
      if (choice == 3) { out <- runif(1, min = 0.60, max = 0.82)}
      if (choice == 4) { out <- runif(1, min = 0.82, max = 1)}
      if (choice == 5) { out <- 1}
    }
    
    if (task == "IG") {
      if (choice == 100) { out <- 1  }
      if (choice == 0) { out <- -1  }
      if (choice != 100 & choice != 0) { out <- (log(1/(2*(100-choice))) + log(100 + 2*choice))/(-log(100-choice) + log(100 + 2*choice))  }
    } 
    
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
        if (choice == 2) { out <- runif(1, min = -2.93) }
        if (choice == 1) { out <- -2.93 }
      }
    }
  
  if (bibkey == "Frey2017") {
    if (task == "BART") {
      out <- choice/(128-choice)
    }
    
    if (task == "HL"){
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
  
  if (bibkey == "Huber2019") {
    if (task == "BRET") {
      if (choice == 25) { out <- 10 }
      if (choice != 25) { out <- choice/(25-choice) }
    }
  }
  if (bibkey == "Brunner2014" | bibkey == "Dursch2012" | bibkey == "Proto2018" | bibkey == "Kirchkamp2021" | bibkey == "Roth2016" | bibkey == "Dursch2017") {
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
out
} 
