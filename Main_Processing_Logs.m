% modelling and analysis

cd D:\MRI_analysis\WVU_Memory\scripts

clear all
close all

% example file
[data1, names, onsets, durations] = conditions3('D:\MRI_analysis\WVU_Memory\CONDS\ENCODING_Pilot1');
[data2, names, onsets, durations] = conditions2('D:\MRI_analysis\WVU_Memory\CONDS\RETRIEVAL_Pilot1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% format for R
ENCODING  = [];
ENCODING  = [data1];
ENCODING  = [[ones(length(data1),1)] ENCODING];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process retrieval as a function of Signal detection theory
% pilot1
RETRIEVAL1 = [];
RETRIEVAL1 = [data2];

Resp = []; % SDT coding
for i = 1:length(RETRIEVAL1)
    if RETRIEVAL1(i,3) == 54 && RETRIEVAL1(i,4) == 1 % hit = 3
        Resp(i) = 3;
    elseif RETRIEVAL1(i,3) == 54 && RETRIEVAL1(i,4) == 2 % fa = 1
        Resp(i) = 1;
    elseif RETRIEVAL1(i,3) == 49 && RETRIEVAL1(i,4) == 1 % miss = 4
        Resp(i) = 4;        
    elseif RETRIEVAL1(i,3) == 49 && RETRIEVAL1(i,4) == 2 % cr = 2
        Resp(i) = 2;  
    end
end

RawResp = []; % answered presence of stim (= old)
for i = 1:length(RETRIEVAL1)
    if RETRIEVAL1(i,3) == 54 % answered present = old
        RawResp(i) = 1;      
    elseif RETRIEVAL1(i,3) == 49 % answered absent = new
        RawResp(i) = 0;  
    end
end

RawStim = []; % presence of stim (= old)
for i = 1:length(RETRIEVAL1)
    if RETRIEVAL1(i,4) == 1 % presence = old
        RawStim(i) = 1;      
    elseif RETRIEVAL1(i,4) == 2 % absence = new
        RawStim(i) = 0;  
    end
end

RETRIEVAL1 = [[ones(length(data2),1)] RETRIEVAL1 Resp' RawResp' RawStim'];

%%%%%%%%%%%%%%%%%%%%%%% SHAPING FOR R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
names   = {'Subj'; 'RT'; 'Onset'; 'Button';'Cond'};
filename = 'D:\MRI_analysis\WVU_Memory\ForR\Rdata_VWU_ENCODING';
write_csv_for_R(ENCODING, names, filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
names   = {'Subj'; 'RT'; 'Onset'; 'Button';'Cond';'Resp';'RawResp';'RawStim'};
filename = 'D:\MRI_analysis\WVU_Memory\ForR\Rdata_VWU_RETRIEVAL';
write_csv_for_R(RETRIEVAL, names, filename)











