function result = gmmClassify(dir_test, dir_train, theta)
files = dir(strcat(dir_test,'/*.mfcc'));

%to get each data file load
M = 8;
eps = 0.1;
% Get trained models
%gmms = gmmTrain(dir_train, 100, eps, M);
gmms = theta;
%test_files = dir('/u/cs401/speechdata/Testing/unkn_*.mfcc');
test_files = files;

% Get test files 
test_names = {test_files.name};

% Go through all test files, find the max, and output to the appropriate file
for i=1:size(test_names, 2)
  % Load files
  test_mfcc = load(strcat(dir_test, '/', test_names{i}));
  % Get each likelihood
  liks = zeros(1,size(gmms,2));
  for j=1:size(gmms,2)
	ll = computeLl(M, test_mfcc, gmms{j});
	liks(j) = ll;
  end
  % Find top hits, print to file
  [res, ind] = sortrows(liks', -1);
  %get test number and convert to string
  tmp = regexp(test_names{i},'[\d]+', 'match');
  s = sprintf('%s', tmp{:});
  fn = strcat('unkn_', s, '.lik');
  fileID = fopen(fn, 'w');
  for j=1:5
	  fprintf(fileID, '%2.4f\t%s\n', res(j), gmms{ind(j)}.name);
  end
  fclose('all');
end
result = 1;
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
    ll = sum(log(wb), 2) / T;
            
return;
end
