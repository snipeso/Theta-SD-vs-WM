% example data used in paper

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;


Coordinates = {
    'P10_LAT_BaselineComp', 536, 118;
     'P10_LAT_Session2Comp', 244, 118;
      'P10_Game_Baseline', 565, 6;
       'P10_Game_Session2', 580, 6;
};