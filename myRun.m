dir_test = '/u/cs401/speechdata/Testing';
%dir_test = 'Testing';

%add code folder to path
addpath(genpath('/u/cs401/A3_ASR/code'));

files = dir(strcat(dir_test,'/*.phn'));
mfccfiles = dir(strcat(dir_test,'/*.mfcc'));
names = {files.name};

% Loop through all test, find top 5 highest likelihoods
hmms = struct();
max_ll = -1000; %something largely negative
correct = 0;
incorrect = 0;
%dim = 7; %should be defined already by myTrain
dim = hmmsAfterTrain.sil.node_sizes_slice(3);
fields = fieldnames(hmmsAfterTrain);
for i=1:length(files)
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        X = load(strcat(dir_test, '/', mfccfiles(i).name));
        fid = fopen(strcat(dir_test, '/', files(i).name));
        disp(files(i).name);
        disp(mfccfiles(i).name);
        chr = fscanf(fid,'%c');
        tmp = textscan(chr, '%s');
        arr = tmp{1};
        fclose(fid);

        for k=1:length(arr)/3
            strt = str2num(arr{k*3-2})/128+1;
            finish = str2num(arr{k*3-1})/128+1;
            tocompare = [];
            for row=strt:finish
                if(row < length(X)+1)
                    tocompare = [tocompare X(row,1:dim)'];
                end
            end
            ll = zeros(numel(fields),1);
            for j=1:numel(fields)
                ll(j) = loglikHMM(hmmsAfterTrain.(fields{j}), tocompare);
            end
            [res, ind] = sortrows(ll, -1);
            %find highest ll
            guess = fields{ind(1)};
        
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
    disp(correct/(incorrect+correct));
end
disp(correct/(incorrect+correct));