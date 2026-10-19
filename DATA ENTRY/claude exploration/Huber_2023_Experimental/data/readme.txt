Replication package for

Tobias Huber (ORCID 0000-0002-9894-9710), Johannes Jaspersen (ORCID 0000-0002-3599-8988), Andreas Richter (ORCID 0000-0002-2588-4813), Dennis Strümpel (ORCID: 0000-0002-6747-6674)
On the Change of Risk Aversion in Wealth: A Field Experiment in a Closed Economic System
Experimental Economics

Package contains
Experimental Files:
- Crashy Cakes 1.04 Signed.apk
- Experiment_Consent_Text.pdf
- PrivacyPolicy_ShoulderByte.pdf
- Screenshot_ConsentPage_Consent.jpeg
- Screenshot_ConsentPage_Empty.jpeg
- Screenshot_ConsentPage_NoConsent.jpeg
- Screenshot_TOS_Screen.jpeg
- Screenshot_ConsentPage_Consent_DE.jpeg
- Screenshot_ConsentPage_Empty_DE.jpeg
- Screenshot_ConsentPage_NoConsent_DE.jpeg
- Screenshot_TOS_Screen_DE.jpeg
- Screenshot_Comparable_to_Fig1(b)_DE.jpeg
- Screenshot_Comparable_to_Fig1(c)_DE.jpeg
Data Files:
- data_anon.csv
- data_DownloadCount.csv
- data_GameRunCount.csv
- data_LotteriesCount.csv
Scripts:
- Figures_2_and_3.R
- Descriptive_Figures_Tables.R
- Inductive_Tables_exA3.R
- anonymize.R
- Table_A3.m
- abs_dec_v2.m
- abs_dec_v4.m

To execute the main experimental file Crashy Cakes 1.04 Signed.apk:
- The game supports Android versions from 4.4 to 10.0. Other Android versions are not supported. Therefore, make sure that you utilize the correct Android version.
- Starting the game on Android:
	1. Download the .apk file from this archive to your Android device.
	2. Open the file browser of your Android device and navigate to the local download path of the .apk file.
	3. Select the .apk file. Now an installation route should open and guide you through the process of installation.
	4. You can now start the game by tapping on its icon.
- Using an emulator (e.g. BlueStacks 5 or 10 on Windows):
	1. Download an Android emulator that supports Android version 10.0. (e.g. BlueStacks [available at: https://www.bluestacks.com/] or Android Studio [available at: https://developer.android.com/studio])
	2. Install the downloaded Android emulator by following it's installation routine.
	3. Download the .apk file from this archive to your Windows computer.
	4. Open the emulator of your choice and follow it's routine to install the .apk. (Many emulators are set as the default program to run .apk files after they are installed. In this case, you can directly click on the .apk file and follow the routine to install the game.)
	5. You should now be able to launch the game from the emulator.
- Notes on emulator performance: Some emulators (e.g. BlueStacks 5) may only allow 1 CPU core to run the game. This is too little to play the game correctly. In this case, you should follow the instructions of the respective emulator to unlock more CPU cores or launch the game via a cloud service (e.g. BlueStacks 10).

Due to GDPR concerns of the publisher, the replication package only uses anonymized data in which the demographic characteristics were randomized according to their distribution in the original data. No correlations were taken into account. The output generated from the scripts in the package will thus not match the output in the paper perfectly. Exceptions are descriptive tables and figures which do not consider demographics (bottom panel Table 2, Figures 2-7) and panel estimations without interactions between wealth and demographic characteristics (columns (1) and (3) in Tables 4, 6 and 7 and the middle panel of Table 5).
The data was anonymized using the script "anonymize.R" contained in the replication package. 

The data_anon.csv file contains 28 variables:
- userid: unique ID for every player
- date: day the lottery decision was made
- cAge: age of player (categorical) <-- anonymized
- sex: player gender (categorical) <-- anonymized
- germany: 1 if player is from Germany <-- anonymized 
- cSpending: cumulative amount of money spent in the shop before lottery decision
- cAd: cumulative number of ads watched before the lottery decision
- highscore: highest point score achieved so far
- lastScore: Score of run before the lottery
- goldBefore: wealth at the time of the lottery
- goldAfter: wealth after the lottery
- lotName: lottery faced by the player
- lotType: Treatment group of the player
- pickedRisky: 1 if player picked the risky option in the lottery
- riskyHighOutput: high payoff of risky lottery
- riskyLowOutput: low payoff of risky lottery
- riskyLeft: 1 if risky option is displayed on the left
- riskySuccess: 1 if risky lottery was chosen and successful, 0 is chosen and not successful, NA if risky lottery was not chosen
- safeOutput: payoff of safe lottery
- threshold: 1 if the current wealth plus the high outcome of the risky decision allowed the purchase of the next more expensive item in the shop, while the current wealth plus the safe outcome of the lottery did not
- cNormalUnlock: cumulative number of purchased normal skins in the shop before lottery decision
- cPremiumUnlock: cumulative number of purchased premium skins in the shop before lottery decision
- decisionTime: time taken for the decision (in seconds)
- runCounter: cumulative number of game runs before lottery decision
- runTotal: total number of runs played by the player
- lotCounter: cumulative number of lottery decisions including the current one
- lotTotal: total number of lottery decision observed from the player
- eventCount: cumulative number of observed lottery decisions including the current one

The data_DownloadCount.csv file contains 4 variables:
- First column: day after game was published (starting at 1 at day of publication)
- date: calendar date
- downloads: number of downloads on this day
- day: as first column

The data_GameRunCount.csv file contains 4 variables:
- date: calendar date
- day: day after game was published (starting at 1 at day of publication)
- sample: sample of players (categorical)
- NumRuns: number of runs played on this day

The data_LotteriesCount.csv file contains 4 variables:
- First column: day after game was published (starting at 1 at day of publication)
- date: calendar date
- lotteries: number of lotteries observed on this day
- day: as first column

Numbers in Table 1 came directly from the publisher and cannot be replicated for GDPR reasons.

To run Figures_2_and_3.R:
- Run R in version 4.2.0
- Adjust the dataDir path to the path which contains data_DownloadCount.csv, data_GameRunCount.csv and data_LotteriesCount.csv
- Adjust the saveDir path to a directory in which you want to save all output
Run the code. It produces the following output in the saveDir directory:
- Figure2.png 
- Figure3(a).png 
- Figure3(b).png

To run Descriptive_Figures_Tables.R:
- Run R in version 4.2.0
- Adjust the dataDir path to the path which contains data_anon.csv
- Adjust the saveDir path to a directory in which you want to save all output
Run the code. It produces the following output in the saveDir directory:
- Figure4(a).png 
- Figure4(b).png 
- Figure5.png
- Figure6(a).png
- Figure6(b).png
- Figure7(a).png
- Figure7(b).png
- FigureA1(a).png - FigureA1(i).png
- FigureA2(a).png - FigureA2(i).png
- FigureB3(a).png - FigureB3(d).png
- FigureB4(a).png - FigureB4(f).png
- FigureB5(a).png - FigureB5(f).png
- Table2_top_panel.txt
- Table2_bottom_panel.txt
- TableA4_top_panel.txt
- TableA4_bottom_panel.txt
The txt files contain all relevant content of the corresponding tables in the main text or the appendix.

To run Inductive_Tables_exA3.R:
- Run R in version 4.2.0
- Adjust the dataDir path to the path which contains data_anon.csv
- Adjust the saveDir path to a directory in which you want to save all output
Run the code. It produces the following output in the saveDir directory:
- Table3.txt
- Table4.txt
- Table5_bottom_panel.txt
- Table5_middle_panel.txt
- Table5_top_panel.txt
- Table6.txt
- Table7.txt
- TableA1.txt
- TableA2.txt
- TableA5.txt
- TableC1.txt
- TableC2.txt
- TableC3.txt
- TableC4.txt
- TableC5.txt
These files contain all relevant content of the corresponding tables in the main text or the appendix.
- The code also produces a variety of variables starting with "in". These are the individual numbers reported in the text and they are described in comments right after their definition. They are calculated in order of appearance in the paper. 

To run Table_A3.m
- run Matlab R2019b
- have abs_dec_v2.m and abs_dec_v4.m in the current folder or the path
Run the code. It produces the following output in the current folder:
- TableA3.xlsx
The file contains all relevant content of the corresponding table in the appendix.
