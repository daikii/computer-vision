function [diff, appMean, eigVec, eigVal] = pca_appearance(app)

% ----------------------------------------------------------- %
% -- Mean vector and eigenvector of landmark training data -- %
% ----------------------------------------------------------- %

[ndims nframes] = size(app);

% mean appearance %
for i = 1 : ndims,
  appMean(i,1) = mean(app(i,:));
end

% -- Eigenvector in the order of highest to lowest eigval -- %

% subtract mean from the original data %
for i = 1 : nframes,
  diff(:,i) = app(:,i) - appMean;
end

C = (diff' * diff) / nframes;

[eigVec, eigVal] = pcacov(C);

%{
% covariance matrix (NxN matrix) %
covMat = cov(diff);

% eigenvec + eigval %
eigVal        = eigs(covMat, nframes - 1);
[eigVec, val] = eigs(covMat, nframes- 1);

%save('mat/shape.mat', 'meanvec', 'eigen');
%}