############## Description of dta_sccheat_analysis.xlsx #######################

June 4, 2022.

File dta_sccheat_analysis.xlsx contains raw data (encoded from paper) for
1) Battiston & al (2019)
2) Experiment I of Battiston & al (2021)
3) Experiment I of "What exactly is public in a public good game?" (Battiston,
  Gamba, Rizzolli, Rotondi, currently R&R)

... but risk variables are only employed in 1) and 2).

Notice that sessions "LAVIS1" and "PINZOLO1" were excluded from the analysis,
as explained in the paper 1) (Appendix C).


IDENTIFYING VARIABLES:
----------------------
- "Group": scout group (and session) identifier
- "ID": individual identifier, unique within Group
- "Squadriglia": scout patrol (numbered within Group)
- "treat_group": "True" means payments from phase I went to patrol, "False"
                 means they went to individual participant.


RISK-RELATED QUESIONNAIRE VARIABLES:
------------------------------------

Risk propensity is measured with a reduced version of the Domain-Specific
Risk-Taking (DOSPERT) Scale (Blais and Weber, 2006),

This is the relevant excerpt of the questionnaire. Each question is preceded
by the related variable name (parts between square brakets were not shown):

###############################################################################

* For each of the following statements, please indicate the likelihood that
you would engage in the described activity or behavior if you were to find
yourself in that situation. Provide a rating from Extremely Unlikely to
Extremely Likely, using the following scale:

[A 7-item Likert scale was used. Each of the following items was followed
by check boxes with numbers from 1–7.]

[att1] Going down a ski run that is beyond your ability. [Recreational]

[att2] Investing 10% of your annual income in a start-up. [Financial]

[att3] Betting a day’s income on the outcome of a sporting event. [Financial]

[att4] Revealing a friend’s secret to someone else. [Ethical]

[att5] Riding a motorcycle without a helmet. [Health/Safety]

[att6] Speaking your mind about an unpopular issue in a patrol meeting. [Social]

[att7] Bungee jumping off a tall bridge. [Recreational]

[att8] Walking home alone at night in an unsafe area of town. [Health/Safety]

[att9] Moving to a city far away from your parents. [Social]

[att10] Not returning a wallet you found that contains e200. [Ethical]

###############################################################################


Empty cells indicate missing answers.


REFERENCES:
-----------

Battiston, P., S. Gamba, M. Rizzolli and V. Rotondi (2021). Lies have long
legs: cheating, peer scrutiny and loyalty in teams. Journal of Behavioral and
Experimental Economics, 94, 101732.

Battiston, P., Gamba, S., Rotondi V. (2019), What does a young cheater look
like? An innovative approach. In Bucciol, A. and Montinari, N., editors,
Dishonesty in Behavioral Economics, Elsevier

Blais, A.-R. and E. U. Weber (2006). A domain-specific risk-taking (DOSPERT)
scale for adult populations. Judgment and Decision Making 1 (1), 33–47. 5.2
