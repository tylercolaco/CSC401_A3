function [SE, IE, DE, LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses


%Load the hypothesis
hyp = fopen(hypothesis);
test = fgets(hyp);
lineNo = 1;
SE = 0;
IE = 0;
DE = 0;
LEV_DIST = 0;
REF_LEN_SUM = 0;

%  ref = 'how to recognize speech';
%  test = 'how to wreck a nice beach';

    while (test ~= -1)
        tempSub = 0;
        tempIns = 0;
        tempDel = 0;
        %Get the corresponding file and Load Sentence
        fileName = sprintf('unkn_%d.txt',lineNo);
        refFile = fopen(strcat(annotation_dir, '/',fileName));
        ref = fgets(refFile);
        
        %String Split
        ref = strsplit(' ',ref);
        test = strsplit(' ',test);
        %Remove first two elements
        ref = ref(3:length(ref));
        test = test(3:length(test));
        
        n = length(ref);
        m = length(test);
        R = ones(n+1,m+1) * Inf;
        R(1,1) = 0;
        % Compute Matrix
        for i=2:n+1
            for j=2:m+1
                %Check for Match
                    if strcmp(ref(i-1),test(j-1))
                        match = 0;
                    else
                        match = 1;
                    end
                    R(i,j) = min([R(i-1,j)+1, R(i-1,j-1)+match,R(i,j-1)+1]);                 
            end
        end
        
        %Trace back to determine SE/IE/DE
        dist = R(n+1,m+1);
        i = n+1;
        j = m+1;
        while (dist ~= 0)
            Min = min([R(i,j-1),R(i-1,j-1),R(i-1,j)]);

            if Min == R(i,j-1)
                %Insertion 
                j = j-1;
                if Min < dist
                    tempIns = tempIns +1;
                end

            elseif Min == R(i-1,j-1)
                %Substitution
                i=i-1;
                j=j-1;
                if Min < dist
                    tempSub = tempSub +1;
                end        
            else %min == R(i-1,j)
                %Deletion
                i=i-1;
                if Min < dist
                    tempDel = tempDel+1;
                end     
            end
            %Update value
            dist = Min;
        end
        %Print out for each line
        
%         disp(['Line No: ' num2str(lineNo)]);
%         disp(['SE = ' num2str(tempSub/n)]);
%         disp(['IE = ' num2str(tempIns/n)]);
%         disp(['DE = ' num2str(tempDel/n)]);
%         total = (tempSub+tempIns+tempDel)/n;
%         disp(['Total Error = ' num2str(total)]);
        SE = SE + tempSub;
        IE = IE + tempIns;
        DE = DE + tempDel;
        REF_LEN_SUM = REF_LEN_SUM + n;
        test= fgets(hyp);
        lineNo = lineNo + 1;
    end

    SE = SE/REF_LEN_SUM;
    IE = IE/REF_LEN_SUM;
    DE = DE/REF_LEN_SUM;
    LEV_DIST = SE + IE +DE;
    
%     disp(['Total SE: ' num2str(SE)]);
%     disp(['Total IE: ' num2str(IE)]);
%     disp(['Total DE: ' num2str(DE)]);
%     disp(['Total Error: ' num2str(LEV_DIST)]);

return