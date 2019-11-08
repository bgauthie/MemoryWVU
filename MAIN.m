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
numrep = 071120192318;

%% Stimuli
ENCODING_RUN_GetChar(ID, numrep)

encoding_file = 'ENCODING_Bgauthie_71120192318';
RETRIEVAL_RUN_GetChar(encoding_file)