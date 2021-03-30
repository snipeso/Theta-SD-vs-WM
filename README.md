# LSM-analysis
This repository contains the complete analysis used for the LSM experiment. 
 
## Content
### eeg
Contains preprocessing scripts, then scripts for analyzing EEG data in different ways. 

### functions
Contains subfolders with different sets of functions used by other scripts. Some are more general use than others. 

### questionnaires
Contains scripts for analyzing all the questionnaire data.

### statistics
Contains scripts for doing statistics on the data. 

### tasks
Contains scripts for running analyses on the tasks.


## Setup
Scripts in "eeg", "questionnaires" and "tasks" can be run independently. Scripts in "statistics" are usually done on an aggregate from any or all of the three.

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
 sigstar: 

Rob Campbell (2020). raacampbell/sigstar (https://www.github.com/raacampbell/sigstar), GitHub. Retrieved April 27, 2020.