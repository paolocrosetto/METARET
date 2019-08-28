## function that translates choices into each different task
## into an 'r' risk parameter of a CRRA x utility funtion

get_r <- function(task, choice) {
  
  if (task == "EG") {
    if (choice == 1) { out <- -2.45 }
    if (choice == 2) { out <- runif(1, min = -2.45, max = -0.16)}
    if (choice == 3) { out <- runif(1, min = -0.16, max = 0.29)}
    if (choice == 4) { out <- runif(1, min = 0.29, max = 0.50)}
    if (choice == 5) { out <- runif(1, min = 0.50, max = 1)}
    if (choice == 6) { out <- 1}
  }
  
  if (task == "HL") {
    if (choice == 0) { out <- 2.71   }
    if (choice == 1) { out <- runif(1, min = 1.95, max = 2.71) }
    if (choice == 2) { out <- runif(1, min = 1.49, max = 1.95) }
    if (choice == 3) { out <- runif(1, min = 1.15, max = 1.49) }
    if (choice == 4) { out <- runif(1, min = 0.85, max = 1.15) }
    if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
    if (choice == 6) { out <- runif(1, min = 0.32, max = 0.59) }
    if (choice == 7) { out <- runif(1, min = 0.03, max = 0.32) }
    if (choice == 8) { out <- runif(1, min = -0.37, max = 0.03) }
    if (choice == 9) { out <- -0.37 }
    if (choice == 10) { out <- -0.37 }
  }
  
  if (task != "HL" & task != "EG") { out <- NA }
  
  out
}
