# Theta during tasks and sleep deprivation
This repository contains all the scripts used for {paper XXX}. This was an investigation in the local changes in EEG theta power caused by sleep deprivation during different tasks. The data is available upon request.

DISCLAIMER: I am a psychologist by training, and did the best I could with writing scripts but they are not high quality. I prioritized making them work intuitively (for me) over formal formatting correctness. Also, I am a PhD student 1 year from graduation, and don't really have time to make perfect documentation. If there's something not clear that you really want to know, just write to me. This is NOT a toolbox, and is only being published for the sake of transparency.

**Preprocessing** contains the scripts used for preprocessing the data, and of course must be run first. These clean the raw EEG data as described in the paper. This works with the EEGLAB toolbox, and at each step saves the EEG data as a .set file. The scripts are run in alphabetical order ('A_EEG2SET.mat', 'B_Filtering_Downsampling.m', ...).

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
Scripts to clean the EEG data.

1. Check **Prep_Paramaters.m**, and change the filepaths to point to the data and destination folders. This script is where all the parameters for the preprocessing are specified for easy visualization and consistency across scripts.
2. Run the scripts in alphabetical order. Scripts C and E require manual work for every file.
    1. **A_EEG2SET.m** converts the BrainVision raw files (saved as '.eeg') into EEGLAB '.set' files in the same folder as the raw data. *A1_SplitRRT.m* is not relevant to this first paper, and can be for now ignored. *A2_SpecialFixes.m* was for me to fix files that had missing triggers or merged multiple recordings together. In the final dataset, all the '.set' files are correct.
    2. **B_Filtering_Downsampling.m** takes the .set files, filters and downsamples them, and saves the new files in a *Preprocessing* folder. Seperate filtering is done for *Cuts*, *Power*, and *ICA*; the first is for visualizing quickly the data to determine manually where there is data to be removed, the second is the filtering used for the final data analysis, and the last is for calculating the independent components used for the final stage of preprocessing.
    3. **C_Cuts.m** is a script for identifying for each file what data to cut. It generates a file in *Preprocessing>Cutting>Cuts* which contains the channels, the snippets (bad segments in single channels), and time windows to remove. This must be run over and over again until all the files are clean. It is done blinded.
    4. **D_GetICA.m** takes the ICA filtered data, removes all the bad data marked in C, and calculates the components for each file. This takes a long time.
    5. **E_RemoveComponents.m** is another manual process that requires running over and over again until all files have been visualized. It shows the components that were automatically marked for removal, allows the user to select further components to remove over and over until the user is happy. Additional channels can further be removed at the end. This outputs a final '.set' file into *Preprocessing>Clean* which is used for data analysis.
    6. **F_eeglab3fieldtrip.m** converts data to fieldtrip datastructure for source localization.

All other scripts are experimental and peripheral things that were not part of the preprocessing pipeline.


### Analysis
Scripts used to create the results in the paper (and more). Some scripts will plot a lot of extra figures; the ones used in the paper are at the beginning. Each script is similarly structured: first the parameters are loaded in, then script-specific parameters are specified, then the data is loaded, and then the individual plots can be run, either in order or not. 

1. Modify **analysisParameters.m**. so that filepaths are correct. Like for preprocessing, this is (now a function) that indicates the parameters in common across scripts. Now the bulk is related to plotting and such.
2. Run **A_Unlocked_Power.m** and the **A1_Locked_Power...** scripts to get the power spectrum data from the clean .set files created by the preprocessing. These are saved in *Final>Unlocked* and *Final>Locked* respectively. "Unlocked" refers to power that is not locked to any particular event, and just takes a certain number of minutes of data, whereas "Locked" takes epochs specific to the underlying task, which is why there's a seperate one for each task.
3. Run the scripts used for the paper. These don't actually have to be run in order
    - **B_Example_Bursts.m** plots the the little example bursts of EEG data
    - **C_Task_Main.m** plots the figure showing averages of theta in the three ROIs (regions of interest) across all tasks. 
    - **D_Task_Topographies.m** plots the topographies of theta in all the tasks, and how they change with sleep deprivation. Other bands can be plotted further down in the script.
    - **E_Task_Spectrums.m** plots the spectrums for each ROI and each task. 
    - **F_M2S_Main.m** plots all the figures related to the match to sample (M2S) short term memory task (STM in the paper).
    - **G_SpFT_Topographies.m** plots the figure showing the changes in theta in the Speech Fluency Task (SpFT).
    - **H_Task_Questionnaires.m** plots the questionnaire data of all the tasks.

Other lettered scripts are from the supplementary material, or not published at all. 



### Data
As of now, the data is in the hands of the Kinderspital Zurich and Sophia Snipes. Eventually this will be made open source.

#### EEG
Raw EEG data is saved as a .eeg file of BrainVision. This gets converted early on as a .set of EEGLAB, and used as such throughout. 
EEG was recorded from a 128 Channel EGI montage at 1000 Hz. 

#### Questionnaires
Questionnaires were recoded on the custom EWOQ platform, and the answers saved as JSON. These need to be first converted to .csv to run the scripts included here.

#### Tasks
Task output is also saved as a JSON, but the scripts here will gladly convert them into a single .mat file.


## credits

#### External scripts and toolboxes

- For EEG: EEGLAB: https://sccn.ucsd.edu/eeglab/downloadtoolbox.php. I used version 2019_1
- For converting Questionnaires into csv: EWOQ analysis: https://github.com/snipeso/EWOQ_Analysis 
    - clone repository
    - run Main_LSM.m (after adjusting for data source location)
    - move .csv files with relevant questionnaire names from .Raw/CSVs to folder ./Final/Questionnaires (create if it doesn't exist)

- sigstar: Rob Campbell (2020). raacampbell/sigstar (https://www.github.com/raacampbell/sigstar), GitHub. Retrieved April 27, 2020.

- colorcet: https://colorcet.holoviz.org/ 

- normalitytest: Ahmed BenSaïda (2021). Shapiro-Wilk and Shapiro-Francia normality tests. (https://www.mathworks.com/matlabcentral/fileexchange/13964-shapiro-wilk-and-shapiro-francia-normality-tests), MATLAB Central File Exchange. Retrieved August 13, 2021.

- effect size measurements: Harald Hentschke (2021). hhentschke/measures-of-effect-size-toolbox (https://github.com/hhentschke/measures-of-effect-size-toolbox), GitHub. Retrieved November 20, 2019.

- rgb2hsl: Vladimir Bychkovsky (2021). hsl2rgb and rgb2hsl conversion (https://www.mathworks.com/matlabcentral/fileexchange/20292-hsl2rgb-and-rgb2hsl-conversion), MATLAB Central File Exchange. Retrieved November 12, 2021.

#### Reference papers and sources

Overall pipeline was based on: Makoto Miyakoshi (2020). Makoto's preprocessing pipeline (https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline), Swartz Center for Computational Neuroscience wiki. Retrieved March 15, 2020.

ICA parameters were chosen based on: Dimigen, O. (2020). Optimizing the ICA-based removal of ocular EEG artifacts from free viewing experiments. NeuroImage, 207, 116117.

Correction for multiple comparisons was based on: Groppe, D. M., Urbach, T. P., & Kutas, M. (2011). Mass univariate analysis of event‐related brain potentials/fields I: A critical tutorial review. Psychophysiology, 48(12), 1711-1725.

EEGLAB: Delorme, A., & Makeig, S. (2004). EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics including independent component analysis. Journal of neuroscience methods, 134(1), 9-21.

Measures of effect size: Hentschke, H., & Stüttgen, M. C. (2011). Computation of measures of effect size for neuroscience data sets. European Journal of Neuroscience, 34(12), 1887-1894.