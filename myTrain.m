%dir_train = '/u/cs401/speechdata/Training';
dir_train = 'Training';
files = dir(dir_train);

count = 0;
data = struct();
hmms = struct();
hmmsAfterTrain = struct();
dim = 14; %try 3 and 7
training_data = 30; %try 10 and 15
states = 3; %try 1 and 2
num_gauss = 8; %try 2 and 4

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
            disp(phn_files(j).name);
            disp(mfcc_files(j).name);
            chr = fscanf(fidphn,'%c');
            tmp = textscan(chr, '%s');
            fclose(fidphn);
            arr = tmp{1};
            for k=1:(length(arr)/3)
                strt = str2num(arr{k*3-2})/128+1;
                finish = str2num(arr{k*3-1})/128+1;
                toadd = [];
                for row=strt:finish
                    if(row < length(X))
                        toadd = [toadd X(row,1:dim)'];
                    end
                end
                if(~isempty(toadd))
                    if(strcmp(arr{k*3},'h#'))
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

disp(numel(fields));
for i=1:numel(fields)
  %init the HMM given the data
  %can use 4 gaussians for all train data
  disp(fields{i});
  hmms.(fields{i}) = initHMM(data.(fields{i}));
  %train the HMM given the data for each phoneme
  hmmsAfterTrain.(fields{i}) = trainHMM(hmms.(fields{i}), data.(fields{i}));
end

fn = sprintf('%dgauss%ddim%dtraining%dstateshmm.mat', num_gauss,dim,train_data,states);
save(fn, 'hmmsAfterTrain');

%next go through each test sequence and determine log likelihood.

%data = 1;
