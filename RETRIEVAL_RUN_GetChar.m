function RETRIEVAL_RUN(encoding_file)

% initialize the pseudoramdom generator
rng('default')

% load parameters
Conf;

% Add experiment path
addpath(conf.dir_stim)

% path for data saving
Dir = conf.dir_stim;
SubDir1 = conf.subdir1;
SubDir2 =  conf.subdir2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BLOCK RANDOMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 = retrieval; 3 = baseline;
% 2 miniblocks per conditions

conds = [1 1 1 1 ];
reps  = [1 2 3 4 ];
randomization = randperm(length(conds));
conds = conds(randomization);
reps  = reps(randomization);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% STIM DURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PICdur   = 1;
% IDLEdur  = 5;
% LIMITdur = 3.5;

PICdur   = 1;
IDLEdur  = 5;
LIMITdur = 3.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE KEYS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define keys
key{1} = 'b'; % left button
key{2} = 'a'; % right button
key{3} = 'T'; % MR pulse
key{4} = ' '; % space bar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PICTURE ORIENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
angle = 180;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% affichage warning/error/autocalibration settings
Screen('Preference','SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'ConserveVRAM', 4096);
screens = Screen('Screens');

% Clear the workspace and the screen
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
if conf.debug
    PsychDebugWindowConfiguration();
end
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = 0;

% Define black and white
white   = WhiteIndex(screenNumber);
black   = BlackIndex(screenNumber);
grey    = white / 2;

% Open an on screen window
[w, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', w);

% main window dimensions
[X,Y]   = RectCenter(windowRect);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% pcenter screen position
dispW   = windowRect(3) - windowRect(1);
dispH   = windowRect(4) - windowRect(2);
x0      = round(dispW/2);
y0      = round(dispH/2);
R       = 15;
R1      = 11;

% fixation cross
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';
Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%% SET STIM PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load ENCODING PICTURES
% encoding_run = [conf.dir_rt 'ENCODING_testirm_1'];
encoded = load([conf.dir_rt encoding_file]);

fileListIndoor_old = []; fileListOutdoor_old = [];

repeat = encoded.BLOCKREPEAT{1,1};
novel = encoded.BLOCKNOVEL{1,1};

rep = []; nov = [];
rep = cellstr(repeat.InDoorImg); nov = cellstr(novel.InDoorImg);
fileListIndoor_old = [rep nov];
rep = []; nov = [];
rep = cellstr(repeat.OutDoorImg); nov = cellstr(novel.OutDoorImg);
fileListOutdoor_old = [rep nov];

% Load new images
fileListIndoor_new = []; fileListOutdoor_new = [];
in = dir(conf.indoor);
out = dir(conf.outdoor);

% remove already used pictures for encoding from the "new" indoor picture list
indexOld2RM = [];
count = 1;
for i = 1:length(in)
    for j = 1:length(fileListIndoor_old)
        if strcmp(in(i).name,fileListIndoor_old{j})
            indexOld2RM = [indexOld2RM i];
        end
    end
end
in(indexOld2RM) = [];
% remove already used pictures for encoding from the "new" outdoor picture list
indexOld2RM = [];
count = 1;
for i = 1:length(out)
    for j = 1:length(fileListOutdoor_old)
        if strcmp(out(i).name,fileListOutdoor_old{j})
            indexOld2RM = [indexOld2RM i];
        end
    end
end
out(indexOld2RM) = [];

fileListIndoor_new  = {in.name};
fileListOutdoor_new = {out.name};

in_scrambled = dir(conf.dir_indoorscrambled);
out_scrambled  = dir(conf.dir_outdoorscrambled);
fileListIndoorscrambled  = {in_scrambled.name};
fileListOutdoorscrambled = {out_scrambled.name};

% set initial parameters
step = ifi;
% FlushEvents;
keyIsDown = 0;

HideCursor()

% DISPLAY GENERAl INSTRUCTIONS

retrieval_instr1 = ['During the experiment, you will see visual scenes.\n ' ...
    '\n you will have to indicate if you already saw these visual scenes in the previous sessions\n ' ...
    '\n  then you will have to indicate how confident you are\n '...
    '\n \n Please press any key to continue '];

retrieval_instr2 = ['To indicate if the scene you saw was seen previously:\n ' ...
    '\n \n you will have to press the left arrow key if already seen (old)\n ' ...
    'or\n  you will have to press the right arrow key if never seen (new)\n '...
    '\n \n \n Please press any key to continue '];

retrieval_instr3 = ['Then, to indicate your confidence level in the answer you just gave:\n ' ...
    '\n \n you will move the red cursor with the mouse on the bottom scale\n ' ...
    '\n  and click on the left mouse button to validate\n '...
    '\n \n \n Please press any key to continue '];

rest_instr1 = ['After each block, a fixation cross will be displayed\n ' ...
    '\n \n  During the next 30s, you have to fixate the cross \n '...
    '\n \n \n Please press any key to continue '];

trig_instr1 = ['Waiting for MRI pulse...'];

if angle == 180
    verticalfliplag = 1;
else
    verticalfliplag = 0;
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, retrieval_instr1,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, retrieval_instr2,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, retrieval_instr3,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

% "Wait for MRI" trigger
Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, trig_instr1,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% trigger release check
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,key{3})
        mri_onset = GetSecs;
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  MINI BLOCKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reorder          = randperm(104);
reorder_baseline = randperm(48);

rand_in_img_baseline  = randperm(length(fileListIndoorscrambled));
rand_out_img_baseline = randperm(length(fileListOutdoorscrambled));

% randomization "OLD" pics
rand_in_img_old = []; rand_out_img_old = [];
for i = 1:8
    rand_in_img_old  = [rand_in_img_old  randperm(length(fileListIndoor_old))];
end
for i = 1:4
    rand_out_img_old = [rand_out_img_old randperm(length(fileListOutdoor_old))];
end
% randomization "NEW" pics
rand_in_img_new = []; rand_out_img_new = [];
for i = 1:8
    rand_in_img_new  = [rand_in_img_new  randperm(length(fileListIndoor_new))];
end
for i = 1:4
    rand_out_img_new = [rand_out_img_new randperm(length(fileListOutdoor_new))];
end

for i = 1:length(conds)
    
    if reps(i) == 1
        trial_indexes_baseline  = 1:24;
        trial_indexes_retrieval = 1:26;
    elseif reps(i) == 2
        trial_indexes_baseline = 25:48;
        trial_indexes_retrieval = 27:52;
   elseif reps(i) == 3
       trial_indexes_baseline = 1:24;
       trial_indexes_retrieval = 53:78;
    elseif reps(i) == 4
        trial_indexes_baseline = 25:48;
        trial_indexes_retrieval = 79:104;
    end
    
    if conds(i) == 1
        % Load images
        % old
%         rand_in_img_old = []; rand_out_img_old = [];
%         for i = 1:8
%             rand_in_img_old  = [rand_in_img_old  randperm(length(fileListIndoor_old))];
%         end
%         for i = 1:4
%             rand_out_img_old = [rand_out_img_old randperm(length(fileListOutdoor_old))];
%         end
        InDoorImg_old  = []; OutDoorImg_old = [];
        InDoorImg_old  = fileListIndoor_old(rand_in_img_old(1:24));
        OutDoorImg_old = fileListOutdoor_old(rand_out_img_old(1:28));
        
        % new
%         rand_in_img_new = []; rand_out_img_new = [];
%         for i = 1:8
%             rand_in_img_new  = [rand_in_img_new  randperm(length(fileListIndoor_new))];
%         end
%         for i = 1:4
%             rand_out_img_new = [rand_out_img_new randperm(length(fileListOutdoor_new))];
%         end
        InDoorImg_new  = []; OutDoorImg_new = [];
        InDoorImg_new  = fileListIndoor_new(rand_in_img_new(1:24));
        OutDoorImg_new = fileListOutdoor_new(rand_out_img_new(1:28));
        
        % list of non-repeated events
        listevents_old = []; listevents_old = [ones(1,24) ones(1,28).*2];
        listevents_new = []; listevents_new = [ones(1,24).*3 ones(1,28).*4];
        
        % combine old and new
        listevents_type = []; listevents_instance = [];
        listevents_type     = [ones(1,24) ones(1,28).*2 ones(1,24).*1 ones(1,28).*2];
        listevents_instance = [1:24 1:28 ...
            1:24 1:28 ];
%         reorder             = randperm(104);
        listevents_type     = listevents_type(reorder);
        listevents_instance = listevents_instance(reorder);
        
        Img  = [];
        Img  = [InDoorImg_old OutDoorImg_old InDoorImg_new OutDoorImg_new];
        Img  = Img(reorder);
        
        % launch encoding novel for a fixed number of repetitions
        BLOCKRETRIEVAL{reps(i)} = Retrieval_loopBaseline_block(listevents_type,...
            listevents_instance,Img,trial_indexes_retrieval,screenYpixels,screenXpixels,...
            w,screenNumber,key,X,Y, PICdur, LIMITdur, IDLEdur,angle,verticalfliplag);
        
    elseif conds(i) == 3
        % block baseline
        rand_in_img = []; rand_out_img = [];
        %         rand_in_img  = randperm(length(fileListIndoorscrambled));
        %         rand_out_img = randperm(length(fileListOutdoorscrambled));
        
        InDoorImg  = []; OutDoorImg = [];
        InDoorImg  = fileListIndoorscrambled(rand_in_img_baseline(1:2));
        OutDoorImg = fileListOutdoorscrambled(rand_out_img_baseline(1:6));
        
        % list of non-repeated events
        listevents_type     = [ones(1,36) ones(1,12).*2];
        listevents_instance = [ones(1,6).*1 ones(1,6).*2 ones(1,6).*3 ones(1,6).*4 ...
            ones(1,6).*5 ones(1,6).*6 ones(1,6).*1 ones(1,6).*2 ];
        %         reorder             = randperm(48);
        listevents_type     = listevents_type(reorder_baseline);
        listevents_instance = listevents_instance(reorder_baseline);
        
        tagoutdoor = 0;
        tagindoor  = 0;
        
        meta_position_list = [];
        meta_RT_list = [];
        meta_answer_list = [];
        
        % launch encoding novel for a fixed number of repetitions
        BLOCKBASE{reps(i)} = Baseline_block(listevents_type,listevents_instance,InDoorImg,OutDoorImg,...
            tagoutdoor,tagindoor,trial_indexes_baseline,screenYpixels,screenXpixels,w,...
            screenNumber,key,X,Y, PICdur, LIMITdur, IDLEdur,angle,verticalfliplag);
        
    end
end

save([conf.dir_rt '/RETRIEVAL_' encoding_file '.mat']);

Screen('CloseAll');
ListenChar(1)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BLOCKRETRIEVAL = Retrieval_loopBaseline_block(listevents_type,listevents_instance,Img,trial_indexes,screenYpixels,screenXpixels,w,screenNumber,key,X,Y, PICdur, LIMITdur, IDLEdur,angle,verticalfliplag)

RespOnset = [];
RespOffset = [];

Conf;

% Define black and white
white   = WhiteIndex(screenNumber); 
black   = BlackIndex(screenNumber);
grey    = white / 2; 

% fixation cross
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';
Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

% retrieval block
for j = trial_indexes

    % count indoor and outdoor events
    ImageLocation = [];
    ImageLocation = [conf.dir_retrieval Img{j}];
    Img_ = []; Img_ = imread(ImageLocation);
    
    TagOK = 0;
    
    % button release check
%     keyisdown = 1;
%     while(keyisdown) % first wait until all keys are released
%         [keyisdown,GetSecs,keycode] = KbCheck;
%         WaitSecs(0.001); % delay to prevent CPU hogging
%     end
    
    theImage = Img_;
    
    % Get the size of the image
    [s1, s2, s3] = size(theImage);
    
    % Get the aspect ratio of the image. We need this to maintain the aspect
    % ratio of the image when we draw it different sizes. Otherwise, if we
    % don't match the aspect ratio the image will appear warped \ stretched
    aspectRatio = s2 / s1;
    
    % We will set the height of each drawn image to a fraction of the screens
    % height
    heightScalers = 0.5;
    imageHeights = screenYpixels .* heightScalers;
    imageWidths = imageHeights .* aspectRatio;
    
    % Make the destination rectangles for our image. We will draw the image
    % multiple times over getting smaller on each iteration. So we need the big
    % dstRects first followed by the progressively smaller ones
    dstRects       = 0;
    theRect        = [0 0 imageWidths(1) imageHeights(1)];
    dstRects = CenterRectOnPointd(theRect, screenXpixels / 2, screenYpixels / 2);
    
    % Draw the image to the screen, unless otherwise specified PTB will draw
    % the texture full size in the center of the screen.
    imageTexture = Screen('MakeTexture', w, theImage);
    Screen('DrawTextures', w, imageTexture, [], dstRects, angle);
    PicOnset = Screen('Flip',w);
    WaitSecs(PICdur);
    
    % indoor or outdoor?
    Screen('TextSize', w, 30);
    DrawFormattedText(w, ['old or new?'],'center', 'center', white,[],verticalfliplag,verticalfliplag);
    RespOnset(j) = Screen('Flip',w);
    
    % check that time is lower than upper limit
    while (TagOK == 0) && ((GetSecs - RespOnset(j)) <= LIMITdur)
        % check if one key has been pressed
        str = [];
        if CharAvail
           str = GetChar(0);
        end
        % check if the right key has been pressed
        if ~isempty(str)
            keycode_Resp{j} = str;
            if strcmp(keycode_Resp{j},key{1}) || strcmp(keycode_Resp{j},key{2})
                RespOffset(j) = GetSecs;
                TagOK = 1;
            else
                TagOK = 0;
            end
        else
            keycode_Resp{j} = NaN;
        end
    end
    % if the delay is passed, no response
    noresponse = GetSecs;
    
    % Get the key press offset if any
    if TagOK == 0
        TimePush = noresponse;
    else
        TimePush = RespOffset(j);
    end
    
    % calculate the reaction time
    Resp_rtime(j) = TimePush - RespOnset(j);
    
    % record reaction time
    RT{j} = Resp_rtime(j);
    
    % display fixation cross for Inter-Trial-Interval
    Screen('FillRect',w,black,FixCross);
    ITIOnset = Screen('Flip',w);
    WaitSecs(IDLEdur);
    
end
    

% display fixation cross for Resting period
Screen('Flip',w);
Screen('FillRect',w,black,FixCross);
RestOffset = GetSecs;
WaitSecs(5);

% % save randomization order and RT
% save([conf.dir_rt '\Retrieval_' id 'run_' num2str(numrep) '_EpisodicMemory.mat'],...
%     'listevents_type','keycode_Resp','RT','Img',...
%     'meta_position_list','meta_RT_list','meta_answer_list');

BLOCKRETRIEVAL = struct();
BLOCKRETRIEVAL(1).listevents_type = listevents_type;
BLOCKRETRIEVAL(1).listevents_instance = listevents_instance;
BLOCKRETRIEVAL(1).keycode_Resp = keycode_Resp;
BLOCKRETRIEVAL(1).RT = RT;
BLOCKRETRIEVAL(1).Img = Img;
BLOCKRETRIEVAL(1).TimePush = TimePush;
BLOCKRETRIEVAL(1).trial_indexes = trial_indexes;
BLOCKRETRIEVAL(1).RespOnset = RespOnset;
BLOCKRETRIEVAL(1).RespOffset = RespOffset;
BLOCKRETRIEVAL(1).PicOnset = PicOnset;
BLOCKRETRIEVAL(1).ITIOnset = ITIOnset;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BLOCKBASE = Baseline_block(listevents_type,listevents_instance,InDoorImg,OutDoorImg,tagoutdoor,tagindoor,trial_indexes,screenYpixels,screenXpixels,w,screenNumber,key,X,Y, PICdur, LIMITdur, IDLEdur,angle,verticalfliplag)

Conf;

RespOnset = [];
RespOffset = [];

% Define black and white
white   = WhiteIndex(screenNumber); 
black   = BlackIndex(screenNumber);
grey    = white / 2; 

% fixation cross
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';
Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

% "BASELINE" block
for j = trial_indexes
    
    disp(j);
    
    % count indoor and outdoor events
    if listevents_type(j) == 1
        tagoutdoor = tagoutdoor + 1;
        disp(tagoutdoor)
        % Load in a random image image from the outdoor folder
        OutdoorImageLocation = [conf.dir_outdoorscrambled OutDoorImg{listevents_instance(j)}];
        OutdoorImg_ = []; OutdoorImg_ = imread(OutdoorImageLocation);
    elseif listevents_type(j) == 2
        tagindoor  = tagindoor + 1;
        disp(tagindoor)
        % Load in a random image image from the indoor folder
        IndoorImageLocation  = [conf.dir_indoorscrambled InDoorImg{listevents_instance(j)}];
        IndoorImg_ = []; IndoorImg_ = imread(IndoorImageLocation);
    end
    
    TagOK = 0;
    
    % button release check
%     keyisdown = 1;
%     while(keyisdown) % first wait until all keys are released
%         [keyisdown,GetSecs,keycode] = KbCheck;
%         WaitSecs(0.001); % delay to prevent CPU hogging
%     end
    
    theImage = [];
    if listevents_type(j) == 1
        theImage = OutdoorImg_;
    elseif listevents_type(j) == 2
        theImage = IndoorImg_;
    end
    
    % Get the size of the image
    [s1, s2, s3] = size(theImage);
    
    % Get the aspect ratio of the image. We need this to maintain the aspect
    % ratio of the image when we draw it different sizes. Otherwise, if we
    % don't match the aspect ratio the image will appear warped / stretched
    aspectRatio = s2 / s1;
    
    % We will set the height of each drawn image to a fraction of the screens
    % height
    heightScalers = 0.5;
    imageHeights = screenYpixels .* heightScalers;
    imageWidths = imageHeights .* aspectRatio;
    
    % Make the destination rectangles for our image. We will draw the image
    % multiple times over getting smaller on each iteration. So we need the big
    % dstRects first followed by the progressively smaller ones
    dstRects       = 0;
    theRect        = [0 0 imageWidths(1) imageHeights(1)];
    dstRects = CenterRectOnPointd(theRect, screenXpixels / 2, screenYpixels / 2);
    
    % Draw the image to the screen, unless otherwise specified PTB will draw
    % the texture full size in the center of the screen.
    imageTexture = Screen('MakeTexture', w, theImage);
    Screen('DrawTextures', w, imageTexture, [], dstRects, angle);
    PicOnset = Screen('Flip',w);
    WaitSecs(PICdur);
    
    % indoor or outdoor?
    Screen('TextSize', w, 30);
    DrawFormattedText(w, ['PUSH'],'center', 'center', white,[],verticalfliplag,verticalfliplag);
    RespOnset(j) = Screen('Flip',w);
    
    % check that time is lower than upper limit
    while (TagOK == 0) && ((GetSecs - RespOnset(j)) <= LIMITdur)
        % check if one key has been pressed
        str = [];
        if CharAvail
           str = GetChar(0);
        end
        % check if the right key has been pressed
        if ~isempty(str)
            keycode_Resp{j} = str;
            if strcmp(keycode_Resp{j},key{1}) || strcmp(keycode_Resp{j},key{2})
                RespOffset(j) = GetSecs;
                TagOK = 1;
            else
                TagOK = 0;
            end
        else
            keycode_Resp{j} = NaN;
        end
    end
    % if the delay is passed, no response
    noresponse = GetSecs;
    
    % Get the key press offset if any
    if TagOK == 0
        TimePush = noresponse;
    else
        TimePush = RespOffset(j);
    end
    
    % calculate the reaction time
    Resp_rtime(j) = TimePush - RespOnset(j);
    
    % record reaction time
    RT{j} = Resp_rtime(j);
    
    % display fixation cross for Inter-Trial-Interval
    Screen('FillRect',w,black,FixCross);
    ITIOnset = Screen('Flip',w);
    WaitSecs(IDLEdur);
    
    % slide metacognition
    if 0
        [meta_position, meta_RT, meta_answer] = slideScale(w, 'How confident are you about your answer?',...
            windowRect,{'0%';'100%'},'slidecolor',[255 0 0],'width',6);
        
        meta_position_list{j} = meta_position;
        meta_RT_list{j} =  meta_RT;
        meta_answer_list{j} = meta_answer;
    end
end

% display fixation cross for Resting period
Screen('FillRect',w,black,FixCross);
RestOffset = GetSecs;
WaitSecs(5);

% save([conf.dir_rt '/Baseline_' id '_run_' num2str(numrep) '.mat'],...
%     'listevents_type','listevents_instance','keycode_Resp','RT','InDoorImg','OutDoorImg',...
%     'meta_position_list','meta_RT_list','meta_answer_list','TimePush','mri_onset','RestOffset');

BLOCKBASE = struct();
BLOCKBASE(1).listevents_type = listevents_type;
BLOCKBASE(1).listevents_instance = listevents_instance;
BLOCKBASE(1).keycode_Resp = keycode_Resp;
BLOCKBASE(1).RT = RT;
BLOCKBASE(1).InDoorImg = InDoorImg;
BLOCKBASE(1).OutDoorImg = OutDoorImg;
BLOCKBASE(1).TimePush = TimePush;
BLOCKBASE(1).RestOffset = RestOffset;
BLOCKBASE(1).trial_indexes = trial_indexes;
BLOCKBASE(1).RespOnset = RespOnset;
BLOCKBASE(1).RespOffset = RespOffset;
BLOCKBASE(1).PicOnset = PicOnset;
BLOCKBASE(1).ITIOnset = ITIOnset;

end
