import pandas

df_orig =  pandas.read_csv("../final_dataset.csv", sep=',')
df_lda = pandas.read_csv("../lda60_boolean.csv", sep='\t')
df_stm = pandas.read_csv("../stm_boolean_expanded.csv", sep='\t')
#df_lda = df_lda.sort_values(by='id')
#df_stm = df_stm.sort_values(by='id')
#print(df_lda[['id','ID']])
#print(df_orig)
#print(df_lda[['id', 'ID']])
#print(df_stm[['id', 'ID']])
#del df_lda['ID']
#del df_stm['ID']
print(df_stm.columns.values)

df = df_lda.join(df_stm, how='right', lsuffix='_lda')
print(df[['id', 'id_lda', 'ID','ID_lda']])
groupby = df.groupby('year')

#print groupby[['code', 'LinearSVC_label']].sum().corr()
print(groupby[['inequal_topic_lda', 'inequal_topic']].sum().corr())

#print df
#Calculate metrics for inequality code
tp1 = df[(df['inequal_topic_lda']==1) & (df['inequal_topic']==1)]
tn1 = df[(df['inequal_topic_lda']==0) & (df['inequal_topic']==0)]
fp1 = df[(df['inequal_topic_lda']==0) & (df['inequal_topic']==1)]
fn1 = df[(df['inequal_topic_lda']==1) & (df['inequal_topic']==0)]

tp1 = df[(df['inequal_topic']==1) & (df['inequal_topic_lda']==1)]
tn1 = df[(df['inequal_topic']==0) & (df['inequal_topic_lda']==0)]
fp1 = df[(df['inequal_topic']==0) & (df['inequal_topic_lda']==1)]
fn1 = df[(df['inequal_topic']==1) & (df['inequal_topic_lda']==0)]

trupos1 = float(len(tp1.index))
truneg1 = float(len(tn1.index))
falpos1 = float(len(fp1.index))
falsneg1 = float(len(fn1.index))

precision_inequl = trupos1/(trupos1 + falpos1)
recall_inequal = trupos1/(trupos1 + falsneg1)

f1_inequal = (2*(precision_inequl * recall_inequal))/(precision_inequl + recall_inequal)

print "Precision Inequality: %f" % precision_inequl
print "Recall Inequality: %f" % recall_inequal
print "F1 Inequality: %f" % f1_inequal

print(df_lda['inequal_topic'].sum())
print(df_stm['inequal_topic'].sum())

print(df[['inequal_topic', 'inequal_topic_lda']])