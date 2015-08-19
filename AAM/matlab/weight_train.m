function fvecs = weight_train(data, meanvec, eigVec, nmodes)

% ---------------------------- %
% -- Weight of eigenvectors -- %
% ---------------------------- %

[ndims nframes] = size(data);

for i = 1 : nframes,
  fvecs(:,i) = weight(data(:,i), meanvec, eigVec, nmodes);
end

