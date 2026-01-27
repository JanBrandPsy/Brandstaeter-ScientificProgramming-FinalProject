%Plan: Subliminale Cueiung Task (nach Schoeberl et al., 2014)
%Erstmal Stimuli machen: Fixationskreuz, Cue links oder rechts weißer Kreis, bunte rotierte Landoltringe in 3 weißen Kreisen
% mit random vorsorgen was alles randomisiert wird an reizen
%TrialLoop: Fixation, Blankscreen 700ms, Cue 16ms oder nix, Target und Distraktoren, Reaktion aufnehmen, Cue visibility assessment, ITI
%optimieren der timings wie in letzter UE-Einheit

%Basics
Screen('Preference', 'SkipSyncTests', 1); 
myScreen = 0;
myBackgroundColour = [61 61 61];
myWindow = Screen('OpenWindow',myScreen, myBackgroundColour, [0 0 1920 1080]);
%myWindow = Screen('OpenWindow',myScreen, myBackgroundColour, [0 0 1280 720]);
Screen('BlendFunction', myWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
VPID = '1';
nTrials = 2;
results = struct('VPID', '', 'CuePosition','', 'TargetPosition','','RT', [],'TargetRotation','', 'Response', '', 'CueVisResp', '');

%Fixationskreuz definieren
fixCross = ones(50, 50)*61; 
fixCross(23:27,:)=0;
fixCross(:,23:27)=0;
fixcrossTexture = Screen('MakeTexture',myWindow,fixCross);

%Cue an sich ist einfach Screen('FrameOval')

%LandoltC
% Plan: ich mach nen Kreis 
% dann höhle ich ihn mit nem weiteren kleineren Kreis aus
% dann schneid ich die Öffnung je nach Rotation rein 
% und packe die jeweils in 4 Texturen
% im Trial dann bei DrawTexture mit [modulateColor] die Farbe anpassen

%Danke Matlabhilfecenter 
[xx yy] = meshgrid([-110:110],[-110:110]); %meshgrid macht ein Koordinatensystem
AussenKreis = zeros(size(xx)); %genauso große Bitmap 
AussenKreis((xx.^2+yy.^2)<100^2)=1; %% setze die Pixel 1, deren Abstand vom Ursprung innerhalb des Kreis Radius ist
[xx2 yy2] = meshgrid([-110:110],[-110:110]);
InnenKreis = zeros(size(xx2));
InnenKreis((xx2.^2+yy2.^2)<80^2)=1;   
Ring1 = AussenKreis - InnenKreis; %großer Kreis minus kleiner Kreis macht Ring

% LandoltOben
Ring1((yy < 10) & (abs(xx) < 110/2)) = 0; %Landolt Öffnung reinmachen 
% RGBA-Bitmap damit Ring sichtbar, aber Rest transparent und [modulateColor] überhaupt anständig klappt
%also da wo Ring ist jeden Farbkanal 255 setzen
img1RGBA = zeros([size(Ring1) 4]);
img1RGBA(:,:,1) = Ring1 * 255; % R
img1RGBA(:,:,2) = Ring1 * 255; % G
img1RGBA(:,:,3) = Ring1 * 255; % B
img1RGBA(:,:,4) = Ring1 * 255; % A
LandoltOben = Screen('MakeTexture',myWindow,img1RGBA);

% LandoltUnten
Ring2 = AussenKreis - InnenKreis;
Ring2((yy > 10) & (abs(xx) < 110/2)) = 0;
img2RGBA = zeros([size(Ring2) 4]);
img2RGBA(:,:,1) = Ring2 * 255; 
img2RGBA(:,:,2) = Ring2 * 255; 
img2RGBA(:,:,3) = Ring2 * 255; 
img2RGBA(:,:,4) = Ring2 * 255; 
LandoltUnten = Screen('MakeTexture',myWindow,img2RGBA);

% LandoltRechts
Ring3 = AussenKreis - InnenKreis;
Ring3((abs(yy) < 110/2) & (xx > 10)) = 0;
img3RGBA = zeros([size(Ring3) 4]);
img3RGBA(:,:,1) = Ring3 * 255;
img3RGBA(:,:,2) = Ring3 * 255;
img3RGBA(:,:,3) = Ring3 * 255;
img3RGBA(:,:,4) = Ring3 * 255;
LandoltRechts = Screen('MakeTexture',myWindow,img3RGBA);

% LandoltLinks
Ring4 = AussenKreis - InnenKreis;
Ring4((abs(yy) < 110/2) & (xx < 10)) = 0;
img4RGBA = zeros([size(Ring4) 4]);
img4RGBA(:,:,1) = Ring4 * 255;
img4RGBA(:,:,2) = Ring4 * 255;
img4RGBA(:,:,3) = Ring4 * 255;
img4RGBA(:,:,4) = Ring4 * 255;
LandoltLinks = Screen('MakeTexture',myWindow,img4RGBA);

%Instruktionen
Instruktionen = ['Gib mit den Pfeiltasten die Orientierung des Blauen Reizes an'];
Instruktionen2 = ['Drücke eine Taste um zu beginnen'];

%Cue Visibility Assessment Instruktionen 
Visibility = ['Wo war der Cue?'];
Visibility2 = ['Drücke die linke Pfeiltaste für links '];
Visibility3 = ['Drücke die rechte Pfeiltaste für rechts'];

%Cue-Kreis-Positionen
LinksCue = [540 420 780 660]; MitteCue = [840 420 1080 660]; RechtsCue = [1140 420 1380 660];
%Cue links, rechts, gar nicht
CUE_LINKS = 1; CUE_RECHTS = 2; CUE_NO = 3;
CueDict = containers.Map('KeyType','double','ValueType','any');
CueDict(CUE_LINKS) = LinksCue;
CueDict(CUE_RECHTS) = RechtsCue;
CueDict(CUE_NO) = [];
rCue = randi(3,1,nTrials); %sollte man eher balancieren

%Landolt-Positionen
LandoltPosLinks = [550 430 770 650]; LandoltPosMitte = [850 430 1070 650]; LandoltPosRechts = [1150 430 1370 650];
LPOS_LINKS = 1; LPOS_MITTE = 2; LPOS_RECHTS = 3;
LPosDict = containers.Map('KeyType','double','ValueType','any');
LPosDict(LPOS_LINKS) = LandoltPosLinks;
LPosDict(LPOS_MITTE) = LandoltPosMitte;
LPosDict(LPOS_RECHTS) = LandoltPosRechts;
rPos = zeros(3,nTrials);
% Target-Position (1 = links, 3 = rechts)
targetPosVec = repmat([LPOS_LINKS LPOS_RECHTS], 1, nTrials/2);
targetPosVec = targetPosVec(randperm(nTrials));

for i = 1:nTrials
    rPos(1,i) = targetPosVec(i);                 % Target
    otherPos  = [LPOS_LINKS LPOS_MITTE LPOS_RECHTS];
    otherPos(otherPos == targetPosVec(i)) = []; % remove target
    rPos(2:3,i) = otherPos;                     % Distraktoren
end


%Rotationen
%TargetRotation oben, unten, rechts links (random weil inhaltlich egal?)
%DistraktorenRotation inhaltlich egal also random
LROT_OBEN = 1; LROT_UNTEN = 2; LROT_RECHTS = 3; LROT_LINKS = 4;
LRotDict = containers.Map('KeyType','double','ValueType','any');
LRotDict(LROT_OBEN) = LandoltOben;
LRotDict(LROT_UNTEN) = LandoltUnten;
LRotDict(LROT_RECHTS) = LandoltRechts;
LRotDict(LROT_LINKS) = LandoltLinks;
rRot = randi(4, 3, nTrials);


%Farben
%TargetColour Blau, DistraktorColour rot und grün
Rot = [255 0 0]; Grun = [0 255 0]; Blau = [0 0 255];
ColourDict = containers.Map('KeyType','double','ValueType','any');
TARGET = 1; ROT = 2; GRUN = 3;
ColourDict(TARGET) = Blau;
ColourDict(ROT) = Rot;
ColourDict(GRUN) = Grun;
rColour = zeros(2,nTrials);
for j = 1:nTrials
    if rand > 0.5
       rColour(1,j) = 2;
       rColour(2,j) = 3;
    else 
        rColour(1,j) = 3;
        rColour(2,j) = 2;
    end
end

%Labels weil man Dictionary Keys nicht in results packen kann
CueLabel = containers.Map('KeyType','double','ValueType','char');
CueLabel(1) = 'left';
CueLabel(2) = 'right';
CueLabel(3) = 'none';

PosLabel = containers.Map('KeyType','double','ValueType','char');
PosLabel(1) = 'left';
PosLabel(2) = 'middle';
PosLabel(3) = 'right';

RotLabel = containers.Map('KeyType','double','ValueType','char');
RotLabel(1) = 'up';
RotLabel(2) = 'down';
RotLabel(3) = 'right';
RotLabel(4) = 'left';

ColourLabel = containers.Map('KeyType','double','ValueType','char');
ColourLabel(1) = 'blue';
ColourLabel(2)= 'red';
ColourLabel(3) = 'green';


%Timings für Screen('Flip'[,when])
tFix = 0.5; %FixCross
tBlankPre = 0.7; %Blank Screen danach
tCue = 0.016; %bei meinem 60Hz Bildschirm ist 16ms doch ziemlich genau 1 Frame lang, fehleranfällig?
tTarget = 0.4; %Target
tBlankPost = 1; %blankScreen Reagier Zeit
ITI = rand(1,nTrials);
rt = NaN;
respKey = NaN;

Screen('DrawText', myWindow, Instruktionen, [600], [420], [200 200 200]);
Screen('DrawText', myWindow, Instruktionen2, [600], [620], [200 200 200]);
Screen('Flip', myWindow);
KbWait;

%===Trial Loop===
%Fixcross, Blankscreen, Cue in einen von 3 Zuständen, t0(3 Kreise + random farbige und rotierte Landolt),Response = t1, abspeichern, visibilityabfrage?, nächster Trial
for i = 1:nTrials;

rt = NaN;
respKey = 'NA';
respKey2 = 'NA';
%--FixCross--

Screen('DrawTexture', myWindow, fixcrossTexture);
tFixOnset = Screen('Flip', myWindow);

%--PreBlank--

Screen('FillRect', myWindow, myBackgroundColour);
tPreBlankOnset = Screen('Flip', myWindow, tFixOnset+tFix);

%--Cue--

if rCue(i) ~= 3
   Screen('FrameOval', myWindow, [250 250 250], CueDict(rCue(i)), 10);
else
    Screen('FillRect', myWindow, myBackgroundColour);
end
tCueOnset = Screen('Flip', myWindow, tPreBlankOnset + tBlankPre);

%--Target--
Screen('FrameOval', myWindow, [250 250 250], LinksCue, 10);
Screen('FrameOval', myWindow, [250 250 250], MitteCue, 10);
Screen('FrameOval', myWindow, [250 250 250], RechtsCue, 10);

Screen('DrawTexture', myWindow, LRotDict(rRot(1,i)), [], LPosDict(rPos(1,i)), [], [], [], ColourDict(TARGET));
Screen('DrawTexture', myWindow, LRotDict(rRot(2,i)), [], LPosDict(rPos(2,i)), [], [], [], ColourDict(rColour(1,i)));
Screen('DrawTexture', myWindow, LRotDict(rRot(3,i)), [], LPosDict(rPos(3,i)), [], [], [], ColourDict(rColour(2,i)));

tTargetOnset = Screen('Flip', myWindow, tCueOnset + tCue);
%--PostBlank und Response--
Screen('FillRect', myWindow, myBackgroundColour);
tPostBlankOnset = Screen('Flip', myWindow, tTargetOnset + tTarget);

ResponseWindow = tTargetOnset + tTarget + tBlankPost;
while GetSecs < ResponseWindow
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        rt = secs - tTargetOnset
        respKey = KbName(find(keyCode,1))
        break
    end
end
RotLabel(rRot(1,i))
%--Cue Visibility Abfrage--
if rCue(i) ~= 3
    KbReleaseWait();
    Screen('DrawText', myWindow, Visibility, [600], [420], [200 200 200]);
    Screen('DrawText', myWindow, Visibility2, [600], [520], [200 200 200]);
    Screen('DrawText', myWindow, Visibility3, [600], [620], [200 200 200]);
    Screen('Flip', myWindow);
    [~, ~, keyCode] = KbWait;
    respKey2 = KbName(find(keyCode,1));
end
WaitSecs(ITI(i));

%--Abspeichern--
results(i).VPID = VPID;
results(i).CuePosition = CueLabel(rCue(i));
results(i).TargetPosition = PosLabel(rPos(1,i));
results(i).RT = rt;
results(i).TargetRotation = RotLabel(rRot(1,i));
results(i).Response = respKey;
if rCue(i) ~= 3
    results(i).CueVisResp = respKey2;
else
    results(i).CueVisResp = 'NA';
end
end
Abschluss = ['Vielen Dank fürs Mitmachen!'];
Screen('DrawText', myWindow, Abschluss, [600], [420], [200 200 200]);
Screen('Flip', myWindow);
WaitSecs(3);

Screen('CloseAll')

resultsname = ['Results\sub-' VPID '_task-subliminalcueing_beh.csv'];
writetable(struct2table(results),resultsname)

