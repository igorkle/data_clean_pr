clean data project
=============

# Introduction

The raw data were collected by Anguita et al. (2012) and are freely available at:

[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
 
Anguita et al. (2012) have collected their data in experiments  with a group of 30 volunteers (the *subjects*). Each person performed six *activities*  wearing a smartphone  on the waist. The  signals measured during these activities were then subjected to additional filtering and transformations. In total, 561 features were reported per observation.  

A detailed description of the original study design and of the features that were reported can be found in  CODE\_BOOK.md (available in this repository). 

From this initial set of features, we have selected all the variables expressing the means (mean()) and the standard deviations (std()) of each variable.  For each *subject-activity* pair, we have then calculated the average value (accross the observations) of these means and standard deviations for each feature.



#Instruction list

* Start from folder that include execution script
* Run run\_analysis.R  (execution can take for a while, du to download and unzip)
* The outputfile - new tidy data is in file new_tidy.txt


#Codebook

* The codebook that contain the detailed description of all variables can be found in CODE\_BOOK.md (available in that repository). 