[wavedata freq] = audioread('cow.mp3');
InitializePsychSound(1);
pahandle = PsychPortAudio('Open', [], [], 2, freq, 1, 0);
PsychPortAudio('FillBuffer', pahandle, wavedata');
rep = 2;
PsychPortAudio('Start', pahandle, rep, 0)
WaitSecs(10)
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);