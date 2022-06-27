This README file was generated on July 23, 2021 by ANDREAS DRICHOUTIS.

The replication package has been deposited at the Open Science Framework (available at https://osf.io/sqk4a/) and contains all the necessary files to replicate the results of the paper. The general structure of the analysis to replicate the results is described below:

1. Anonymized data are contained in the Stata formated file "data.dta". This data file has been compiled from the raw *.tsv files exported from Qualtrics and other data sources described in the paper. 

2. The "MAIN_SYNTAX.do" includes detailed comments as labels that clearly indicate which tables and figures certain portions of code are reproducing. The code might take >1 hour to run depending on computer power. The file "RESULTS.txt" provides an output of the results that will be reproduced by running the "MAIN_SYNTAX.do" file.

-------------------
GENERAL INFORMATION
-------------------

Title of Dataset: Data and codes accompanying the paper entitled "On the stability of risk and time preferences amid the COVID-19 pandemic".

Author Information: Andreas Drichoutis, Agricultural University of Athens, 11855, Iera Odos 75, adrihout@aua.gr; Rodolfo M. Nayga. Jr., Department of Agricultural Economics, Texas A&M University, College Station, TX 77843, USA, rnayga@tamu.edu.

Date of data collection: 30.1.2019-20.3.2019 (2019 wave), 29.1.2020-16.3.2020 (2020A wave), 23.3.2020-28.5.2020 (2020B wave)

Geographic location of data collection: Online panel of students from the Agricultural University of Athens, Athens, GREECE.

Description of the experiment: Details are provided in the paper.

Eligibility requirements for subjects:  There were no particular eligibility requirements except that subjects should be students at the university which was the case because subjects were recruited using the online recruitment system for students.

--------------------------
SHARING/ACCESS INFORMATION
-------------------------- 

Licenses/restrictions placed on the data, or limitations of reuse: Permission to use with appropriate citation.

Recommended citation for the data: Drichoutis, Andreas and Nayga, Rodolfo, M. Jr. (2021) On the stability of risk and time preferences amid the COVID-19 pandemic. Open Science Framework. Available at https://osf.io/sqk4a/


--------------------
DATA & FILE OVERVIEW
--------------------

File list (filenames, directory structure (for zipped files) and brief description of all data files): Run the "MAIN_SYNTAX.do" file. Every other file is called from within this file. The "MAIN_SYNTAX.do" will use the data.dta file and other excel files as inputs to generate graphs and results. 

--------------------------
METHODOLOGICAL INFORMATION
--------------------------

Description of methods used for collection/generation of data: Data were collected online via Qualtrics. The file "risktime.qsf" can be imported in Qualtrics in order to reconstruct the questionnaire from the 2020B wave. Similar questions have been used in previous waves.

Methods for processing the data: The file "data.dta" contains compiled data from the *.tsv Qualtrics files and other sources as described in the paper.

Software information needed to process the data: Stata ver. 16 was used.

People involved with sample collection, processing and analysis: Andreas Drichoutis

-----------------------------------
SHORT DESCRIPTION OF MAIN VARIABLES
-----------------------------------

In general, when running the "MAIN_SYNTAX.do" file to replicate the analysis and results, variables and their values will be labelled. Below we provide a description for some of the main variables used in the analysis but labels provided in the do file will be more explanatory.

AM: anonymized unique ID variable
wave: Wave indicator
nchoice: Numbers choices each subject made in the risk and time preferences tasks. Runs from 1 to 50.
time1: Self reported time preferences question: "Are you generally an impatient person, or someone who always shows great patience?"
time2: Self reported time preferences question: "Are you generally an impulsive person, or someone who always shows great caution?"
bis_1-bis_15: Components of the Barratt Impulsiveness Scale.
riskinvestment: Risk investment question
dospert_1-dospert_15: Components of the DOSPERT scale.
choices: Indicates left, middle or right choice in the risk/time preferences tasks.
gender: Subjects' gender
byear: Birth year
hsize: Household size
regyear: Start year at the university
smokestatus: Smoking status
corona_*: All corona related variables. These are labeled appropriately once the syntax is run.
Accepted: Dummy, indicates subjects that accepted electronic transfers
ra: Dummy, indicates Risk Aversion task=1, Time preferences task=0
principal: principal amount in the time preferences task
horizon: time horizon in the time preferences task
DelaeydP: Middle payment option (as per Table 5 in the paper).
DelaeydP2: Payment option B (as per Table 5 in the paper).
RowProbA: Probability of left hand side prize in a lottery
RowProbB: Probability of right hand side prize in a lottery
Vprizea1: Left hand side Lottery A prize  
Vprizea2: Right hand side Lottery A prize  
Vprizeb1: Left hand side Lottery B prize  
Vprizeb2: Right hand side Lottery B prize  
fed: Front end delay
cases: N of cases in subject's region the day s/he took the survey
deaths: N of deaths in subject's region the day s/he took the survey 
pop_11: Populaation in subject's region
cases_adj: cases/pop_11
deaths_adj: deaths/pop_11