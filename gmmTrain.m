function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture
%gmms is a cell array of structs
gmms = {};
%initilaize theta
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
        %Get the mfcc files from directories (used to train gausians)
        
        mfcc_files = dir(strcat(speaker_data_path,'*.mfcc'));
        for j=1:length(mfcc_files)
            mfcc_file = load(strcat(speaker_data_path,mfcc_files(j).name));
            X = [X;mfcc_file];
        end
        %Initialize Theta
        theta = init_gaussians(M,X);
        
        %Set break conditions and train
        k = 0;
        prev_L = -Inf;
        improvement = Inf;
        %Log space computation
        %log(b) = log(num) - log(den)
        %log(num) = -1/2*sum[(data-mean)^2/cov)]
        %log(den) = d/2*log(2pi) + 1/2*sum(covariance)
        
        while k<=max_iter && improvement >= epsilon
            %L = compute(theta, X);
            %compute b in log domain
            %T is number of data vectors
            T = size(X,1);
            %D is number of features per data vector
            D = size(X,2);
            
            b_num = zeros(T,M);
            %Required for the denominator of b
            logCovSum = zeros(T,M);
            
            b = computeB(M,X,theta);
            
            L = theta.w * exp(b');
            logL = sum(log(L),2);
            
            postProb_num = repmat(theta.w,T,1) .* exp(b);
            postProb_den = repmat(sum(postProb_num,2),1,M);
            postProb = postProb_num ./ postProb_den;
            
           % disp(theta.mean);
            %Update Terms
            sumpostProb = sum(postProb);
            
            %Update Weights
            theta.w = sumpostProb / T;
            
            %Update Means
            theta.mean = postProb' * X ./ repmat(sumpostProb',1,D);
            theta.mean = theta.mean';
            
            %Update Covariance
            theta.cov = postProb' * (X.^2) ./ repmat(sumpostProb',1,D);
            theta.cov = theta.cov' - (theta.mean).^2;
            cov = zeros(D,D,M);
            for j =1:M
                cov(:,:,j) = diag(theta.cov(:,j));
            end
            theta.cov = cov;

            
            %theta = update(theta, X, L);
            improvement = logL-prev_L;
            prev_L = logL;
            k = k+1;
        end 
        gmms{count}.weights = theta.w;
        gmms{count}.means = theta.mean;
        gmms{count}.cov = theta.cov;
    end
end
 
function theta = init_gaussians(M, X)
    theta = struct();
    %Set weights to 1/M for each GMM
    w = 1/M * ones(1, M);
    
    %Pick the middle value to use as initial Means
    middle = size(X,1)/2;
    
    mean = X(middle:middle+M-1,:);
    %was MXD make it DxM
    mean = mean';
    
    %Assume covariance is independant (all ones)
    %DxD identity
    A = eye(size(X,2));
    %Span it M times
    cov = repmat(A,[1,1,M]);

    theta.w = w;
    theta.mean = mean; 
    theta.cov = cov;
return;

function b = computeB(M,X,theta)

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
        meansRep = repmat(theta.mean(j,:),T,1);
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
            
return;



