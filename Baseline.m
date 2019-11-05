function Baseline(id, numrep)6
Conf;
%% demo test WHAT recognition task
%addpath('D:/Time_island/Stim')

%%%%%%%%%%%%%%%%
% clear all
% close all
% id = 'niptest';
% numrep = 1;
%%%%%%%%%%%%%%%%
addpath(conf.dir_stim)
%addpath('D:/Episodic_Memory_Sonication/STIM')
% AddPsychJavaPath;
% AssertOpenGL;

%% %%%%%%%%%%%%%%%%%%% Get FILENAME build by user input %%%%%%%%%%%%%%%%%%%
% path for data saving
Dir = conf.dir_stim;
SubDir1 = conf.subdir1;
SubDir2 =  conf.subdir2;
%% %%%%%%%%%%%%%%% SET DISPLAY PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% affichage warning/error/autocalibration settings
Screen('Preference','SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'ConserveVRAM', 4096);
%Screen('Preference', 'ConserveVRAM', 64);

screens = Screen('Screens');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the workspace and the screen
sca;
close all;
% clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
if conf.debug
    PsychDebugWindowConfiguration();
    
end
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = 2;

% Define black and white
white   = WhiteIndex(screenNumber);
black   = BlackIndex(screenNumber);
grey    = white / 2;
inc     = white - grey;
red     = [255 0 0 ];
green   = [0 255 0];
blue    = [0 0 255];
yellow  = [255 255 0];

% Open an on screen window
[w, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
% [w,windowRect] = Screen('OpenWindow', screenNumber,0,[],32,2);
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', w);


%% DEBUGGING
% PsychDebugWindowConfiguration(0.5)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [w,windowRect] = Screen('OpenWindow', screenNumber,0,[],32,2);
% Open an on screen window
% [w, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

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

% fixation cross for dimension cueing
FixCross  = [X-2,Y-15,X+2,Y+15;X-15,Y-2,X+15,Y+2]';

Mat1 = diag(ones(1,16))+diag(ones(15,1),1)+diag(ones(15,1),-1);
Mat2 = flipdim(Mat1,1);
Mat = ((Mat1 + Mat2) ~= 0)*255;

%% %%%%%%%%%%%%%%%%%%%%%%% SET STIM PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize pseudorandom number generator
rand('state',sum(100*clock))

% Load images
fileListIndoor = []; fileListOutdoor = [];
in = dir(conf.indoorscrambled );
out = dir(conf.outdoorscrambled);

fileListIndoor  = {in.name};
fileListOutdoor = {out.name};

% set initial parameters
step = ifi;
% FlushEvents;
keyIsDown = 0;

HideCursor()

% define keys
triggerkey = 53;
key1 = 49; 
key2 = 54; 

% DISPLAY GENERAl INSTRUCTIONS
g1instr = ['During the experiment, you will see indoor and outdoor scenes.\n ' ...
    '\n ' ...
    'you will have to indicate if the scene you just saw is indoor or outdoor\n ' ...
    '\n  ' ...
    'then you will have to indicate how confident you are\n '...
    '\n ' ...
    '\n ' ...
    'Please press any key to continue '];

g2instr = ['To indicate if the scene you saw was indoor or outdoor:\n ' ...
    '\n ' ...
    '\n ' ...
    'you will have to press the left arrow key for indoor\n ' ...
    'or\n  ' ...
    'you will have to press the right arrow key for outdoor\n '...
    '\n ' ...
    '\n ' ...
    '\n ' ...
    'Please press any key to continue '];

g3instr = ['Then, to indicate your confidence level in the answer you just gave:\n ' ...
    '\n ' ...
    '\n ' ...
    'you will move the red cursor with the mouse on the bottom scale\n ' ...
    '\n  ' ...
    'and click on the left mouse button to validate\n '...
    '\n ' ...
    '\n ' ...
    '\n ' ...
    'Please press any key to continue '];

trigdisplay = ['Waiting for MRI pulse...'];

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, g1instr,...
    'center', 'center', white);
Screen('Flip',w);

while KbCheck
end
KbWait

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, g2instr,...
    'center', 'center', white);
Screen('Flip',w);

while KbCheck
end
KbWait

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, g3instr,...
    'center', 'center', white);
Screen('Flip',w);

while KbCheck
end
KbWait

tic; init_time = toc;

% % self-triggered experiment beginning
% LetsGo = 'please press the space bar to start';
% boundsLetsGo = TextBounds(w,LetsGo);
% Screen('DrawText', w, LetsGo, (X-boundsLetsGo(3)./2), Y, white, black, 1);

% self-triggered experiment beginning
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', w, 30);
DrawFormattedText(w, 'please press the spacebar to start the experiment.', 'center', 'center', white);
Screen('Flip',w);

while KbCheck
end
KbWait

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rand_in_img = []; rand_out_img = [];
rand_in_img  = randperm(length(fileListIndoor));
rand_out_img = randperm(length(fileListOutdoor));

InDoorImg  = []; OutDoorImg = [];
InDoorImg  = fileListIndoor(rand_in_img(1:2));
OutDoorImg = fileListOutdoor(rand_out_img(1:6));

% list of non-repeated events
listevents_type     = [ones(1,36) ones(1,12).*2];
listevents_instance = [ones(1,6).*1 ones(1,6).*2 ones(1,6).*3 ones(1,6).*4 ...
    ones(1,6).*5 ones(1,6).*6 ones(1,6).*1 ones(1,6).*2 ];
reorder             = randperm(48);
listevents_type     = listevents_type(reorder);
listevents_instance = listevents_instance(reorder);

tagoutdoor = 0;
tagindoor  = 0;

meta_position_list = [];
meta_RT_list = [];
meta_answer_list = [];

%% "Wait for MRI" trigger

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Geneva');
DrawFormattedText(w, trigdisplay,'center', 'center', white);
Screen('Flip',w);

% button release check
while 1 
    [keyisdown,secs,keycode] = KbCheck;
    if keyisdown
        if find(keycode) == triggerkey
            mri_onset = secs;
            break;
        end
    end
end

% "NOVEL" block
for j = 1:length(listevents_type)
    
    % count indoor and outdoor events
    if listevents_type(j) == 1
        tagoutdoor = tagoutdoor + 1;
        disp(tagoutdoor)
        % Load in a random image image from the outdoor folder
        OutdoorImageLocation = [conf.dir_outdoorscrambled '/' OutDoorImg{listevents_instance(j)}];
        OutdoorImg_ = []; OutdoorImg_ = imread(OutdoorImageLocation);
    elseif listevents_type(j) == 2
        tagindoor  = tagindoor + 1;
        disp(tagindoor)
        % Load in a random image image from the indoor folder
        IndoorImageLocation  = [conf.dir_indoorscrambled '/' InDoorImg{listevents_instance(j)}];
        IndoorImg_ = []; IndoorImg_ = imread(IndoorImageLocation);
    end
    
    TagOK = 0;
    
    % button release check
    keyisdown = 1;
    while(keyisdown) % first wait until all keys are released
        [keyisdown,secs,keycode] = KbCheck;
        WaitSecs(0.001); % delay to prevent CPU hogging
    end
    
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
    Screen('DrawTextures', w, imageTexture, [], dstRects);
    Screen('Flip',w);
    WaitSecs(0.5);
    
    % indoor or outdoor?
    Screen('TextSize', w, 30);
    DrawFormattedText(w, ['PUSH'], 'center', 'center', white);
    RespOnset(j) = Screen('Flip',w);
    
    % check that time is lower than upper limit
    while (TagOK == 0) && ((GetSecs - RespOnset(j)) <= 2)
        % check if one key has been pressed
        [keyisdown,secs,keycode] = KbCheck;
        % check if the right key has been pressed
        keycode_Resp{j} = find(keycode == 1);
        if ~isempty(keycode_Resp{j})
            if (keycode_Resp{j} == key1) || (keycode_Resp{j} == key2)
                RespOffset(j) = secs;
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
    Screen('Flip',w);
    
    % record reaction time
    RT{j} = Resp_rtime(j);
    
    % display fixation cross for Inter-Trial-Interval
    Screen('FillRect',w,black,FixCross);
    WaitSecs(0.5);
    
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
RestOffset = secs;
WaitSecs(60);

% save randomization order and RT
save([conf.dir_rt '/Baseline_' id '_run_' num2str(numrep) '.mat'],...
    'listevents_type','listevents_instance','keycode_Resp','RT','InDoorImg','OutDoorImg',...
    'meta_position_list','meta_RT_list','meta_answer_list','TimePush','mri_onset','RestOffset');


namefile = [conf.dir_rt '/repeat_' id 'run_' num2str(numrep) '.mat'];


Screen('CloseAll');
