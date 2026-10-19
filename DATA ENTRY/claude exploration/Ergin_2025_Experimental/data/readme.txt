May 27, 2025

Main scripts:
	bleichrodt_dataprep.do
	fork_dataprep.do
	trautmann_dataprep.do
	Replication_Ergin_Gurdal_Kuzubas(2024).do
	
Data files: 
	Bleichrodt_experiment_data.csv
	Fork_experiment_data.csv
	Noussair_experiment_data.csv

+-------------------------------------------+
| General                                   |
+-------------------------------------------+

Opening the data preparation scripts (bleichrodt_dataprep.do, fork_dataprep.do, and trautmann_dataprep.do) and 
executing them prepares the data for analysis. Running the main script Replication_Ergin_Gurdal_Kuzubas(2024).do 
reproduces all results reported in the paper 'The Fork Game: A Graphical Interface for Eliciting Higher-Order Risk Preferences'. 
Results are reported in the same order as in the main text of the paper.

Running the scripts requires all data files to be in the working directory. 

The scripts were run with Stata/SE 15.1 on Windows 10.

Required Stata packages:
- egenmore (for quantile analysis)
- Install with: ssc install egenmore

+-------------------------------------------+
| bleichrodt_dataprep.do                    |
+-------------------------------------------+

This script prepares data for the Bleichrodt and Bruggen (2022) replication experiment. 
It imports the raw CSV data from Bleichrodt_experiment_data.csv, cleans and structures the data for each treatment (Risk, Prudence, Temperance), 
and generates two output files: Bleichrodt_experiment_data.dta and Bleichrodt_survey.dta.

+-------------------------------------------+
| fork_dataprep.do                          |
+-------------------------------------------+

This script prepares data for the Fork Game experiment. 
It imports the raw CSV data from Fork_experiment_data.csv, cleans and structures the data for each treatment (Risk, Prudence, Temperance), 
and generates two output files: Fork_experiment_data.dta and Fork_survey.dta.

+-------------------------------------------+
| trautmann_dataprep.do                     |
+-------------------------------------------+

This script prepares data for the Noussair et al. (2014) replication experiment. 
It imports the raw CSV data from Noussair_experiment_data.csv, cleans and structures the data for each treatment (Risk, Prudence, Temperance), 
and generates two output files: Trautmann_experiment_data.dta and Trautmann_survey.dta.

+-------------------------------------------+
| Replication_Ergin_Gurdal_Kuzubas(2024).do |
+-------------------------------------------+

This is the main analysis script that reproduces all results reported in the paper. The script performs the following analyses in sequence:

1. Data Loading and Preparation
   - Combines all experimental data from the three games
   - Generates participant-level identifiers
   - Creates standardized GPS (Global Preference Survey) variables
   - Calculates choice variables by treatment

2. Descriptive Statistics
   - Summary statistics for choices by treatment and game (Tables 1, 6)
   - Tests against random choice using signrank tests
   - Correlation analysis (Tables 2, 7)

3. Visual Analysis
   - Histograms of choices (Figures 12, 14)
   - Comparisons across games (Figures 13, 16-18)
   - Decision time analysis (Figure 15)

4. Regression Analysis
   - Panel logit regressions by treatment and game (Tables 5, 15, 16)
   - Calculation of marginal effects
   - Inclusion of GPS preference variables

5. Comparison Analysis
   - Across games (Tables 7, 8, 9)
   - Across tasks within games (Tables 17-19)
   - Treatment-specific comparisons (Tables 12-14)

The script generates the following output files:
- experiment_data_all_rounds.dta: Combined dataset with all experimental rounds
- aggregate_experiment_data.dta: Participant-level aggregated data
- xtlogitfinal.dta: Dataset prepared for panel logit analysis
- analysis_results.dta: Results from pairwise comparison analysis
- pairwise_results.xlsx and pairwise_results_labeled.xlsx: Excel exports

+-------------------------------------------+
| Bleichrodt_experiment_data.csv            |
+-------------------------------------------+

This file contains the experimental data from the Bleichrodt and Bruggen (2022) replication. 
The data includes choice decisions, decision times, payoff parameters, and participant characteristics for all treatments (Risk, Prudence, Temperance).

+-------------------------------------------+
| Fork_experiment_data.csv                  |
+-------------------------------------------+

This file contains the experimental data from the Fork Game. 
The data includes choice decisions made using the graphical fork interface, decision times, payoff parameters, and participant characteristics 
for all treatments (Risk, Prudence, Temperance).

+-------------------------------------------+
| Noussair_experiment_data.csv              |
+-------------------------------------------+

This file contains the experimental data from the Noussair et al. (2014) replication. 
The data includes choice decisions, decision times, payoff parameters, and participant characteristics for all treatments (Risk, Prudence, Temperance).

+-------------------------------------------+
| Variable Definitions                      |
+-------------------------------------------+

Key Experimental Variables:
- treatment: Type of treatment - "Risk", "Prudence", or "Temperance"
- choice: Binary variable indicating risk-averse/prudent/temperate choice (main dependent variable)
- choice_risk, choice_pru, choice_temp: Aggregate choice variables by treatment
- w: Maximum payoff
- k, d: Parameters related to payoff differences
- e, e_1, e_2: Variables related to expected values and background risk
- ms: Decision time in milliseconds
- id: Unique identifier of the participant
- round: Round number (1-12) for each task
- outcome: Earning of the participant for the respective round
- game: Indicates experiment type - "Fork", "Bleichrodt", or "Trautmann"

Demographic and Survey Variables:
- demo_age: Age of the participant
- demo_sex: Gender (0 = female, 1 = male)
- demo_gpa: GPA of the participant
- demo_preexp: Previous participation in an experiment (binary)
- demo_dep: Department of the participant
- demo_econcourses: Number of economics courses taken (censored at 4)
- demo_difficulty: Self-assessed difficulty of the experiment (1-10)
- demo_sure: Confidence about the choices in the experiment (1-10)

Global Preference Survey (GPS) Variables:
- gps_general_risk: Willingness to take risk (1-10)
- gps_future_benefit: Willingness to give up something today
- gps_punish_self: Willingness to punish if oneself treated unfairly (1-10)
- gps_punish_others: Willingness to punish if others treated unfairly (1-10)
- gps_good_cause: Willingness to give for good causes (1-10)
- gps_describe_favor: Willingness to return a favor (1-10)
- gps_describe_revenge: Willingness to take revenge (1-10)
- gps_describe_intentions: Trust (1-10)
- gps_describe_math: Math skill (1-10)
- gps_describe_postpone: Procrastination (1-10)
- gps_stair_risk: Staircase risk measure (1-32)
- gps_gift: Size of the gift (positive reciprocity measure)
- gps_donation: Donation amount (altruism measure)
- gps_stair_patience: Patience measure (1-32)

Standardized GPS Preference Variables (created during analysis):
- risk: Standardized risk preference measure
- patience: Standardized patience measure
- pos_reciprocity: Standardized positive reciprocity measure
- neg_reciprocity: Standardized negative reciprocity measure
- trust: Standardized trust measure
- altruism: Standardized altruism measure
- math_skill: Standardized math skill measure

+-------------------------------------------+
| Experimental Framework Setup Guide       |
+-------------------------------------------+

The Fork Game experiment was implemented using a web-based graphical interface. 
For researchers interested in running the experiment or modifying the interface, the following information is provided:

System Requirements:
- Node.js: Version 18.0.0 or higher (https://nodejs.org/en)
- Dependencies: All required modules are pre-installed in the node_modules directory. To see the used modules, refer to the package.json file.

Development Environment Setup:
Initialize the development environment using the following command:
npm run dev

Configuration Options:

Experimental Condition Selection:
To modify the active experimental condition, navigate to the main application file:
- File Path: src/App.vue
- Locate line 140 and uncomment the desired experimental condition while commenting out any previously active conditions.

Server Integration Options:
The current application is uncoupled from the server infrastructure and logs experimental data to the browser console for verification purposes. 
To implement your own server, follow these steps:

1. Locate src/functions/updateData.js and uncomment lines 22–25
2. Locate src/components/IntroScreen.vue and uncomment line 97
3. Update the server URL in both locations to point to your research data collection endpoint

The server should be configured to accept JSON objects matching the schemas defined in the src/models directory.

Data Collection and Analysis:
Experimental data was originally stored as JSON objects in a MongoDB database. 
For statistical analysis, the JSON data from a custom server should be transformed into CSV format. 
A supplementary single-page application for this transformation is available upon request from the research team.

Sources and acknowledgments can be found at: https://github.com/emrergin/prudence-labversion/blob/main/README.md

+-------------------------------------------+
| Notes                                     |
+-------------------------------------------+

- The script uses expandcl to restructure the data. Ensure this command is available in your Stata installation.
- Some analyses require the xtile command from the egenmore package.
- Graphs use the s1mono scheme, which can be changed if preferred.
- Decision time analyses in milliseconds (variable ms) are also presented in seconds (ms_seconds).
- The treatment order variable indicates the sequence of Risk (R), Prudence (P), and Temperance (T) tasks presented to participants (e.g., "RPT" or "RTP").
- Variables with the gps_ prefix are from the Global Preference Survey methodology and are used to control for individual preference heterogeneity.
- In the panel logit models, standard errors are clustered at the participant level.
- The analysis includes non-parametric tests (Wilcoxon signed-rank, Mann-Whitney rank-sum) to compare distributions.

For questions about this replication package, please contact the authors.

+-------------------------------------------+
| Citation                                  |
+-------------------------------------------+

If you use this replication package, please cite:
Ergin, E., Gürdal, M. Y., & Kuzubaş, T. U. (2025). The Fork Game: A Graphical Interface for Eliciting Higher-Order Risk Preferences.