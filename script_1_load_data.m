% For this script is necessary use Matlab 2017 with HOMER3 version 1.54.0

close all; clear; clc;
grupos = ["C:\Users\DANIEL WIN\Documents\UASLP\FNIRS\Depression_Datos_Listos\PreImageIntervention\derivatives\homer";...
          "C:\Users\DANIEL WIN\Documents\UASLP\FNIRS\Depression_Datos_Listos\PostImageIntervention\derivatives\homer"];

% grupos = ["C:\Users\DANIEL WIN\Documents\UASLP\FNIRS\Depression_Datos_Listos\PreBreathIntervention\derivatives\homer";...
%           "C:\Users\DANIEL WIN\Documents\UASLP\FNIRS\Depression_Datos_Listos\PostBreathIntervention\derivatives\homer"];

% grupos = ["D:\Pre_RestingState\derivatives\homer";
%           "D:\Post_RestingState\derivatives\homer"];

tic      
dirFile_Subjects = func_extractFiles(grupos); % Extraction of fold path per subject
timeSn = [-1, 6];
datas = func_load(dirFile_Subjects, timeSn); % Charge data and clean them
toc

% Ask to save the data in a whatever folder you want
syn = input('Do you want to save the data? = ');
if syn == 1
    ruta = uigetdir; %Path of the folder where the file will be saved
    namef = 'data_images_3_paper2';
    save(fullfile(ruta, namef), 'datas');
end

% data_images_1_paper2 -> interval from -1 to 8 for images
% data_images_2_paper2 -> interval from -1 to 7 for images
% data_images_3_paper2 -> interval from -1 to 6 for images

