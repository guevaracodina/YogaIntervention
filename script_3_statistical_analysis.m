% For this script is necessary use Matlab 2023
clear; close all; clc;
tic
% load('C:\Users\DANIEL WIN\Documents\UASLP\Investigation\2026\Project_fNIRS_BIM\Data\data_org_1a_paper2');
load('C:\Users\DANIEL WIN\Documents\UASLP\Investigation\2026\Project_fNIRS_BIM\Data\data_org\data_org_1b_paper2');

strc = strc_breath;

%% T-test for breath data

kAn = 2; % this is the period that will be analyzed

[T, TO, TR, TT] = func_ttest_breath(strc, kAn);

%% ANOVA 
% load('C:\Users\DANIEL WIN\Documents\UASLP\Investigation\2026\Project_fNIRS_BIM\Data\data_org_paper2')

% Here is the procedure example; the data must be cleaned of NaN,
% so it will be decided whether the NaN values are removed in the channel or
% the channel median is provided to them

[DetallesStim, DetallesAct, DetallesPrePost, DetallesInt] = func_ANOVA_img(strc_image);
% %% ============================================================
% % MIXED ANOVA COMPLETE + POSTHOC + EFFECTS + FDR
% % ============================================================

toc
