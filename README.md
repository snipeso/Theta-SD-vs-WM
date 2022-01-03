# Theta during tasks and sleep deprivation
This repository contains all the scripts used for {paper XXX}. This was an investigation in the local changes in EEG theta power caused by sleep deprivation during different tasks. The data is available upon request. 

**Preprocessing** contains the scripts used for preprocessing the data, and of course must be run first. These clean the raw EEG data (saved as BrainVision .eeg files) as described in the paper. This works with the EEGLAB toolbox, and at each step saves the EEG data as a .set file. The scripts are run in alphabetical order ('A_EEG2SET.mat', 'B_Filtering_Downsampling.m', ...).

**Analysis** contains the scripts used for analyzing the data. A lot more analyses were conducted than were included in the final publication. The ones that were publised are marked with letters at the beginning of the filename in the order in which they appear in the publication.

**Quality_Checks** contains unedited scripts that I used to make sure the data was ok. It tabulated the amount of data removed, and things like that. 

**SpfT_Scoring** contains the quick scripts I used to blind myself for the scoring of the Speech Fluency Task data.

**functions** contains all the functions used in the script folders. Functions in the *external* folder are, as you could imagine, from other toolboxes and little bits of code from other people. All other code was written by me (Sophia Snipes).


## Setup
1. Download EEGLAB
    - in the "pop_loadset" function, disable line 117:  fprintf('pop_loadset(): loading file %s ...\n', filename); so that you can't see which file is being loaded during the randomized file cleaning
2. Make sure to have the required MATLAB toolboxes: 
    - Text Analytics Toolbox
    - Statistics And Analytics Toolbox

### Preprocessing
1. Chech Prep_Paramaters, and change the filepaths to point to the data and destination folders. This script is where all the parameters for the preprocessing are specified for easy visualization and consistency across scripts.
2. Run the scripts in alphabetical order. Scripts C and E require manual work for every file.
    1. **A_EEG2SET.m** converts the BrainVision raw files (saved as '.eeg') into EEGLAB '.set' files in the same folder as the raw data. *A1_SplitRRT.m* is not relevant to this first paper, and can be for now ignored. *A2_SpecialFixes.m* was for me to fix files that had missing triggers or merged multiple recordings together. In the final dataset, all the '.set' files are correct.
    2. **B_Filtering_Downsampling.m** takes the .set files, filters and downsamples them, and saves the new files in a *Preprocessing* folder. Seperate filtering is done for *Cuts*, *Power*, and *ICA*; the first is for visualizing quickly the data to determine manually where there is data to be removed, the second is the filtering used for the final data analysis, and the last is for calculating the independent components used for the final stage of preprocessing.
    3. **C_Cuts.m** is a script for identifying for each file what data to cut. It generates a file in *Preprocessing>Cutting>Cuts* which contains the channels, the snippets (bad segments in single channels), and time windows to remove. This must be run over and over again until all the files are clean. It is done blinded.
    4. **D_GetICA.m** takes the ICA filtered data, removes all the bad data marked in C, and calculates the components for each file. This takes a long time.
    5. **E_RemoveComponents.m** is another manual process that involves running over and over again until all files have been visualized. It shows the components that were automatically marked for removal, allows the user to select further components to remove over and over until the user is happy. Additional channels can further be removed at the end.
    6. **F_eeglab3fieldtrip.m** converts data to fieldtrip datastructure for source localization.


### Analysis
1. Modify analysisParameters. so that paths and so on are correct
2. Run "Unlocked_Power.m" and the "Locked_Power..." scripts to get the power spectrum data
3. For example data, run "ExampleBursts.m"
4. For power spectrums, run "Task_Spectrums.m"


## External scripts

- For EEG: EEGLAB: https://sccn.ucsd.edu/eeglab/downloadtoolbox.php. I used version 2019_1
- For Questionnaires: EWOQ analysis: https://github.com/snipeso/EWOQ_Analysis 
    - clone repository
    - run Main_LSM.m (after adjusting for data source location)
    - move .csv files with relevant questionnaire names from .Raw/CSVs to folder ./Final/Questionnaires (create if it doesn't exist)

### Data
As of now, the data is in the hands of the Kinderspital Zurich and Sophia Snipes. Eventually this will be made open source.

#### EEG
Raw EEG data is saved as a .eeg file of BrainVision. This gets converted early on as a .set of EEGLAB, and used as such throughout. 
EEG is recorded from a 128 Channel EGI montage at 1000 Hz. 

#### Questionnaires
Questionnaires were recoded on the custom EWOQ platform, and the answers saved as JSON. These need to be first converted to .csv to run the scripts included here.

#### Tasks
Task output is also saved as a JSON, but the scripts here will gladly convert them into a single .mat file.


## credits

#### Reference papers

#### External functions
 sigstar: Rob Campbell (2020). raacampbell/sigstar (https://www.github.com/raacampbell/sigstar), GitHub. Retrieved April 27, 2020.

 colorcet: https://colorcet.holoviz.org/ 

 normalitytest: Ahmed BenSaïda (2021). Shapiro-Wilk and Shapiro-Francia normality tests. (https://www.mathworks.com/matlabcentral/fileexchange/13964-shapiro-wilk-and-shapiro-francia-normality-tests), MATLAB Central File Exchange. Retrieved August 13, 2021.

 effect size measurements: Harald Hentschke (2021). hhentschke/measures-of-effect-size-toolbox (https://github.com/hhentschke/measures-of-effect-size-toolbox), GitHub. Retrieved November 20, 2019.

 rgb2hsl: Vladimir Bychkovsky (2021). hsl2rgb and rgb2hsl conversion (https://www.mathworks.com/matlabcentral/fileexchange/20292-hsl2rgb-and-rgb2hsl-conversion), MATLAB Central File Exchange. Retrieved November 12, 2021.