import sys
import numpy as np
from StringIO import StringIO
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.datasets import load_files
from sklearn.cross_validation import train_test_split
from sklearn import metrics
from sklearn.pipeline import Pipeline
from sklearn.svm import LinearSVC, SVC
from sklearn.naive_bayes import MultinomialNB
from sklearn import tree
import pandas
import csv
from sklearn.ensemble import RandomForestClassifier



## make a Multinomial-NB and CountVectorized pipeline by default
## or switch in tf-idf as your vectorizer, and LinearSVC for your classifier
def easy_pipeline(vect = 'tfidf', clf = 'lsvc', min_df = 0.01, max_df = 0.95, stop_words = None, decode_error = 'ignore'):
  if vect == 'tfidf':
    V = TfidfVectorizer
  else:
    V = CountVectorizer
 
  if clf == 'lsvc':
    C = LinearSVC
  else:
    C = MultinomialNB
 
 
  pipeline = Pipeline([
      ('vect', V(min_df=min_df, max_df=max_df, stop_words = stop_words, decode_error = decode_error)),
      ('clf', C()),
  ])
  return pipeline
 
## Print the precision/recall/F1 numbers per label, and also
##  the top-10 most informative features per label
def print_metrics(pipeline, data_folder, test_size = 0.25):
  dataset = load_files(data_folder, shuffle = False)
  docs_train, docs_test, y_train, y_test = train_test_split(
    dataset.data, dataset.target, test_size = test_size, random_state=None)
  pipeline.fit(docs_train, y_train)
  y_predicted = pipeline.predict(docs_test)
  # print report
  print(metrics.classification_report(y_test, y_predicted, target_names = dataset.target_names))
  ## print out top 10 words
  clf = pipeline.steps[1][1]
  vect = pipeline.steps[0][1]
  for i, class_label in enumerate(dataset.target_names):
              topt = numpy.argsort(clf.coef_[i])[-10:]
              print("%s:    %s" % (class_label,
                    ", ".join(vect.get_feature_names()[j] for j in topt)))
 
sh_dataset = pandas.read_csv("../../data/final_dataset.csv")

#df_tc = sh_dataset
#sh_dataset = sh_dataset
#df_b2 = sh_dataset

sh_dataset['b1'] = sh_dataset['code']
sh_dataset['b1'][sh_dataset['code']==2]=1
sh_dataset['b1'][sh_dataset['code']==3]=1
sh_dataset['b1'][sh_dataset['code']==4]=1
sh_dataset['b1'][sh_dataset['code']==5]=2
#print sh_dataset['relineq']

sh_dataset['b2'] = sh_dataset['code']
sh_dataset['b2'][sh_dataset['code']==2]=1
sh_dataset['b2'][sh_dataset['code']==3]=2
sh_dataset['b2'][sh_dataset['code']==4]=2
sh_dataset['b2'][sh_dataset['code']==5]=2

sh_dataset['tc'] = sh_dataset['code']
sh_dataset['tc'][sh_dataset['code']==2]=1
sh_dataset['tc'][sh_dataset['code']==3]=2
sh_dataset['tc'][sh_dataset['code']==4]=2
sh_dataset['tc'][sh_dataset['code']==5]=3

sh_dataset['fc'] = sh_dataset['code']
sh_dataset['fc'][sh_dataset['code']==2]=2
sh_dataset['fc'][sh_dataset['code']==3]=3
sh_dataset['fc'][sh_dataset['code']==4]=3
sh_dataset['fc'][sh_dataset['code']==5]=4


labels = [1, 2, 3]#, 4, 5]

for n in range(10,11):
    trset = "trset_" + str(n)

    b2_docs_train = sh_dataset.text[sh_dataset[trset]==1].values
    b2_y_train = sh_dataset.b2[sh_dataset[trset]==1].values
    b2_docs_test = sh_dataset.text[sh_dataset[trset]==0].values
    b2_y_test = sh_dataset.b2[sh_dataset[trset]==0].values

    tc_docs_train = sh_dataset.text[sh_dataset[trset]==1].values
    tc_y_train = sh_dataset.tc[sh_dataset[trset]==1].values
    tc_docs_test = sh_dataset.text[sh_dataset[trset]==0].values
    tc_y_test = sh_dataset.tc[sh_dataset[trset]==0].values


    b1_docs_train = sh_dataset.text[sh_dataset[trset]==1].values
    b1_y_train = sh_dataset.b1[sh_dataset[trset]==1].values
    b1_docs_test = sh_dataset.text[sh_dataset[trset]==0].values
    b1_y_test = sh_dataset.b1[sh_dataset[trset]==0].values

    fc_docs_train = sh_dataset.text[sh_dataset[trset]==1].values
    fc_y_train = sh_dataset.fc[sh_dataset[trset]==1].values
    fc_docs_test = sh_dataset.text[sh_dataset[trset]==0].values
    fc_y_test = sh_dataset.fc[sh_dataset[trset]==0].values



    sh_pipeline = Pipeline([
    ('vect', TfidfVectorizer(lowercase=True, min_df=0, max_df=.95)),
    ('clf', SVC(C=1000, class_weight="auto", probability=True)),
    ])


    sh_pipeline2 = Pipeline([
    ('vect', TfidfVectorizer(lowercase=True, min_df=30, max_df=.95)),
    ('clf', LinearSVC(C=1000, class_weight="auto")),
    ])

    df = sh_dataset[sh_dataset[trset]==0]
    """
    sh_pipeline2.fit(b2_docs_train, b2_y_train)
    b2_y_predicted2 = sh_pipeline2.predict(b2_docs_test)
    df['linearSVC_binary2'] = b2_y_predicted2
    #print df[['id', 'LinearSVC_label', 'code']]
    """
    sh_pipeline2.fit(fc_docs_train, fc_y_train)
    fc_y_predicted2 = sh_pipeline2.predict(fc_docs_test)
    df['linearSVC_four_code2'] = fc_y_predicted2
    """
    sh_pipeline2.fit(b1_docs_train, b1_y_train)
    b1_y_predicted2 = sh_pipeline2.predict(b1_docs_test)
    df['linearSVC_binary1'] = b1_y_predicted2
    df_merge = pandas.merge(sh_dataset, df, how='outer', on=['title', 'year', 'month', 'text', 'journal', 'author', 'code', 'weight', 'code_label', 'id', 'binary1', 'binary2', 'three_code2', 'b1', 'b2', 'tc' ])
    print df_merge.columns.values
    #print df_merge[['b1', 'linearSVC_binary1']]
    cols_to_keep = ['title', 'year', 'month', 'text', 'journal', 'author', 'code', 'weight', 'code_label', 'id', 'binary1', 'binary2', 'three_code2', 'linearSVC_three_code2', 'linearSVC_binary1', 'linearSVC_binary2', 'b1', 'b2', 'tc']
    #print df_merge[['binary1','linearSVS_binary1']]
    #df_merge[cols_to_keep].to_csv("../python_sml_results.csv", header = True, sep = '\t', index = False, quoting = csv.QUOTE_MINIMAL)
    #df[cols_to_keep].to_csv("../python_sml_results_testset.csv", header = True, sep = '\t', index = False, quoting = csv.QUOTE_MINIMAL)
    #print df


    # print the results
    print "LinearSVC_b1"
    print(metrics.classification_report(b1_y_test, b1_y_predicted2, target_names = ["1", "2"]))
    print(metrics.confusion_matrix(b1_y_test, b1_y_predicted2))

    print "LinearSVC_b2"
    print(metrics.classification_report(b2_y_test, b2_y_predicted2, target_names = ["1", "2"]))
    print(metrics.confusion_matrix(b2_y_test, b2_y_predicted2))
    """
    print "LinearSVC_tc"
    print(metrics.classification_report(fc_y_test, fc_y_predicted2, target_names = ["1", "2", "3", "4"]))
    print(metrics.confusion_matrix(fc_y_test, fc_y_predicted2))

    class_labels = [1, 2, 3, 4]
    clf = sh_pipeline2.steps[1][1]
    #print clf
    vect = sh_pipeline2.steps[0][1]
    feature_names = vect.get_feature_names()
    for i, class_label in enumerate( class_labels ):
        #print 'processing index ', clf.coef_[i]
        topt = np.argsort(clf.coef_[i])[-40:]
        #print topt
        print("%s: %s" % (class_label, " ".join(feature_names[j] for j in topt)))

    coefs_with_fns = sorted(zip(clf.coef_[0], feature_names))
    top = zip(coefs_with_fns[:n], coefs_with_fns[:-(n + 1):-1])
    #print top
    #for (coef_1, fn_1), (coef_2, fn_2) in top:
    #    print "\t%.4f\t%-15s\t\t%.4f\t%-15s" % (coef_1, fn_1, coef_2, fn_2)
