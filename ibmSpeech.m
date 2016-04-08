
username = 'a7a3e2fc-316f-45a1-af3f-b0ab909840e7';
password = 'wazCQew0JYEO';
url = 'https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true';
fn_speechToText = '4.1translations.txt';
fn_textToSpeech = '4.2translations.txt';

%add code folder to path
addpath(genpath('/u/cs401/A3_ASR/code'));

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
disp('Scores for 4.1');
[SE, IE, DE, LEV_DIST] = Levenshtein(fn_speechToText,'Testing');




%%% Section 4.3 %%%%


% {
%   "credentials": {
%     "url": "https://stream.watsonplatform.net/text-to-speech/api",
%     "password": "WJHyP0nsCrbj",
%     "username": "1e9866fa-c726-42a6-8a01-a139195e9cbd"
%   }
% }

%if Lev dist file exists
if(~exist(fn_textToSpeech,'file'))
   
    fileID = fopen(fn_textToSpeech,'a');
    %create audio file for each text + translate
    for i=1:30
        %Credentials for text -> Speech
        username = '1e9866fa-c726-42a6-8a01-a139195e9cbd';
        password = 'WJHyP0nsCrbj';
        baseUrl = 'https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize?voice=';

        flacName = sprintf('IBM_%d.flac',i);

        %read classified speaker
        fileLikName = sprintf('unkn_%d.lik',i);
        fileLik = fopen(fileLikName);
        [~] = fgets(fileLik);
        gender = fgets(fileLik);
        
        %check if male or female 
        if (strcmp(gender(1),'M'))
            %Male Voice Synthesizer
            url = strcat(baseUrl,'en-US_MichaelVoice&text=');
        else
            %Female Voice Synthesizer
            url = strcat(baseUrl,'en-US_LisaVoice&text=');
        end
        %Prepare text to add to url
        fileTextName = sprintf('Testing/unkn_%d.txt',i);
        fileText = fopen(fileTextName);
        text = fgets(fileText);

        %remove punctuation
        text = regexprep(text, '[,\:\;\.\?!'']','');
        text = text(9:length(text));

        %escape text
        text = urlencode(text);

        %Add to URL
        url = strcat(url,text);

        %Check if flac exists
        if(~exist(flacName,'file'))
            %send request to get flac file
            [~, ~] = unix(sprintf('env LD_LIBRARY_PATH='''' curl -u ''%s'':''%s'' -X GET --header %cAccept: audio/flac%c   %c%s%c > %s',username,password,'"','"','"',url,'"',flacName));
        end
        %Credentials for Speech -> text 

        username = 'a7a3e2fc-316f-45a1-af3f-b0ab909840e7';
        password = 'wazCQew0JYEO';
        url = 'https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true';

        %Translate Data
        %Send request to IBM
        [status, result] = unix(sprintf('env LD_LIBRARY_PATH='''' curl -u ''%s'':''%s'' -X POST --header %cContent-Type: audio/flac%c --header %cTransfer-Encoding: chunked%c --data-binary @%s %c%s%c',username,password,'"','"','"','"',flacName,'"',url,'"'));

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
disp('Scores for 4.2');
[SE, IE, DE, LEV_DIST] = Levenshtein(fn_textToSpeech,'Testing');


