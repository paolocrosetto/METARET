**Certainty equivalent staircase (CE_staircase)**

Like the certainty equivalent price list (CEPL), this task pins down the *certainty equivalent* of a lottery by pitching it against sure amounts. The difference is that the choices are adaptive: the subject faces a short sequence of binary choices, and each sure amount depends on the previous answer. If the lottery was preferred, the next sure amount is higher; if the sure amount was preferred, it is lower, and the step is halved each time (bisection). After four or five choices the certainty equivalent lies in a narrow interval.

The best-known implementation is the staircase of [Falk et al. (2016, 2018, 2023)](https://doi.org/10.1287/mnsc.2022.4455), used in the Global Preference Survey. Here a 50/50 lottery between a positive prize and nothing is used, and the CRRA coefficient is computed from the interval of the certainty equivalent.
