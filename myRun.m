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
        X = [];
        
        fid = fopen(strcat(dir_test, '/', files(i).name));
        chr = fscanf(fid,'%c');
        tmp = textscan(chr, '%s');
        arr = tmp{1};
        fclose(fid);
        
        mfcc_files = dir(strcat(speaker_data_path,'*.mfcc'));
        for j=1:length(mfcc_files)
            mfcc_file = load(strcat(speaker_data_path,mfcc_files(j).name));
            X = [X;mfcc_file];
        end
        
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
    end
end

disp(correct/incorrect+correct);