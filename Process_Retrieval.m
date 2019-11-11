function [test, names, onsets, durations] = Process_Retrieval(Retrieval_file)

data = load(Retrieval_file);
MRI_onset = data.mri_onset;

for i = 1:length(data.BLOCKRETRIEVAL)
    timeref(i) = data.BLOCKRETRIEVAL{1,i}.TimePush;
end

% get order
order = sortrows([timeref; 1 2 3 4]');

% offset of blocks (FIXME)
lasttimepush = timeref - ones(1,4).*MRI_onset ;
lasttimepush = lasttimepush(order(:,2));

% process miniblock
count = 1;
ONSETS = [];
RESP = [];
RESPO = [];
RT = [];
DISP = [];

for i = order(:,2)'
    % compute timing (missing info FIXME)
    
    if count == 1; % first pack of trials
        
        DispImg = [];
        tmpRT = [];
        onset = [];
        resp  = [];
        respO = [];
        trial_index = []; trial_index = data.BLOCKRETRIEVAL{1,i}.trial_indexes;
        
        for j = 1:length(trial_index)
            if j > 1
                tmpRT(j)   = [data.BLOCKRETRIEVAL{1,i}.RT{trial_index(j)}];
                onset(j)   = [onset(j-1) + data.BLOCKRETRIEVAL{1,i}.RT{trial_index(j-1)} + 5 + 1 + 0.051];
                resp(j)    = [data.BLOCKRETRIEVAL{1,i}.keycode_Resp{trial_index(j)}];
                respO(j)   = [data.BLOCKRETRIEVAL{1,i}.RespOffset(trial_index(j))];
                DispImg{j} =  data.BLOCKRETRIEVAL{1,i}.Img{trial_index(j)};
            else
                tmpRT(j)   = [data.BLOCKRETRIEVAL{1,i}.RT{trial_index(j)}];
                onset(j)   = [0];
                resp(j)    = [data.BLOCKRETRIEVAL{1,i}.keycode_Resp{trial_index(j)}];
                respO(j)   = [data.BLOCKRETRIEVAL{1,i}.RespOffset(trial_index(j))];
                DispImg{j} =  data.BLOCKRETRIEVAL{1,i}.Img{trial_index(j)};
            end
        end
        
        ONSETS{count} = onset;
        RT{count}     = tmpRT;
        RESP{count}   = resp;
        RESPO{count}  = respO;
        DISP          = [DISP DispImg];
        
        count = count +1;
        
    else % next packs of trials
        
        DispImg = [];
        tmpRT = [];
        onset = [];
        resp  = [];
        respO = [];
        trial_index = []; trial_index = data.BLOCKRETRIEVAL{1,i}.trial_indexes;
        
        for j = 1:length(trial_index)
            if j > 1
                tmpRT(j)   = [data.BLOCKRETRIEVAL{1,i}.RT{trial_index(j)}];
                onset(j)   = [onset(j-1) + data.BLOCKRETRIEVAL{1,i}.RT{trial_index(j-1)} + 5 + 1 + 0.051];
                resp(j)    = [data.BLOCKRETRIEVAL{1,i}.keycode_Resp{trial_index(j)}];
                respO(j)   = [data.BLOCKRETRIEVAL{1,i}.RespOffset(trial_index(j))];
                DispImg{j} =  data.BLOCKRETRIEVAL{1,i}.Img{trial_index(j)};
            else
                tmpRT(j)   = [data.BLOCKRETRIEVAL{1,i}.RT{trial_index(j)}];
                onset(j)   = [ONSETS{count-1}(end) + RT{count-1}(end) + 5 + 1 + 0.051 + 5];
                resp(j)    = [data.BLOCKRETRIEVAL{1,i}.keycode_Resp{trial_index(j)}];
                respO(j)   = [data.BLOCKRETRIEVAL{1,i}.RespOffset(trial_index(j))];
                DispImg{j} =  data.BLOCKRETRIEVAL{1,i}.Img{trial_index(j)};
            end
        end
        
        ONSETS{count} = onset;
        RT{count}     = tmpRT;
        RESP{count}   = resp;
        RESPO{count}  = respO;
        DISP          = [DISP DispImg];
        
        count = count + 1;
        
    end
end

CatONSETS = [ONSETS{1,1} ONSETS{1,2} ONSETS{1,3} ONSETS{1,4}];
CatRT     = [RT{1,1} RT{1,2} RT{1,3} RT{1,4}];
CatRESP   = [RESP{1,1} RESP{1,2} RESP{1,3} RESP{1,4}];
RESPO     = [RESPO{1,1} RESPO{1,2} RESPO{1,3} RESPO{1,4}];
test      = [CatRT; CatONSETS];

% real timing
RESPO = RESPO - ones(1,length(RESPO)).*data.mri_onset -CatRT - ones(1,length(RESPO)) ;
test2      = [CatRT; CatONSETS; RESPO];

% offset of blocks (FIXME)
lasttimepush = timeref - ones(1,4).*MRI_onset ;
lasttimepush = lasttimepush(order(:,2));

lastonset = [];
for i = 1:length(lasttimepush) % remove last RT to check per block last onset match
    lastonset(i) = lasttimepush(i)-RT{i}(end)-1;
end

lastonset - [ONSETS{1,1}(end) ONSETS{1,2}(end) ONSETS{1,3}(end) ONSETS{1,4}(end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% code resp %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list of image
List_img = DISP;

% list of old/new images 
List_img_old = [data.encoded.BLOCKNOVEL{1,1}.OutDoorImg data.encoded.BLOCKNOVEL{1,1}.InDoorImg...
                data.encoded.BLOCKREPEAT{1,1}.OutDoorImg data.encoded.BLOCKREPEAT{1,1}.InDoorImg];
List_img_new = [data.InDoorImg_new data.OutDoorImg_new];

imgcode = ones(1,length(List_img)).*2;
% coding  old = 0, new = 1
for i = 1:length(List_img)
    for j = 1:length(List_img_old)
        if not(isempty(strmatch(List_img{i},List_img_old{j})))
            imgcode(i) = 1;
        end
    end
%     for j = 1:length(List_img_new)
%         if not(isempty(strmatch(List_img{i},List_img_new{j})))
%             imgcode(i) = 2;
%         end
%     end
end

test = [CatRT; CatONSETS; CatRESP; imgcode]';

% build regressors list
old_onsets   = [];
new_onsets   = [];
old_duration = [];
new_duration = [];

count_old = 1; 
count_new = 1;

for i = 1:length(test)
    if test(i,4) == 1
        old_onsets(count_old)   = test(i,2); 
        old_duration(count_old) = test(i,1)+1; 
        count_old = count_old + 1;
    elseif test(i,4) == 2
        new_onsets(count_new)   = test(i,2); 
        new_duration(count_new) = test(i,1)+1;
        count_new = count_new + 1;
    end
end

names        = {'old','new'};
onsets{1}    =  old_onsets;
onsets{2}    =  new_onsets;
durations{1} =  old_duration;
durations{2} =  new_duration;



