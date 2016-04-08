
username = 'a7a3e2fc-316f-45a1-af3f-b0ab909840e7';
password = 'wazCQew0JYEO';
url = 'https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true';
fn_speechToText = '4.1translations.txt';
fn_textToSpeech = '4.2translations.txt';

% test = strsplit('transcript',result);
% test = char(test(2));
% test = strsplit('}',test);
% test = char(test(1));
% test = strsplit('"',test);
% test = char(test(3));
% test = test(1:length(test)-1);
% %add two pieces at front to be parsed out in Levenshtein
% test = char(strcat('X Y',{' '}, test));


%If we haven't already translated the flac files
if(~exist(fn_speechToText,'file'))
    %Create text file to store results
    fileID = fopen(fn_speechToText,'a');
    %Loop through each flac
    for i=1:30
        %Send request to IBM
        [status, result] = unix(sprintf('env LD_LIBRARY_PATH='''' curl -u ''%s'':''%s'' -X POST --header %cContent-Type: audio/flac%c --header %cTransfer-Encoding: chunked%c --data-binary @Testing/unkn_%d.flac %c%s%c',username,password,'"','"','"','"',i,'"',url,'"'));
        
        %Parse the JSON to extract the first translation
        test = strsplit('transcript',result);
        test = char(test(2));
        test = strsplit('}',test);
        test = char(test(1));
        test = strsplit('"',test);
        test = char(test(3));
        test = test(1:length(test)-1);
        %add two pieces at front to be parsed out in Levenshtein
        test = char(strcat('X Y',{' '}, test));
        
        %Write to text file
        fprintf(fileID,'%s\n',test);
        
        %wait before next request
        pause(5);
    end
    fclose(fileID); 
end

%created textfile, calculate Lev score
[SE, IE, DE, LEV_DIST] = Levenshtein(fn_speechToText,'Testing');