%dir_train = '/u/cs401/speechdata/Training';
dir_train = 'Training';
files = dir(dir_train);

count = 0;
data = struct();
hmms = struct();
hmmsAfterTrain = struct();
dim = 3; %try 3 and 7
training_data = 12; %try 12 and 17
states = 1; %try 1 and 2
num_gauss = 4; %try 2 and 4
for i=1:training_data
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        count = count + 1;
        speaker = files(i).name;
        speaker_data_path = strcat(dir_train,'/',speaker,'/');
        phn_files = dir(strcat(speaker_data_path,'*.phn'));
        mfcc_files = dir(strcat(speaker_data_path,'*.mfcc'));
        %Get the phn files from directories (used to train gausians)

        for j=1:length(phn_files)
            X = load(strcat(speaker_data_path,mfcc_files(j).name));
            fidphn = fopen(strcat(speaker_data_path,phn_files(j).name));
            chr = fscanf(fidphn,'%c');
            tmp = textscan(chr, '%s');
            fclose(fidphn);
            arr = tmp{1};
            for k=1:(length(arr)/3)
                strt = str2num(arr{k*3-2})/128+1;
                finish = str2num(arr{k*3-1})/128+1;
                toadd = [];
                for row=strt:finish
                    if(row < (length(X)+1))
                        toadd = [toadd X(row,1:dim)'];
                    end
                end
                if(~isempty(toadd))
                    if(strcmp(arr(k*3),'h#'))
                        %check if field already
                        if(isfield(data, 'sil'))
                            data.('sil'){length(data.('sil'))+1} = toadd;
                        else 
                            data.('sil'){1} = toadd;
                        end
                    else
                        %check if field already
                        if(isfield(data, arr{k*3}))
                            data.(arr{k*3}){length(data.(arr{k*3}))+1} = toadd;
                        else 
                            data.(arr{k*3}){1} = toadd;
                        end
                    end
                end
            end
        end
        %disp(X);
    end
end

%first need to make a model for each phoneme
%init hmms for each phoneme
fields = fieldnames(data);

for i=1:numel(fields)
  %init the HMM given the data
  %can use 4 gaussians for all train data
  hmms.(fields{i}) = initHMM(data.(fields{i}),num_gauss, states);
  %train the HMM given the data for each phoneme
  hmmsAfterTrain.(fields{i}) = trainHMM(hmms.(fields{i}), data.(fields{i}));
end

fn = sprintf('%dgauss%ddim%dtraining%dstateshmm.mat', num_gauss,dim,training_data,states);
save(fn, 'hmmsAfterTrain');



%run script
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
disp(fn);