#!/usr/bin/Rscript

library(topicmodels)
library(tm)

setwd("<working directory path name>") #set this to the working directory

df <-read.csv("final_dataset.csv", header=TRUE, sep =",", quote = "\"") #read in CSV file, one text per line. Note data is not included in the replication repository because of copyright issues
head(df)
m <- list(Content="text")
head(m)
myReader <- readTabular(mapping=m)
a <- VCorpus(DataframeSource(df), readerControl = list(reader = myReader)) #create corpus containing the text column, on line per document
#corp <- Corpus(x=newspaper_text, readerControl=list(reader=readTabular(mapping=m),language="en"))
a <- Corpus(VectorSource(df$text)) #$text points to the name of the column that contains the text (the name of the column is text)



#summary(a) #should tell you how many documents are in your corpus
#inspect(a[1:2]) #check the content of the first document in the corpus

a <- tm_map(a, content_transformer(tolower), mc.cores=1)
a <- tm_map(a, content_transformer(removePunctuation), mc.cores=1) 
a <- tm_map(a, content_transformer(removeNumbers), mc.cores=1)
a <- tm_map(a, removeWords, stopwords("english"), mc.cores=1)

library(SnowballC) # needed for stemming function

a <- tm_map(a, stemDocument, lazy=TRUE)#, language = "english") # converts terms to tokens
a.dtm <- TermDocumentMatrix(a, control=list(minDocFreq = 2)) #convert to term document matrix, words have to be in at least minDocFreq to appear, I set it to 2, but you can change this.

a.dtm.sp <- removeSparseTerms(a.dtm, sparse=0.95) #remove sparse terms
a.dtm.sp.df <- as.data.frame(inspect(a.dtm.sp)) # convert document term matrix to data frame

require(topicmodels)


#Now we produce the model

lda60 <- LDA(a.dtm.sp.t.tdif,60) # generate a LDA model with 60 topics

get_terms(lda60, 20)

gamma <- lda60@gamma # create object containing posterior topic distribution for each document

g <- data.frame(gamma)
g$ID <- seq.int(nrow(g))
df$ID <- seq.int(nrow(df))

df_all <- merge(df, g, on="ID")


#######################
#Put output into various csv files
write.csv(df_all, file = "lda60_docdist.csv")
save.image("lda60.RData")
