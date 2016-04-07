function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses


% %Load the hypothesis
% hyp = fopen(hypothesis);
% line = fgets(hyp);
% references = dir(strcat(annotation_dir,'unkn*.txt'));

%line = strsplit(line,' ');

% while (line ~= -1)
%     line= fgets(hyp)
% end
disp('WOO');
SE = 0;

LEV_DIST = 1;

ref = 'how to recognize speech';
test = 'how to wreck a nice beach';
ref = strsplit(ref,' ');
test = strsplit(test,' ');
n = length(ref);
m = length(test);
R = ones(n+1,m+1) * Inf;
R(1,1) = 0;
for i=2:n+1
    for j=2:m+1
        %Check for Match
            if strcmp(ref(i-1),test(j-1))
                match = 0;
            else
                match = 1;
                if (i == j)     
                    SE = SE + 1;
                end
            end
            R(i,j) = min([R(i-1,j)+1, R(i-1,j-1)+match,R(i,j-1)+1]);                 
    end
end
%Determine Insertion and Deletion Errors
if (n < m)
    IE = m-n;
    DE = 0;
elseif (m < n)
    IE = 0;
    DE = n-m;
else
    IE = 0;
    DE = 0;   
end
    
return