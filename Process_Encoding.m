function [test, names, onsets, durations] = Process_Encoding(Encoding_file)

data = load(Encoding_file);
MRI_onset = data.mri_onset;

imgcode = [];
for i = 1:length(data.conds)
    if data.conds(i) == 1 % block novel
        timeref(i) = data.BLOCKNOVEL{1,data.rep(i)}.TimePush;
        imgcode = [imgcode ones(1,24)];
    elseif data.conds(i) == 2 % block repeat
        timeref(i) = data.BLOCKREPEAT{1,data.rep(i)}.TimePush;
        imgcode = [imgcode ones(1,24).*2];
    elseif data.conds(i) == 3 % block baseline
        timeref(i) = data.BLOCKBASE{1,data.rep(i)}.TimePush;
        imgcode = [imgcode ones(1,24).*3];
    end
end

% get order
order = sortrows([timeref; data.conds; data.rep]');

% offset of blocks (FIXME)
lasttimepush = timeref - ones(1,6).*MRI_onset ;

% process miniblock
count_novel   = 1;
count_repeat  = 1;
count_base    = 1;
count         = 1;
ONSETS_novel  = [];
ONSETS_repeat = [];
ONSETS_base   = [];
RT_novel      = [];
RT_repeat     = [];
RT_base       = [];

CatONSETS = [];
CatRT     = [];
CatRESP   = [];

ONSETS = [];
RT     = [];

for i = 1:length(order)
    % compute timing (missing info FIXME)
    if order(i,2) == 1 % block novel
        if count_novel == 1; % first pack of trials
            
            tmpRT = [];
            onset = [];
            resp  = [];
            trial_index = []; trial_index = data.BLOCKNOVEL{1,data.rep(i)}.trial_indexes;
            
            for j = 1:length(trial_index)
                if j > 1
                    tmpRT(j) = [data.BLOCKNOVEL{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [onset(j-1) + data.BLOCKNOVEL{1,data.rep(i)}.RT{trial_index(j-1)} + 5 + 1+ 0.045];
                    resp(j)  = [data.BLOCKNOVEL{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                else
                    tmpRT(j) = [data.BLOCKNOVEL{1,data.rep(i)}.RT{trial_index(j)}];
                    if i == 1
                        onset(j) = [0];
                    else
                        onset(j) = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 5+ 0.045];
                    end
                    resp(j)  = [data.BLOCKNOVEL{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                end
            end
            
            ONSETS_novel{count_novel} = onset;
            RT_novel{count_novel}     = tmpRT;
            RESP_novel{count_novel}   = resp;
            
            ONSETS{count} = onset;
            RT{count}     = tmpRT;
            
            CatONSETS = [CatONSETS ONSETS_novel{count_novel}];
            CatRT     = [CatRT RT_novel{count_novel}];
            CatRESP   = [CatRESP RESP_novel{count_novel}];
            
            count_novel = count_novel +1;
            count       = count + 1;
            
        else % next packs of trials
            
            tmpRT = [];
            onset = [];
            trial_index = []; trial_index = data.BLOCKNOVEL{1,data.rep(i)}.trial_indexes;
            
            for j = 1:length(trial_index)
                if j > 1
                    tmpRT(j) = [data.BLOCKNOVEL{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [onset(j-1) + data.BLOCKNOVEL{1,data.rep(i)}.RT{trial_index(j-1)} + 5 + 1+ 0.045];
                    resp(j)  = [data.BLOCKNOVEL{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                else
                    tmpRT(j) = [data.BLOCKNOVEL{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 5+ 0.045];
                    resp(j)  = [data.BLOCKNOVEL{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                end
            end
            
            ONSETS_novel{count_novel} = onset;
            RT_novel{count_novel}     = tmpRT;
            RESP_novel{count_novel}   = resp;
            
            ONSETS{count} = onset;
            RT{count}     = tmpRT;
            
            CatONSETS = [CatONSETS ONSETS_novel{count_novel}];
            CatRT     = [CatRT RT_novel{count_novel}];
            CatRESP   = [CatRESP RESP_novel{count_novel}];
            
            count_novel = count_novel + 1;
            count       = count + 1;
            
        end
    elseif order(i,2) == 2 % block repeat
        if count_repeat == 1; % first pack of trials
            
            tmpRT = [];
            onset = [];
            resp  = [];
            trial_index = []; trial_index = data.BLOCKREPEAT{1,data.rep(i)}.trial_indexes;
            
            for j = 1:length(trial_index)
                if j > 1
                    tmpRT(j) = [data.BLOCKREPEAT{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [onset(j-1) + data.BLOCKREPEAT{1,data.rep(i)}.RT{trial_index(j-1)} + 5 + 1+ 0.045];
                    resp(j)  = [data.BLOCKREPEAT{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                else
                    tmpRT(j) = [data.BLOCKREPEAT{1,data.rep(i)}.RT{trial_index(j)}];
                    if i == 1
                        onset(j) = [0];
                    else
                        onset(j) = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 5+ 0.045];
                    end
                    resp(j)  = [data.BLOCKREPEAT{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                end
            end
            
            ONSETS_repeat{count_repeat} = onset;
            RT_repeat{count_repeat}     = tmpRT;
            RESP_repeat{count_repeat}   = resp;
            
            ONSETS{count} = onset;
            RT{count}     = tmpRT;
            
            CatONSETS = [CatONSETS ONSETS_repeat{count_repeat}];
            CatRT     = [CatRT RT_repeat{count_repeat}];
            CatRESP   = [CatRESP RESP_repeat{count_repeat}];
            
            count_repeat = count_repeat +1;
            count       = count + 1;
            
        else % next packs of trials
            
            tmpRT = [];
            onset = [];
            trial_index = []; trial_index = data.BLOCKREPEAT{1,data.rep(i)}.trial_indexes;
            
            for j = 1:length(trial_index)
                if j > 1
                    tmpRT(j) = [data.BLOCKREPEAT{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [onset(j-1) + data.BLOCKREPEAT{1,data.rep(i)}.RT{trial_index(j-1)} + 5 + 1+ 0.045];
                    resp(j)  = [data.BLOCKREPEAT{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                else
                    tmpRT(j) = [data.BLOCKREPEAT{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 5+ 0.045];
                    resp(j)  = [data.BLOCKREPEAT{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                end
            end
            
            ONSETS_repeat{count_repeat} = onset;
            RT_repeat{count_repeat}     = tmpRT;
            RESP_repeat{count_repeat}   = resp;
            
            ONSETS{count} = onset;
            RT{count}     = tmpRT;
            
            CatONSETS = [CatONSETS ONSETS_repeat{count_repeat}];
            CatRT     = [CatRT RT_repeat{count_repeat}];
            CatRESP   = [CatRESP RESP_repeat{count_repeat}];
            
            count_repeat = count_repeat + 1;
            count       = count + 1;
            
        end
        
    elseif order(i,2) == 3 % block baseline
        if count_base == 1; % first pack of trials
            
            tmpRT = [];
            onset = [];
            resp  = [];
            trial_index = []; trial_index = data.BLOCKBASE{1,data.rep(i)}.trial_indexes;
            
            for j = 1:length(trial_index)
                if j > 1
                    tmpRT(j) = [data.BLOCKBASE{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [onset(j-1) + data.BLOCKBASE{1,data.rep(i)}.RT{trial_index(j-1)} + 5 + 1+ 0.045];
                    resp(j)  = [data.BLOCKBASE{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                else
                    tmpRT(j) = [data.BLOCKBASE{1,data.rep(i)}.RT{trial_index(j)}];
                    if i == 1
                        onset(j) = [0];
                    else
                        onset(j) = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 5+ 0.045];
                    end
                    resp(j)  = [data.BLOCKBASE{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                end
            end
            
            ONSETS_base{count_base} = onset;
            RT_base{count_base}     = tmpRT;
            RESP_base{count_base}   = resp;
            
            ONSETS{count} = onset;
            RT{count}     = tmpRT;
            
            CatONSETS = [CatONSETS ONSETS_base{count_base}];
            CatRT     = [CatRT RT_base{count_base}];
            CatRESP   = [CatRESP RESP_base{count_base}];
            
            count_base = count_base +1;
            count       = count + 1;
            
        else % next packs of trials
            
            tmpRT = [];
            onset = [];
            trial_index = []; trial_index = data.BLOCKBASE{1,data.rep(i)}.trial_indexes;
            
            for j = 1:length(trial_index)
                if j > 1
                    tmpRT(j) = [data.BLOCKBASE{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [onset(j-1) + data.BLOCKBASE{1,data.rep(i)}.RT{trial_index(j-1)} + 5 + 1 + 0.045];
                    resp(j)  = [data.BLOCKBASE{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                else
                    tmpRT(j) = [data.BLOCKBASE{1,data.rep(i)}.RT{trial_index(j)}];
                    onset(j) = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 5+ 0.045];
                    resp(j)  = [data.BLOCKBASE{1,data.rep(i)}.keycode_Resp{trial_index(j)}];
                end
            end
            
            ONSETS_base{count_base} = onset;
            RT_base{count_base}     = tmpRT;
            RESP_base{count_base}   = resp;
            
            ONSETS{count} = onset;
            RT{count}     = tmpRT;
            
            CatONSETS = [CatONSETS ONSETS_base{count_base}];
            CatRT     = [CatRT RT_base{count_base}];
            CatRESP   = [CatRESP RESP_base{count_base}];
            
            count_base = count_base + 1;
            count       = count + 1;
            
        end
    end
end

% CatONSETS = [ONSETS{1,1} ONSETS{1,2} ONSETS{1,3} ONSETS{1,4}];
% CatRT     = [RT{1,1} RT{1,2} RT{1,3} RT{1,4}];
% CatRESP   = [RESP{1,1} RESP{1,2} RESP{1,3} RESP{1,4}];
% test      = [CatRT; CatONSETS];

% offset of blocks (FIXME)

lastonset = [];
for i = 1:length(lasttimepush) % remove last RT to check per block last onset match
    lastonset(i) = lasttimepush(i)- RT{i}(end)-1;
end

lastonset - [ONSETS{1,1}(end) ONSETS{1,2}(end) ONSETS{1,3}(end) ONSETS{1,4}(end) ONSETS{1,5}(end) ONSETS{1,6}(end)];

test = [CatRT; CatONSETS; CatRESP; imgcode]';

% build regressors list
novel_onsets    = [];
repeat_onsets   = [];
base_onsets     = [];
novel_duration  = [];
repeat_duration = [];
base_duration   = [];

count_novel  = 1;
count_repeat = 1;
count_base   = 1;

for i = 1:length(test)
    if test(i,4) == 1
        novel_onsets(count_novel)   = test(i,2);
        novel_duration(count_novel) = test(i,1)+1;
        count_novel                 = count_novel + 1;
    elseif test(i,4) == 2
        repeat_onsets(count_repeat)   = test(i,2);
        repeat_duration(count_repeat) = test(i,1)+1;
        count_repeat                  = count_repeat + 1;
    elseif test(i,4) == 3
        base_onsets(count_base)   = test(i,2);
        base_duration(count_base) = test(i,1)+1;
        count_base                = count_base + 1;
    end
end

names        = {'novel','repeat','base'};
onsets{1}    =  novel_onsets;
onsets{2}    =  repeat_onsets;
onsets{3}    =  base_onsets;
durations{1} =  novel_duration;
durations{2} =  repeat_duration;
durations{3} =  base_duration;



