# Paper 1
This repository contains the complete analysis used for paper XXX.
 

## Setup
1. Download EEGLAB
    - in the "pop_loadset" function, disable line 117:  fprintf('pop_loadset(): loading file %s ...\n', filename); so that you can't see which file is being loaded during the randomized file cleaning
2. Make sure to have the required MATLAB toolboxes: 
    - Text Analytics Toolbox
    - Statistics And Analytics Toolbox

### Preprocessing
1. Chech Prep_Paramaters, and make sure the folders point to the data
2. Run the scripts in alphabetical order. Scripts C and E require manual work for every file.

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