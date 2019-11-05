% main script calling the different stimuli with proper inputs
clear all
close all

% calls the functions that set the path
Conf

% set stimulation path as current directory
cd(conf.dir_stim)

%% parameters
% participant's ID
ID     = 'Bgauthie';

% acquisition index
numrep = 041120191511;

%% Stimuli

ENCODING_RUN(ID, numrep)

encoding_file = 'ENCODING_Bgauthie_41120191511.mat';
RETRIEVAL_RUN(encoding_file)
