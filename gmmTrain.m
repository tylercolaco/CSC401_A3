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
%I DONT KNOW HOW TO INITILIAZE WHY GAUSSIAN WHYY
for i=1:length(files)

    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        count = count + 1;
        speaker = files(i).name;
        mfcc_data = [];
        speaker_data_path = strcat(dir_train,'/',speaker,'/');
        %Create struct for each speaker
        gmms{count} = struct();
        gmms{count}.name = speaker;
        %Get the mfcc files from directories (used to train gausians)
        
        mfcc_files = dir(strcat(speaker_data_path,'*.mfcc'));
        for j=1:length(mfcc_files)
            mfcc_file = load(strcat(speaker_data_path,mfcc_files(j).name));
            mfcc_data = [mfcc_data;mfcc_file];
        end
   
    end
end
 
i=0;
prev_L = -Inf;
improvement = Inf;
theta = init_gaussians(M);
return;

while i<=max_iter && improvement >= epsilon
    L = compute(theta, X);
    %theta = update(theta, X, L);
    improvement = L-prev_L;
    prev_L = L;
    i = i+1;
end

return;

function theta = init_gaussians(m, X)
    theta = struct();
    w = zeros(1, m);
    cov = zeros(length(X), length(X), m);
    mean = zeroes(length(X), m);
    for i=1:m
        w(i) = 1/m;
        for j=1:length(X)
            mean(j,i) = 0;
            for k=1:length(X)
                if(k==j)
                    cov(k,j,i) = 1;
                end
            end
        end
    end
    theta.w = w;
    theta.mean = mean;
    theta.cov = cov;
return;

function L = compute(theta, mfcc_data)
    d = length(mfcc_data);
    b = zeros(M, 1);
    for j=1:M
        sum = 0;
        d = length(mfcc_data);
        for i=1:d
            sum = sum + ((mfcc_data(i) - theta.mean(i,j))^2)/cov(i,j,j);
        end
        num = exp(-0.5*sum);
        prod = eye(d);
        for i=1:d
            prod = prod*cov(i,j);
        end
        denom = ((2*pi)^(d/2))*prod^0.5;
        b = num/denom;
    end
    weight_sum = 0;
    for i=1:M
        weight_sum = weight_sum + theta.w(i)*b;
    end
    
    L = zeros(M, 1);
    for i=1:M
        L(i) = theta.w(i)*b/weight_sum;
    end
    return;
return;