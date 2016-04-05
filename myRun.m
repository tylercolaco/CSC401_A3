%dir_train = '/u/cs401/speechdata/Testing';
dir_test = 'Testing';
files = dir(strcat(dir_test,'/*.phn'));
mfccfiles = dir(strcat(dir_test,'/*.mfcc'));
names = {files.name};

% Loop through all test, find top 5 highest likelihoods
hmms = struct();
max_ll = -1000; %something largely negative
correct = 0;
incorrect = 0;
fields = fieldnames(hmmsAfterTrain);
%for i=1:length(files)
for i=1:2
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        X = load(strcat(dir_test, '/', mfcc_files(i).name));
        fid = fopen(strcat(dir_test, '/', files(i).name));
        disp(phn_files(i).name);
        disp(mfcc_files(i).name);
        chr = fscanf(fid,'%c');
        tmp = textscan(chr, '%s');
        arr = tmp{1};
        fclose(fid);

        for k=1:length(arr)/3
            strt = str2num(arr{k*3-2})/128+1;
            finish = str2num(arr{k*3-1})/128-1;
            tocompare = [];
            for row=strt:finish
                if(row < length(X))
                    tocompare = [tocompare X(row,:)'];
                end
            end
            max_ll = -1000;
            for j=1:numel(fields)
                ll = loglikHMM(hmmsAfterTrain.(fields{j}), tocompare);
                if(ll > max_ll)
                    %disp(guess);
                    %disp(fields{i});
                    %disp(ll);
                    max_ll = ll;
                    guess = fields{j};
                end
            end
            if(strcmp(guess, 'sil'))
                guess = 'h#';
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
    end
end

disp(correct/incorrect+correct);