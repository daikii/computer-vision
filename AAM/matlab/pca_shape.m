function [meanvec, eigVec, eigVal] = pca_shape(shape)

% ----------------------------------------------------------- %
% -- Mean vector and eigenvector of landmark training data -- %
% ----------------------------------------------------------- %

% -- Vector of mean for each dimension in img matrix -- %

[ndims nframes] = size(shape);

% compoute mean for each dimension %
for i = 1 : ndims,
  meanvec(i,1) = mean(shape(i,:));
end

% -- Eigenvector in the order of highest to lowest eigval -- %

% subtract mean from the original data %
for i = 1 : nframes,
  diff(:,i) = shape(:,i) - meanvec;
end

% covariance matrix %
covMat = cov(diff');

% eigenvec + eigval %
eigVal        = eigs(covMat, ndims - 1);
[eigVec, val] = eigs(covMat, ndims - 1);

%save('mat/shape.mat', 'meanvec', 'eigen');
