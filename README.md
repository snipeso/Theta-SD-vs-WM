# Paper 1
This repository contains the complete analysis used for paper XXX.
 
## Content
### Preprocessing


## Setup
1. Download EEGLAB
    - in the "pop_loadset" function, disable line 117:  fprintf('pop_loadset(): loading file %s ...\n', filename); so that you can't see which file is being loaded during the randomized file cleaning

### External scripts

- For EEG: EEGLAB: https://sccn.ucsd.edu/eeglab/downloadtoolbox.php. I used version 2019_1
- For Questionnaires: EWOQ analysis: https://github.com/snipeso/EWOQ_Analysis 

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