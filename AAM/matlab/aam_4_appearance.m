clear all;
home;

% ----------------------------------------------- %
% -- AAM script 4 : PCA for appearance model 2 -- %
% ----------------------------------------------- %

data    = load('mat/mapping.mat');
faceMap = data.faceMap;

% -- List of normalized images -- %

[row col rgb nframes] = size(faceMap);

for i = 1 : nframes,
  data = faceMap(:,:,:,i);
  app(:,i) = data(:);
end

appNorm = normalize_face(app);
%a = mean(app, 2);
%app = app - repmat(a, [1 nframes]);

s = reshape(appNorm(:,1), [row col rgb]);
imshow(s);

% -- PCA for appearance model -- %
%{
% mean vector and eigenvector %
[diff appMean eigVec eigVal] = pca_appearance(app);

% normalize eigenvalues to sum at 1 %
eigVal = eigVal ./ sum(eigVal);

% number of modes of variation %
nmodes = modes_variation(eigVal);
nmodes

% top nmodes eigenvectors + eigenvals %
eigVec = eigVec(:,1:nmodes);
eigVal = eigVal(1:nmodes,1);

eigVec = diff * eigVec;

% normalize according to Eckart-Young theorem %
for i = 1 : nmodes,
  eigVec(:,i) = eigVec(:,i) / norm(eigVec(:,i));
end

% weight of eigenvecs %
%fvecs = weight_train(app, appMean, eigVec, nmodes);

% -- SAVE -- %

save('mat/appearance.mat', 'appMean', 'eigVec', 'nmodes');  

% -- Reconstruct img using different weight values -- %

K = 1;
%reconmark = ((eigVec(:,K) * fvecs(K,1)) + appMean;
reconmark = (eigVec(:,K) * sqrt(eigVal(K)) * -3) + appMean;

s = reshape(reconmark, [row col rgb]);
imshow(s);

%}                     
                        