% For this script is necessary use Matlab 2023
clear; close all; clc;
tic 
images = load('C:\Users\DANIEL WIN\Documents\UASLP\Investigation\2026\Project_fNIRS_BIM\Data\data_images_paper2.mat');
breath = load('C:\Users\DANIEL WIN\Documents\UASLP\Investigation\2026\Project_fNIRS_BIM\Data\data_breath_paper2.mat');
% Kind of stimuli -> K,N,P 

% A function must be created to identify the number of
% stimuli; in addition, the time interval that we are going to
% analyze for max, mean, trapz must be extracted

% Here at this point, we establish that the data are completely
% clean; the columns are the same for each of their groups

% For this configuration, it is first necessary to load the configuration
% of the channels, so it is necessary to load a file
% .mat that contains the number of channels and the "name" value of source and
% detector

v_analysis_image = [-1, 0; % Baseline IM
                     2, 4]; % Analyze
             
v_analysis_breath = [-2, 0; % Baseline B
                      4, 10]; % Analyze



% This function organize all th data in tables where we could work better
% to the next analysis.

strc_image = func_organize(images, v_analysis_image);
strc_breath = func_organize(breath, v_analysis_breath);

toc

% Ask to save the data in a whatever folder you want
syn = input('Do you want to save the data? = ');
if syn == 1
    ruta = uigetdir; %Path of the folder where the file will be saved
    namef = 'data_org_3c_paper2';
    save(fullfile(ruta, namef), 'strc_image', 'strc_breath');
    % save(fullfile(ruta, namef), 'strc_breath');
end
% data_org_1a_paper2 -> interval from -1 to 8 for images -> 1 to 4
% data_org_1b_paper2 -> interval from -1 to 8 for images -> 1.5 to 4.5
% data_org_1c_paper2 -> interval from -1 to 8 for images -> 2 to 4

% data_org_2a_paper2 -> interval from -1 to 7 for images -> 1 to 4
% data_org_2b_paper2 -> interval from -1 to 7 for images -> 1.5 to 4.5
% data_org_2c_paper2 -> interval from -1 to 7 for images -> 2 to 4

% data_org_3a_paper2 -> interval from -1 to 6 for images -> 1 to 4
% data_org_3b_paper2 -> interval from -1 to 6 for images -> 1.5 to 4.5
% data_org_3c_paper2 -> interval from -1 to 6 for images -> 2 to 4