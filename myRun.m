%dir_train = '/u/cs401/speechdata/Testing';
dir_test = 'Testing';
files = dir(strcat(dir_test,'/*.phn'));
names = {files.name};

% Loop through all test, find top 5 highest likelihoods
hmms = struct();
max_ll = -1000; %something largely negative
correct = 0;
incorrect = 0;
for i=1:2
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        
        count = {};
        speaker = files(i).name;
        
        fid = fopen(strcat(dir_test, '/', files(i).name));
        chr = fscanf(fid,'%c');
        tmp = textscan(chr, '%s');
        arr = tmp{1};
        disp(arr);
        
        fields = fieldnames(hmmsAfterTrain);

        for k=1:length(arr)/3
            dat = [str2num(arr{k*3-2}), str2num(arr{k*3-1})];
            max_ll = -1000;
            for j=1:numel(fields)
                ll = loglikHMM(hmmsAfterTrain.(fields{j}), dat);
                if(ll > max_ll)
                    %disp(guess);
                    %disp(fields{i});
                    %disp(ll);
                    max_ll = ll;
                    guess = fields{j};
                end
            end
            disp(guess);
            disp(arr{k*3});
            disp(strcmp(guess, arr{k*3}));
            if(strcmp(guess, arr{k*3}))
                correct = correct + 1;
            else
                incorrect = incorrect + 1;
            end
        end
        
        
%         fn = strcat('PHNunkn_', speaker, '.lik');
%         fileID = fopen(fn, 'w');
%         fid = fopen(fileID);
%         
%         for k=1:(length(arr)/3)
%             if(strcmp(arr(k*3),'h#'))
%                 %check if field already
%                 if(isfield(hmms, 'sil'))
%                     hmms.('sil'){1} = [hmms.('sil'){1}, [str2num(arr{k*3-2}), str2num(arr{k*3-1})]];
%                 else 
%                     hmms.('sil') = {[str2num(arr{k*3-2}), str2num(arr{k*3-1})]};
%                 end
%             else
%                 if(isfield(hmms, arr{k*3}))
%                     hmms.(arr{k*3}){1} = [hmms.(arr{k*3}){1}, [str2num(arr{k*3-2}), str2num(arr{k*3-1})]];
%                 else 
%                     hmms.(arr{k*3}) = {[str2num(arr{k*3-2}), str2num(arr{k*3-1})]};
%                 end
%             end
%         end
        fclose(fid);
    end
end

disp(correct/incorrect+correct);