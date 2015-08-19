function fvec = weight(data, meanvec, eigVec, nmodes)

% --------------------------- %
% -- Weight of eigenvector -- %
% --------------------------- %

data = data - meanvec;

for i = 1 : nmodes,
  fvec(i,1) = eigVec(:,i)' * data;
end
