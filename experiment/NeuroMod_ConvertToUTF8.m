function word = NeuroMod_ConvertToUTF8(word)

% Not sure if this is exactly right...
os = computer;
if strcmp(os(1:4),'GLNX')
    % Nothing to do on Linux...
else
    word = native2unicode(word-0,'UTF-8');
end

