% COLOUR STROOP TASK

% This script re-creates a colour Stroop task, based upon that used in: Jaiswal, S. (2018). Better cognitive performance is associated with the
% combination of high trait mindfulness and low trait anxiety.

% The code generates a .mat file containing the workspace variables. The results are also saved in a variable 'resultsTable', which includes
% the colour, word, key response, time when the stimulus was shown, exact time when the user responds, and calculated RT.

% Clear the workspace and command window
clear all;          
clc;

% Subject information input boxes 

% Enter participant ID number, initials, and age
Participant_ID = input('Please enter participant ID, e.g. 001: '); 
Participant_name = input('Please enter your initials: ','s');    
Participant_age = input('Please enter your age: ');                

% Seed the random number generator

rand('state',sum(100*clock));

% Initialise Cogent

% Configures the display screen to demo mode (small screen)
config_display(0);  
% Initialise key presses (keyboard)
config_keyboard;
% Starts Cogent
start_cogent;   
% Enables low level Cogent functions
cgloadlib;          

config_log('PSM_MatlabExperiment_Stroop.log');
config_results('PSM_MatlabExperiment_Stroop.res');
% A .res file will be saved in the workspace under this file name

% Program start instruction

% Sets the pen colour to white
cgpencol(1,1,1)         
% Sets the font and size to Arial, size 20
cgfont('Arial',20)      

cgtext('Welcome to the experiment!',0,100);
cgtext('You will be shown words, one at a time, printed in different colours.',0,50);
cgtext('Press R for printed in red, G for green, B for blue, and Y for yellow.',0,25);
cgtext('Try to be as fast and accurate as possible.',0,0);
cgtext('Please press space to continue.',0,-50);
% Copies the above offscreen text to a black display screen
cgflip(0,0,0);          
% Waits until participant makes a keypress
waitkeydown(inf,71);    


% Stimulus sorting (colours in words and RGB)

% Stores the words in a 4x1 cell array
Word_list = {'red','green','blue','yellow'}';
% Converts the Word_list variable into character array, to enable it to be used by preparestring later in the script
% e.g. word_list_string(1,:) = 'red'
Word_list_string = char(Word_list);

% Stores R G B values for the four colours, red, green, blue and yellow in a 4x3 matrix
RGB_colours = [1 0 0; 0 1 0; 0 0 1; 1 1 0];

% Gives an enumeration of all the possible conditions
condMatrixBase = [repmat([1 2 3 4], 1, 4); sort(repmat([1 2 3 4], 1, 4))];     
% Sets the number of trials per condition to 1
trialsPerCondition = 1;
% Creates a conditions matrix based on the number of trials per condition
% The number of trials here will be 16, based on the size of the condition matrix (see above).
condMatrix = repmat(condMatrixBase, 1, trialsPerCondition);
[~, numTrials] = size(condMatrix);

% I adapted from PeterScarfe.com Stroopdemo PsychToolbox example: shuffler = Shuffle(1:numTrials)
% https://uk.mathworks.com/matlabcentral/fileexchange/27076-shuffle
shuffler = randperm(numTrials);
% Creates a randomised condition matrix
condMatrixShuffled = condMatrix(:, shuffler);

% Make a response matrix

% Creates a 6-column matrix which will record (1) colour word presented, (2) colour ink
% written in, (3) key responded with, (4) time stimulus presented, (5) time response made, and (6)calculated RT
respMat = nan(numTrials, 6);

% Main program loop

% Sets the text style to Arial, size 40
settextstyle('Arial',40);
% Draws a fixation cross in display buffer 2
preparestring('+',2);           

% In this case, the for loop will run though each of trials number 1-16
for trial = 1:numTrials

    % Brings up the word condition code (1-4) at the appropriate row (trial number) in the word condition column of the condMatrix
    wordNum = condMatrixShuffled(1,trial);   
    % Brings up the ink colour condition code (1-4) at the appropriate row trial number) in the colour condition column of the condMatrix
    colourNum = condMatrixShuffled(2,trial);              

    theWord = Word_list_string(wordNum,:,1);
    theColour = RGB_colours(colourNum,:);
    
    logstring(wordNum);
    logstring(colourNum);
    
    % Took inspiration from the Vision Labs Stroop example cogent script
    % Translates colour variables into the three R G B values, so that they can be used by preparestring (see below)
    R = theColour(1,1);      
    G = theColour(1,2);
    B = theColour(1,3);
    
    % Displays the fixation point (stored in buffer 2) and waits 1000ms
    drawpict(2);
    wait(1000);
          
    % Draws the word into display buffer 1
    % Clears the previous word before displaying the current word
    clearpict(1)                
    settextstyle('Arial',60);  
    % Sets the colour of the word, using the R G B values stored
    setforecolour(R,G,B);
    % Prepares the word
    preparestring(theWord,1);   
    clearkeys
    
    % Displays the word stored in buffer 1
    drawpict(1)
    
    % Records the time at which word is presented
    t0 = time;            
    logstring(t0);   
    
    clearkeys;
     
    readkeys;
    waitkeydown(inf)
    logkeys;
    
    % Check key press and calculate RT
    % keyout is the key pressed, t is the time at which it is pressed, and n is the number of key presses
    [keyout,t,n] = getkeydown;
    
    % If a (single) key is pressed
    if n == 1
        % the assign the that key to the response
        response = keyout(1);  
        % To calculate reaction time, the time the word was presented is subtracted from the time the key was pressed
        RT = t(1) - t0;       
    
    % Else the respose will be zero
    else response = 0          
    end
    
    % These if, elseif statements change the default key codes for the assigned key responses to a more meaningful number, based on the word-colour condition code
    % If a key other than an assigned key ('r', 'g', 'b' or 'y') is pressed, then the response is recorded as 0 to indicate an error.
    if response == 18          
       response = 1;
    elseif response == 7
       response = 2;
    elseif response == 2
       response = 3;
    elseif response == 25
       response = 4;
    else response = 0;  
        % Add these lines if you want to disgard the timing and RT data for key presses other than the above.
        % t0 = 0;                 
        % t(1) = 0;
        % RT = 0;
    end
    
    % Add these line if you want to disgard timing and RT data for incorrect responses.
    % if colourNum ~= response
        % t0 = 0;
        % t(1) = 0;
        % RT = 0;
    % end
    
    addresults(wordNum,colourNum,response,t0,t(1),RT);
    
    % Record the trial data into data matrix created earlier in script, above
    respMat(trial,1) = wordNum;
    respMat(trial,2) = colourNum;
    respMat(trial,3) = response;
    respMat(trial,4) = t0;
    respMat(trial,5) = t(1);
    respMat(trial,6) = RT;
        
    % Used the array2table function tp add column headings to my results matrix, as per below syntax: 
    % https://uk.mathworks.com/help/matlab/ref/array2table.html
    % resultsTable = array2table(respMat,'VariableNames',{'wordNum','colourNum','response','RT'});
        
end
    
% Thank you screen!

drawpict(3);
wait(3000);
clearpict;
% Change the pen colour, i.e. white
cgpencol(1,1,1)
% Change the font and size, i.e. Arial, size 30
cgfont('Arial',30)
cgtext('Thank you!',0,50);
cgtext('Press the space key to exit',0,0);
% Copies the above offscreen text to a black display screen
cgflip(0,0,0);
% Waits until participant makes a keypress
waitkeydown(inf,71);
drawpict(3);

% Converts array to table, creating a headed results table
% Output intentionally not suppressed
resultsTable = array2table(respMat,'VariableNames',{'wordNum','colourNum','response','t0','t1','RT'})

% Saves workspace data into a .mat file using the participant ID and name, in format '[participant ID]_[participant initials]_data_stroop'
save(sprintf('%d_%s_data_stroop',Participant_ID,Participant_name))

% End program
   
stop_cogent
