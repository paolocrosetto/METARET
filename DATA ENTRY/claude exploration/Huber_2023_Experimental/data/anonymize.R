options(stringsAsFactors=FALSE)

dataDir <- "C:/Users/jaspersen/Desktop/RPW/Final/" 

data <- read.csv(file = paste0(dataDir,"data.csv"), sep=",",header = TRUE)

users <- unique(data$userid)
n <- length(users)

# The numbers below (281/ 35/ 245/ 32/ 59/ 159) are taken directly from Table 2 in the paper

rand <- runif(n, min = 0, max = 1)
thresh = 281/2216
germany <- ifelse(rand>thresh,1,0)
for(i in 1:n){
  user_id <- users[i]
  data$germany[which(data$userid == user_id)] <- germany[i]
}

rand <- runif(n, min = 0, max = 1)
thresh <- 35/2216
thresh2 <- 245/2216
sex <- ifelse(rand>thresh2,"Male",
              ifelse(rand>thresh,"Female","Non Binary"))
for(i in 1:n){
  user_id <- users[i]
  data$sex[which(data$userid == user_id)] <- sex[i]
}

rand <- runif(n, min = 0, max = 1)
thresh <- 32/2216
thresh2 <- 59/2216
thresh3 <- 159/2216
cAge <- ifelse(rand>thresh3,"16-25",
              ifelse(rand>thresh2,"26-35",
                     ifelse(rand>thresh,"36-45","> 45")))
for(i in 1:n){
  user_id <- users[i]
  data$cAge[which(data$userid == user_id)] <- cAge[i]
}

write.csv(data,paste0(dataDir,"data_anon.csv"), row.names = FALSE)