%dir_train = '/u/cs401/speechdata/Training';
dir_train = 'Training';
files = dir(dir_train);

count = 0;
data = struct();
hmms = struct();
hmmsAfterTrain = struct();
%jsut go through 3 files for now
%for i=1:length(files)
for i=1:length(files)
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        count = count + 1;
        speaker = files(i).name;
        X = [];
        speaker_data_path = strcat(dir_train,'/',speaker,'/');
        %Get the phn files from directories (used to train gausians)
        phn_files = dir(strcat(speaker_data_path,'*.phn'));
        mfcc_files = dir(strcat(speaker_data_path,'*.mfcc'));
        for j=1:length(mfcc_files)
            mfcc_file = load(strcat(speaker_data_path,mfcc_files(j).name));
            X = [X;mfcc_file];
        end
        for j=1:length(phn_files)
            fidphn = fopen(strcat(speaker_data_path,phn_files(j).name));
            chr = fscanf(fidphn,'%c');
            tmp = textscan(chr, '%s');
            fclose(fidphn);
            arr = tmp{1};
            for k=1:(length(arr)/3)
                strt = str2num(arr{k*3-2})/128+1;
                finish = str2num(arr{k*3-1})/128;
                if(strcmp(arr(k*3),'h#'))
                    for row=strt:finish
                        %check if field already
                        if(isfield(data, 'sil'))
                            data.('sil'){length(data.('sil'))+1} = X(row,:);
                        else 
                            data.('sil'){1} = X(row,:);
                        end
                    end
                else
                    for row=strt:finish
                        %check if field already
                        if(isfield(data, arr(k*3)))
                            data.(arr{k*3}){length(data.(arr{k*3}))+1} = X(row,:);
                        else 
                            data.(arr{k*3}){1} = X(row,:);
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
  hmms.(fields{i}) = initHMM(data.(fields{i}), 1);
  %train the HMM given the data for each phoneme
  hmmsAfterTrain.(fields{i}) = trainHMM(hmms.(fields{i}), data.(fields{i}));
end

%next go through each test sequence and determine log likelihood.

%data = 1;
