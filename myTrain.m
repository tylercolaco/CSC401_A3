%dir_train = '/u/cs401/speechdata/Testing';
dir_train = 'Training';
files = dir(dir_train);

count = 0;
hmms = struct();
for i=1:length(files)
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        count = count + 1;
        speaker = files(i).name;
        X = [];
        speaker_data_path = strcat(dir_train,'/',speaker,'/');
        %Create struct for each speaker
        gmms{count} = struct();
        gmms{count}.name = speaker;
        %Get the phn files from directories (used to train gausians)
        phn_files = dir(strcat(speaker_data_path,'*.phn'));
        for j=1:length(phn_files)
            fid = fopen(strcat(speaker_data_path,phn_files(j).name));
            chr = fscanf(fid,'%c');
            tmp = textscan(chr, '%s');
            arr = tmp{1};
            for k=1:(length(arr)/3)
                if(strcmp(arr(k*3),'h#'))
                    %check if field already
                    if(isfield(hmms, 'sil'))
                        hmms.('sil'){1} = [hmms.('sil'){1}, [str2num(arr{k*3-2}), str2num(arr{k*3-1})]];
                    else 
                        hmms.('sil') = {[str2num(arr{k*3-2}), str2num(arr{k*3-1})]};
                    end
                else
                    if(isfield(hmms, arr{k*3}))
                        hmms.(arr{k*3}){1} = [hmms.(arr{k*3}){1}, [str2num(arr{k*3-2}), str2num(arr{k*3-1})]];
                    else 
                        hmms.(arr{k*3}) = {[str2num(arr{k*3-2}), str2num(arr{k*3-1})]};
                    end
                end
            end
            fclose(fid);
            %disp(tmp);
            %phn_file = load(strcat(speaker_data_path,phn_files(j).name));
            %X = [X;mfcc_file];
        end
        %disp(X);
    end
end

%first need to make a model for each phoneme

%next go through each test sequence and determine log likelihood.
%data = 1;
hmm = initHMM(hmms.sil, 8);