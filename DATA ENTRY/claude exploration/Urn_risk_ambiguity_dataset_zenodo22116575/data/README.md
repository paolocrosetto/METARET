# An Anonymized Urn-Based Experimental Dataset on Decision-Making under Risk and Ambiguity

This repository contains an anonymized dataset from controlled behavioral experiments on decision-making under risk and ambiguity using Ellsberg-type urn tasks.

The data were collected in two complementary implementations:

- **Experiment I:** laboratory experiment
- **Experiment II:** online experiment

Participants made decisions under different levels of information about the composition of lottery urns. In each task, they reported the maximum stake they were willing to place in order to participate in a subsequent lottery. In selected tasks, participants also chose the color on which they wished to bet. Experiment II additionally contains post-experimental evaluations of perceived uncertainty.

## Dataset overview

The release contains **4,486 decision records** associated with **246 adult participant records** across the two experiments.

Participant identifiers are experiment-specific. The total of 246 participant records should therefore not be interpreted as a verified count of unique physical persons across both experiments.

### Experiment I

- 203 adult participant records
- 2,960 decision records
- 14 experimental sessions
- laboratory implementation with monetary payoffs

### Experiment II

- 43 participant records
- 1,526 decision records
- 4 experimental sessions
- online implementation with point-based rewards
- repeated participation for a subset of participants
- post-experimental subjective uncertainty evaluations

## Files

### Main datasets

- `ambiguity_experiment_I_anonymized.xlsx`  
  Anonymized laboratory experiment dataset.

- `ambiguity_experiment_II_anonymized.xlsx`  
  Anonymized online experiment dataset.

### CSV exports

- `experiment_I_csv.zip`  
  CSV exports corresponding to the worksheets of Experiment I.

- `experiment_II_csv.zip`  
  CSV exports corresponding to the worksheets of Experiment II.

### Experimental materials

- `experimental_materials.zip`  
  Participant-facing experimental materials, including task pages and graphical urn illustrations.

### Documentation

- `CODEBOOK.md`  
  Description of variables, tables, identifiers, units, and coding conventions.

## Data structure

Both experiments contain the following main relational tables:

- `sessions` — de-identified experimental session metadata
- `participants` — de-identified participant-level demographic information
- `games` — definitions of experimental tasks
- `responses` — main decision-level response table
- `draws` — realized lottery outcomes

Experiment II additionally contains:

- `questionnaire` — post-experimental evaluations of perceived uncertainty

The tables can be linked using shared identifiers such as:

- `session_id`
- `participant_id`
- `game_id`

The `responses` table is the main fact table and contains one row per participant decision.

## Experimental tasks

The experiment contains several types of urn-based decision problems:

1. **Ignorance tasks**  
   Neither the total number of balls nor the proportions of individual colors are specified.

2. **Uniform benchmark tasks**  
   The urn contains 30 balls, with exactly 5 balls of each of six colors.

3. **One-red-in-N tasks**  
   The urn contains N = 5,...,12 balls, exactly one of which is red. The distribution of the remaining colors is unspecified.

4. **Ellsberg-type tasks**  
   The urn contains 15 balls of three possible colors, including exactly 5 red balls and an unknown distribution of the remaining colors.

Full task descriptions are provided in the accompanying experimental materials and in the related data-descriptor preprint.

## Interpretation of stake responses

The recorded stake represents the maximum amount that a participant stated they were willing to stake in order to participate in the subsequent lottery.

These responses may be interpreted as **proxies for willingness to pay within the implemented incentive mechanism**.

The elicitation mechanism differs from standard incentive-compatible procedures such as the Becker-DeGroot-Marschak mechanism. Participants were selected for realized lotteries based on their relative stakes rather than by comparison with an independently randomized price.

Analyses sensitive to incentive compatibility should therefore interpret the recorded values as incentivized stake or bid responses rather than strict incentive-compatible willingness-to-pay measurements.

## Anonymization and data processing

The public release was prepared from pseudonymized source data.

The following information was removed or transformed before public release:

- original participant nicknames
- e-mail addresses
- free-text school or institution fields
- exact ages
- original session names
- exact timestamps

Exact ages were replaced by age groups.

Five source participants younger than 18 and their **58 decision records** were excluded because the project archive did not contain documentation of guardian permission for unrestricted public publication of their individual-level data.

No behavioral outlier filtering or trimming was applied.

The transformation from the source files was limited to:

- privacy protection
- relational repair
- schema normalization
- conversion of response times to integer seconds
- explicit representation of stake and payoff units

## Missing values

Missing values are represented by blank cells in the Excel files and corresponding empty fields in the CSV exports.

## Potential reuse

The dataset can support:

- comparisons of decision-making under risk and ambiguity
- analyses of ambiguity attitudes
- analyses of stake or bid responses
- comparisons of continuous valuations and discrete choices
- analyses of behavioral stability and repeated participation
- comparisons of subjective and objective uncertainty
- replication studies
- methodological benchmarking
- teaching and demonstration

## Related publication

A methodological analysis of the experimental framework is presented in:

Jiroušek, R., and Kratochvíl, V. (2021).  
**Ambiguity effect: Decision-making influenced by lack of information.**  
2021 IEEE International Conference on Technology and Entrepreneurship (ICTE), 1–6.  
https://doi.org/10.1109/ICTE51655.2021.9584706

A separate data-descriptor preprint describes this anonymized public release:

**An Anonymized Urn-Based Experimental Dataset on Decision-Making under Risk and Ambiguity**

## License

This dataset is released under the **Creative Commons Attribution 4.0 International license (CC BY 4.0)**, as specified in the Zenodo record metadata.

## Contact

**Václav Kratochvíl**  
Institute of Information Theory and Automation, Czech Academy of Sciences  
Faculty of Management, Prague University of Economics and Business  

E-mail: velorex@utia.cas.cz
