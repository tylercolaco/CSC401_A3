%dir_train = '/u/cs401/speechdata/Testing';
dir_train = 'Training';
files = dir(dir_train);

count = 0;
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
            fclose(fid);
            disp(chr);
            %phn_file = load(strcat(speaker_data_path,phn_files(j).name));
            %X = [X;mfcc_file];
        end
        disp(X);
    end
end
%data = 1;
%hmm = initHMM(8);