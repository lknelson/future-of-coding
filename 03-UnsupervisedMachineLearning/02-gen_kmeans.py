from __future__ import print_function

__author__ = 'laura'

import string
import pandas
from nltk import word_tokenize
from nltk.stem import PorterStemmer
from nltk.corpus import stopwords
from sklearn.cluster import KMeans
from sklearn.feature_extraction.text import TfidfVectorizer
import csv


def process_text(text, stem=True):
    """ Tokenize text and stem words removing punctuation """
    text = text.translate(string.punctuation)
    tokens = word_tokenize(text)

    if stem:
        stemmer = PorterStemmer()
        tokens = [stemmer.stem(t) for t in tokens]
    return tokens


def cluster_texts(texts, clusters):
    """ Transform texts to Tf-Idf coordinates and cluster texts using K-Means """
    vectorizer = TfidfVectorizer(tokenizer=process_text,
                                 stop_words=stopwords.words('english'),
                                 max_df=0.5,
                                 min_df=0.1,
                                 lowercase=True)


    tfidf_model = vectorizer.fit_transform(texts)
    terms = vectorizer.get_feature_names()
    print(vectorizer)
    km_model = KMeans(n_clusters=clusters)
    km_model.fit(tfidf_model)
    clustering = km_model.labels_.tolist()


    print("Top terms per cluster:")
    print()
    #sort cluster centers by proximity to centroid
    order_centroids = km_model.cluster_centers_.argsort()[:, ::-1]
    for i in range(clusters):
        column_title = ("Cluster %d words:," % i)
        #print(column_title)
        term_list = []
        for ind in order_centroids[i, :20]: 
           row_terms = (terms[ind].split(' '))
           term_list.append(row_terms)
        print(column_title,term_list)


    return clustering


if __name__ == "__main__":

    df = pandas.read_csv("<filename") #Note the data is not in the replication repository because of copyright issues

    articles = df['text']
    clusters = cluster_texts(articles, 30)
    df['clusters'] = clusters
    print(df['clusters'].value_counts())
    df.to_csv("../data/kmeans30.csv", header = True, sep = '\t', index = False, quoting = csv.QUOTE_MINIMAL)
