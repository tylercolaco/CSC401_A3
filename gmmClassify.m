function result = gmmClassify(dir_test, dir_train)
files = dir(strcat(dir_test,'/*.mfcc'));

%to get each data file load
M = 8;
epsilon = 0.1;
% Get trained models
gmms = gmmTrain(dir_train, 100, epsilon, M);
%add code
addpath(genpath('/u/cs401/A3_ASR/code'));
% Get names of files 
names = {files.name};
labels = {'MMRP0', 'MPGH0', 'MKLW0', 'FSAH0', 'FVFB0', 'FJSP0', 'MTPF0', 'MRDD0', 'MRSO0', 'MKLS0', 'FETB0','FMEM0','FCJF0','MWAR0','MTJS0'};
correct = 0;
% Loop through all test, find top 5 highest likelihoods
for i=1:size(names, 2)
  % Load files
  test_mfcc = load(strcat(dir_test, '/', names{i}));
  % Get log likelihoods
  likelihoods = zeros(1,size(gmms,2));
  for j=1:size(gmms,2)
	ll = computeLl(M, test_mfcc, gmms{j});
	likelihoods(j) = ll;
  end
  % print top 5 to file
  [res, ind] = sortrows(likelihoods', -1);
  %get test number and convert to string
  tmp = regexp(names{i},'[\d]+', 'match');
  s = sprintf('%s', tmp{:});
  spknum = str2num(s);
  if(spknum<16)
      lab = labels(spknum);
      str_lab = sprintf('%s', lab{:});
      if(strcmp(str_lab,gmms{ind(1)}.name))
          correct = correct + 1;
      end
  end
  fn = strcat('unkn_', s, '.lik');
  fileID = fopen(fn, 'w');
  fprintf(fileID, 'SpeakerID\tlog likelihood\n');
  for j=1:5
	  fprintf(fileID, '%s\t\t%2.2f\n', gmms{ind(j)}.name, res(j));
  end
  fclose('all');
end
result = correct/15;
end

function ll = computeLl(M,X,theta)

    T = size(X,1);
    %D is number of features per data vector
    D = size(X,2);
    b_num = zeros(T,M);
    %Required for the denominator of b
    logCovSum = zeros(T,M);

    for j=1:D

        %mean, want it to be T x M matrix when its D x M
        %Looping through the D element
        %take mean(j,:) and repeat it T times
        meansRep = repmat(theta.means(j,:),T,1);
        %disp(meansRep);
        %data, want it to be T x M matrix when its T x D
        %Loop thorugh the D element
        %X(:,j) and repeat T times
        dataRep = repmat(X(:,j),1,M);

        %first take the difference
        delta = dataRep - meansRep;

        %square the difference
        delta = delta.^2;
        covRep = theta.cov(j,j,:);
        covRep = repmat(covRep,[1,T,1]);
        %turn into 2D matrix
        covRep = squeeze(covRep);
        %Sum to be used for denominator of b
        logCovSum = logCovSum + log(covRep);
        %disp(b_num);
        b_num = b_num + delta./covRep;

    end

    b_num = -1/2*b_num;

    %Sum of log covariances calculated in previous D loop
    %log(den) = d/2*log(2pi) + 1/2*sum(log(covariance))
    b_den = ones(T,M) * D/2 * log(2*pi) + 1/2*logCovSum;



    b = b_num - b_den;
    % Compute log likelihood
    wb = theta.weights * exp(b)';
    ll = sum(log(wb), 2);
            
return;
end