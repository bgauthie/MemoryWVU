function ENCODING_RUN_GetChar(ID, numrep)

% initialize the pseudoramdom generator
rng('shuffle')

% load parameters
Conf;

% Add experiment path
addpath(conf.dir_stim)

% path for data saving
Dir     = conf.dir_stim;
SubDir1 = conf.subdir1;
SubDir2 =  conf.subdir2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BLOCK RANDOMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 = novel; 2 = repeat; 3 = baseline;
% 2 miniblock per conditions

conds = [1 2  1 2  3 3];
rep   = [1 1  2 2  1 2];
randomization = randperm(length(conds));
conds = conds(randomization);
rep   = rep(randomization);

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
key{1} = 'a'; % left button
key{2} = 'b'; % right button
key{3} = 'T'; % MR pulse
key{4} = ' '; % space bar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PICTURE ORIENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
angle = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% affichage warning/error/autocalibration settings
Screen('Preference','SyncTests', 0);
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
% initialize pseudorandom number generator
rand('state',sum(100*clock))

% Load images
fileListIndoor = []; fileListOutdoor = [];
in = dir(conf.indoor);
out = dir(conf.outdoor);
in_scrambled = dir(conf.dir_indoorscrambled);
out_scrambled  = dir(conf.dir_outdoorscrambled);

fileListIndoor  = {in.name};
fileListOutdoor = {out.name};
fileListIndoorscrambled  = {in_scrambled.name};
fileListOutdoorscrambled = {out_scrambled.name};

% set initial parameters
step = ifi;
% FlushEvents;
keyIsDown = 0;

HideCursor()

% DISPLAY GENERAl INSTRUCTIONS
encoding_instr1 = ['During RECOGNITION block, you will see indoor and outdoor scenes.\n ' ...
    '\n you will have to indicate if the scene you just saw is indoor \n ' ...
    '\n \n Please press any key to continue '];

encoding_instr2 = ['To indicate if the scene you saw was indoor or outdoor:\n ' ...
    '\n \n you will have to press the left button for indoor\n ' ...
    'or \n  you will have to press the right button for outdoor\n '...
    '\n \n \n Please press any key to continue '];

baseline_instr1 = ['During BUTTON PRESS block you will see scrambled images\n ' ...
    '\n \n  and then will be instructed to push the button. \n ' ...
    '\n  When you see "PUSH" displayed in the middle of the screen, push either left or right button\n '...
    '\n \n \n Please press any key to continue '];

rest_instr1 = ['After each block, a fixation cross will be displayed\n ' ...
    '\n \n  During the next 5s, you have to fixate the cross \n '...
    '\n \n \n Please press any key to continue '];

trig_instr1 = ['Waiting for MRI pulse...'];

if angle == 180
    verticalfliplag = 1;
else
    verticalfliplag = 0;
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, encoding_instr1,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

% while KbCheck
% end
% KbWait

KbName('UnifyKeyNames')
FlushEvents('KeyDown');
ListenChar(2)

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, encoding_instr2,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, rest_instr1,'center', 'center', white,[],verticalfliplag,verticalfliplag);
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
reorder_novel    = randperm(48);
reorder_repeat   = randperm(48);
reorder_baseline = randperm(48);

rand_in_img_novel     = randperm(length(fileListIndoor));
rand_out_img_novel    = randperm(length(fileListOutdoor));
rand_in_img_repeat    = randperm(length(fileListIndoor));
rand_out_img_repeat   = randperm(length(fileListOutdoor));
rand_in_img_baseline  = randperm(length(fileListIndoorscrambled));
rand_out_img_baseline = randperm(length(fileListOutdoorscrambled));

for i = 1:length(conds)
    
    if rep(i) == 1
        trial_indexes = 1:24;
    else
        trial_indexes = 25:48;
    end
    
    if conds(i) == 1 
        % block novel
        
        % Load images
        rand_in_img = []; rand_out_img = [];
%         rand_in_img  = randperm(length(fileListIndoor));
%         rand_out_img = randperm(length(fileListOutdoor));
        
        InDoorImg  = []; OutDoorImg = [];
        InDoorImg  = fileListIndoor(rand_in_img_novel(1:2));
        OutDoorImg = fileListOutdoor(rand_out_img_novel(1:6));
        
        % list of non-repeated events
        listevents_type     = [ones(1,36) ones(1,12).*2];
        listevents_instance = [ones(1,6).*1 ones(1,6).*2 ones(1,6).*3 ones(1,6).*4 ...
            ones(1,6).*5 ones(1,6).*6 ones(1,6).*1 ones(1,6).*2 ];
%         reorder             = randperm(48);
        listevents_type     = listevents_type(reorder_novel);
        listevents_instance = listevents_instance(reorder_novel);
        
        tagoutdoor = 0;
        tagindoor  = 0;
        
        % launch encoding novel for a fixed number of repetitions
        BLOCKNOVEL{rep(i)} = Encoding_novel(listevents_type,listevents_instance,InDoorImg,OutDoorImg,...
            tagoutdoor,tagindoor,trial_indexes,screenYpixels,screenXpixels,w,...
            screenNumber,key,X,Y, PICdur, IDLEdur, LIMITdur,angle,verticalfliplag);
        
    elseif conds(i) == 2
        % block repeat
        
%         rand_in_img  = randperm(length(fileListIndoor));
%         rand_out_img = randperm(length(fileListOutdoor));
        
        InDoorImg  = fileListIndoor{rand_in_img_repeat(1)};
        OutDoorImg = fileListOutdoor{rand_out_img_repeat(1)};
        
        % list of repeated events
        listevents = [ones(1,36) ones(1,12).*2];
        listevents = listevents(reorder_repeat);
        
        tagoutdoor = 0;
        tagindoor  = 0;
        
        meta_position_list = [];
        meta_RT_list = [];
        meta_answer_list = [];
        
        % launch encoding novel for a fixed number of repetitions
        BLOCKREPEAT{rep(i)} = Encoding_repeat(listevents,InDoorImg,OutDoorImg,tagoutdoor,tagindoor,...
            trial_indexes,screenYpixels,screenXpixels,w,screenNumber,key,...
            X,Y,  PICdur, IDLEdur, LIMITdur,angle,verticalfliplag);
        
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
        BLOCKBASE{rep(i)} = Baseline_block(listevents_type,listevents_instance,InDoorImg,OutDoorImg,...
            tagoutdoor,tagindoor,trial_indexes,screenYpixels,screenXpixels,w,...
            screenNumber,key,X,Y, PICdur, IDLEdur, LIMITdur,angle,verticalfliplag);
        
    end
end

save([conf.dir_rt '/ENCODING_' ID '_' num2str(numrep) '.mat']);

Screen('CloseAll');
ListenChar(1)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BLOCKNOVEL = Encoding_novel(listevents_type,listevents_instance,InDoorImg,OutDoorImg,tagoutdoor,tagindoor,trial_indexes,screenYpixels,screenXpixels,w,screenNumber,key,X,Y, PICdur, IDLEdur,LIMITdur,angle,verticalfliplag)

Conf;

RespOnset = [];
RespOffset = [];
PicOnset = [];
ITIOnset = [];

% Define black and white
white   = WhiteIndex(screenNumber); 
black   = BlackIndex(screenNumber);
grey    = white / 2; 

% fixation cross
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';
Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

% additional instruction 15/02/2021
Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
instr = ['This is a RECOGNITION block:\n ' ...
    'to indicate if the scene you saw was indoor or outdoor:\n ' ...
    '\n \n you will have to press the left button for indoor\n ' ...
    'or \n  you will have to press the right button for outdoor\n '...
    '\n \n \n Please press SPACEBAR to continue '];
DrawFormattedText(w, instr,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

% "NOVEL" block
for j = trial_indexes
    
    disp(j);
    
    % count indoor and outdoor events
    if listevents_type(j) == 1
        tagoutdoor = tagoutdoor + 1;
        disp(tagoutdoor)
        % Load in a random image image from the outdoor folder
        OutdoorImageLocation = [conf.dir_outdoor '/' OutDoorImg{listevents_instance(j)}];
        OutdoorImg_ = []; OutdoorImg_ = imread(OutdoorImageLocation);
    elseif listevents_type(j) == 2
        tagindoor  = tagindoor + 1;
        disp(tagindoor)
        % Load in a random image image from the indoor folder
        IndoorImageLocation  = [conf.dir_indoor '/' InDoorImg{listevents_instance(j)}];
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
    PicOnset(j) = Screen('Flip',w);
    WaitSecs(PICdur);
    
    % indoor or outdoor?
        FlushEvents('KeyDown')
    Screen('TextSize', w, 30);
    DrawFormattedText(w, ['Indoor or Outdoor?'],'center', 'center', white,[],verticalfliplag,verticalfliplag);
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

BLOCKNOVEL = struct();
BLOCKNOVEL(1).listevents_type = listevents_type;
BLOCKNOVEL(1).listevents_instance = listevents_instance;
BLOCKNOVEL(1).keycode_Resp = keycode_Resp;
BLOCKNOVEL(1).RT = RT;
BLOCKNOVEL(1).InDoorImg = InDoorImg;
BLOCKNOVEL(1).OutDoorImg = OutDoorImg;
BLOCKNOVEL(1).TimePush = TimePush;
BLOCKNOVEL(1).RestOffset = RestOffset;
BLOCKNOVEL(1).trial_indexes = trial_indexes;
BLOCKNOVEL(1).RespOnset = RespOnset;
BLOCKNOVEL(1).RespOffset = RespOffset;
BLOCKNOVEL(1).PicOnset = PicOnset;
BLOCKNOVEL(1).ITIOnset = ITIOnset;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BLOCKREPEAT = Encoding_repeat(listevents,InDoorImg,OutDoorImg,tagoutdoor,tagindoor,trial_indexes,screenYpixels,screenXpixels,w,screenNumber,key,X,Y, PICdur, IDLEdur,LIMITdur,angle,verticalfliplag)

Conf;

RespOnset = [];
RespOffset = [];
PicOnset = [];
ITIOnset = [];

% Define black and white
white   = WhiteIndex(screenNumber); 
black   = BlackIndex(screenNumber);
grey    = white / 2; 

% fixation cross
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';
Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

% additional instruction 15/02/2021
Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
instr = ['This is a RECOGNITION block:\n ' ...
    'to indicate if the scene you saw was indoor or outdoor:\n ' ...
    '\n \n you will have to press the left button for indoor\n ' ...
    'or \n  you will have to press the right button for outdoor\n '...
    '\n \n \n Please press SPACEBAR to continue '];
DrawFormattedText(w, instr,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

% "REPEAT" block
for j = trial_indexes
    
    disp(j);
    
    % count indoor and outdoor events
    if listevents(j) == 1
        tagoutdoor = tagoutdoor + 1;
        disp(tagoutdoor)
        % Load in a random image image from the outdoor folder
        OutdoorImageLocation = [conf.dir_outdoor '/' OutDoorImg];
        OutdoorImg = []; OutdoorImg = imread(OutdoorImageLocation);
    elseif listevents(j) == 2
        tagindoor  = tagindoor + 1;
        disp(tagindoor)
        % Load in a random image image from the indoor folder
        IndoorImageLocation  = [conf.dir_indoor '/' InDoorImg];
        IndoorImg = []; IndoorImg = imread(IndoorImageLocation);
    end
    
    TagOK = 0;
    
    % button release check
%     keyisdown = 1;
%     while(keyisdown) % first wait until all keys are released
%         [keyisdown,GetSecs,keycode] = KbCheck;
%         WaitSecs(0.001); % delay to prevent CPU hogging
%     end
    
    theImage = [];
    if listevents(j) == 1
        theImage = OutdoorImg;
    elseif listevents(j) == 2
        theImage = IndoorImg;
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
    PicOnset(j) = Screen('Flip',w);
    WaitSecs(PICdur);
    
    % indoor or outdoor?
    FlushEvents('KeyDown')
    Screen('TextSize', w, 30);
    DrawFormattedText(w, ['Indoor or Outdoor?'],'center', 'center', white,[],verticalfliplag,verticalfliplag);
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

% % save randomization order and RT
% save([conf.dir_rt '/EncodingRepeat_' id '_run_' num2str(numrep) '.mat'],...
%     'listevents','keycode_Resp','RT','InDoorImg','OutDoorImg',...
%     'meta_position_list','meta_RT_list','meta_answer_list','TimePush','mri_onset','RestOffset');

BLOCKREPEAT = struct();
BLOCKREPEAT(1).listevents = listevents;
BLOCKREPEAT(1).keycode_Resp = keycode_Resp;
BLOCKREPEAT(1).RT = RT;
BLOCKREPEAT(1).InDoorImg = InDoorImg;
BLOCKREPEAT(1).OutDoorImg = OutDoorImg;
BLOCKREPEAT(1).TimePush = TimePush;
BLOCKREPEAT(1).RestOffset = RestOffset;
BLOCKREPEAT(1).trial_indexes = trial_indexes;
BLOCKREPEAT(1).RespOnset = RespOnset;
BLOCKREPEAT(1).RespOffset = RespOffset;
BLOCKREPEAT(1).PicOnset = PicOnset;
BLOCKREPEAT(1).ITIOnset = ITIOnset;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BLOCKBASE = Baseline_block(listevents_type,listevents_instance,InDoorImg,OutDoorImg,tagoutdoor,tagindoor,trial_indexes,screenYpixels,screenXpixels,w,screenNumber,key,X,Y, PICdur, IDLEdur,LIMITdur,angle,verticalfliplag)

Conf;

RespOnset = [];
RespOffset = [];
PicOnset = [];
ITIOnset = [];

% Define black and white
white   = WhiteIndex(screenNumber); 
black   = BlackIndex(screenNumber);
grey    = white / 2; 

% fixation cross
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';
Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

% additional instruction 15/02/2021
Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
instr = ['This is a SCRAMBLED PICTURE block: you will see scrambled images\n ' ...
    '\n \n  and then will be instructed to push the button. \n ' ...
    '\n  When you see "PUSH" displayed in the middle of the screen, push either left or right button\n '...
    '\n \n \n Please press SPACEBAR to continue '];
DrawFormattedText(w, instr,'center', 'center', white,[],verticalfliplag,verticalfliplag);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% space bar release check
while ~strcmp(str,key{4})
    str = GetChar(0);
end

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
    PicOnset(j) = Screen('Flip',w);
    WaitSecs(PICdur);
    
    % indoor or outdoor?
    FlushEvents('KeyDown')
    Screen('TextSize', w, 30);
    DrawFormattedText(w, ['PUSH'],'center', 'center', white,[],verticalfliplag,verticalfliplag);
    RespOnset(j) = Screen('Flip',w);
    tmp = []; tmp = GetSecs;
    
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
