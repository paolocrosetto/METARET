## Holzmeister, F. & Stefan, M. (2019). The risk elicitation puzzle revisited: Across-methods (In)consistency?

*The paper is currently under review.*
*The preprint is available via [https://osf.io/pj9u2/](https://osf.io/pj9u2/]).*


The dataset `Holzmeister_Stefan.xlsx` contains the experimental data corresponding to the manuscript.
The experiment combined four widely-used risk preference eliciation procedures in a within-subject experimental design: (i) the "bomb" risk elicitation task (*BRET*; Crosetto & Filippin, 2013), (ii) a certainty equivalence method (*CEM*; Abdellaoui et al., 2011), (iii) a multiple price list (*MPL*; Holt & Laury, 2005), and a single choice list (*SCL*; Eckel & Grossman, 2008).

To generalize the data structure of the different methods, the data of all tasks is expressed in terms of a **series of binary choices between lottery pairs**. While this is the case for the certainty equivalence method and the multiple price list by default, data from the "bomb" risk elicitation task and the single choice list have been converted into implicit binary choices between adjacent gambles.


-----
### Variables:

* `task` (integer) ... identifier for each task.
    * 1 ... "bomb" risk elicitation task (*BRET*; Crosetto & Filippin, 2013)
    * 2 ... certainty equivalence method (*CEM*; Abdellaoui et al., 2011)
    * 3 ... multiple price list (*MPL*; Holt & Laury, 2005)
    * 4 ... single choice list (*SCL*; Eckel & Grossman, 2008)
    
* `pid` (string) ... unique alpha-numeric identifier for each participant.

* `k` (integer) ... numeric identifier of the binary choice between gambles within each task.
    * `k` = {0...100} for *BRET* (`task` = 1)
    * `k` = {1...9} for *CEM* (`task` = 2)
    * `k` = {1...10} for *MPL* (`task` = 3)
    * `k` = {1...6} for *SCL* (`task` = 4)
    
* `choice` (integer) ... binary indicator for participants' choices between gabmles
    * `choice`= 0 indicates that lottery "A" is revealed preferred
    * `choice`= 1 indicates that lottery "B" is revealed preferred
    * **Note:** The sum of `choice` per task corresponds to the number of risky choices for *CEM* and *MPL*, the number of boxes selected in *BRET*, and the chosen lottery in *SCL*.
    
* `p_ah` (decimal) ... probability of the payoff "high" in lottery "A"

* `x_ah` (decimal) ... payoff "high" in lottery "A"

* `p_al` (decimal) ... probability of the payoff "low" in lottery "A"

* `x_al` (decimal) ... payoff "low" in lottery "A"

* `p_bh` (decimal) ... probability of the payoff "high" in lottery "B"

* `x_bh` (decimal) ... payoff "high" in lottery "B"

* `p_bl` (decimal) ... probability of the payoff "low" in lottery "B"

* `x_bl` (decimal) ... payoff "low" in lottery "B"