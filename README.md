# The Future of Coding

Replication repository for Nelson, Laura K., Derek Burk, Marcel Knudsen, and Leslie McCall. Forthcoming. "The Future of Coding: A Comparison of Hand-Coding and Three Types of Computer-Assisted Text Analysis Methods." *Sociological Methods and Research*. 


### Code:

* 01-SupervisedMachineLearning contains code to replicate the supervised machine learning results using Python's scikit-learn, R's RTextTools, and the StanfordNLP classifier, as well as the accuracy metrics for these methods.
* 02-Dictionries contains the code to reproduce the results from the two dictionary methods
* 03-UnsupervisedMachineLearning contains code to reproduce the k-means analysis, the Latent Dirichlet Allocation topic model, and the Structural Topic Model, as well as the accuracy metrics from these methods.
* `gen_graph.do` reproduces the figures in the paper

### Data:

Sharable data are in the `data` folder. Because of copyright restrictions we cannot share the full text of the articles. Instead, we provide a number of different versions of the data that enable partial reproduction of our results.

1. `final_dataset.csv` contains the following variables:
	* ID - article ID
	* year - year article was published
	* code - the hand-coded code (see page 7, Figure 1 in the paper)
		* 1 = explicit discussion of inequality
		* 2 = implicit discussion of inequality
		* 3 = discussion of wages of income (but not inequality)
		* 4 = discussion of employmentand macroeconomic conditions (but not inequality) 
		* 5 = discussion of irrelevant economic and non-economic issues
	* weight - weight based on stratified random sample of articles (see pages 5-6)
	* code_label - text indicating the label of the numerical code (explicit, implicit, relchanges, releconomy, irrelevant)
	* binary1 - code based on the first binary coding scheme (see page 12)
	* binary2 - code based on the second binary coding scheme (see page 12)
	* binary3 - code based on the third binary coding scheme (see page 12)
	* three_code1 - code based on the first three-code coding scheme (see page 12)
	* three_code2 - code based on the second three-code coding scheme (see page 12)
	* three_code3 - code based on the third three-code coding scheme (see page 12)
	* four_code - code based on the first four-code coding scheme (see page 12)
	* four_code2 - code based on the second four-code coding scheme (see page 12)

2. `mccall_doc_term_matrix_and_hand_code.Rdata` - the document-term matrix for the full text, in an .Rdata file. This file can be used to train your own classifier based on our hand-coded data.
3. `kmeans30.csv` - results from the 30-cluster k-means analysis, to reproduce the accuracy metrics and graphs for the Unsupervised Machine Learning results
	* ID - article ID
	* clusters - cluster number, n=30
4. `lda60_docdist.csv` - topic weights for the 60-topic LDA model, and article ID, to reproduce the accuracy metrics and graphs for the Unsupervised Machine Learning results
5. `stm60_theta.csv` - topic weights for the 60-topic STM model, and article ID, to reproduce the accuracy metrics and graphs for the Unsupervised Machine Learning results
6. `python_sml_results.csv` - results from the Python support vector machine classifier, for all coding schemes, to reproduce the accuracy metrics and graphs for the Supervised Machine Learning results
7. `python_sml_results_testset.csv` - results from the Python support vector machine classifier, for all coding schemes, test set only, to reproduce the accuracy metrics and graphs for the Supervised Machine Learning results
