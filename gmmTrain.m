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
gmms = struct();
%initilaize theta
files = dir(dir_train);
%I DONT KNOW HOW TO INITILIAZE WHY GAUSSIAN WHYY
for i=1:length(files)
    %disp(files(i).name);
    if (strcmp(files(i).name,'.') || strcmp(files(i).name,'..'))
    else
        gmm = struct();
        gmm.name = files(i).name;
        %disp(gmm.name);
        gmms.(files(i).name) = gmm;
    end
end

return;
%struct of structs 

i=0;
prev_L = -Inf;
improvement = Inf;

while i<max_iter && improvement > epsilon
    L = compute;
    theta = update;
    improvement = L-prev_L;
    prev_L = L;
    i = i+1;
end