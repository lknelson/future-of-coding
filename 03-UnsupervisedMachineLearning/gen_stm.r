library(stm)

#setwd() #set working directory to your home directory

### Load Data

df <- read.csv("<filename>")
df <- df[ which (df$code!=5),]
namesdf)
)
####################################
######### Pre-processing ###########
####################################


temp<-textProcessor(documents=df$text,metadata=df)
meta<-temp$meta
vocab<-temp$vocab
docs<-temp$documents
out <- prepDocuments(docs, vocab, meta)
docs<-out$documents
vocab<-out$vocab
meta <-out$meta
meta$text <- as.character(meta$text)

#head(meta)

set.seed(02138)

#plotRemoved(out$documents,lower.thresh=seq(1,200,by=100))

##################################
######### Choose Model ###########
##################################


### Model search across numbers of topics

storage <- manyTopics(docs,vocab,K=c(10,20,30,40,50,60),prevalence=~year,data=meta,runs=10,max.em.its=15)

mean(storage$exclusivity[[3]])


mod.10 <- storage$out[[1]]
mod.20 <- storage$out[[2]] # most coherent
mod.30 <- storage$out[[3]] 
mod.40 <- storage$out[[4]] # most exclusive 
mod.50 <- storage$out[[5]]

model <- mod.60
# Labels
labelTopics(model)

save.image("stm_allmodels.RData")


labels <- labelTopics(model, n=20)

write.csv(labels$prob, file="stm60_terms.csv")
write.csv(labels$frex, file="stm60_terms_frex.csv")

findThoughts(model,texts=meta$text,n=5,topics=47)$docs[[1]]

meta$ID <- seq.int(nrow(df))
theta <- data.frame(model$theta)
theta$ID <- seq.int(nrow(theta))

df_all <- merge(meta, theta)
df_all$X1

write.csv(df_all, file="stm60_theta.csv")
