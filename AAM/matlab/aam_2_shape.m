clear all;
home;

% ---------------------------------------- %
% -- AAM script 2 : PCA for shape model -- %
% ---------------------------------------- %

data          = load('mat/aligned.mat');
landmarkAlign = data.landmarkAlign;

[nmark ndim nframes] = size(landmarkAlign);

% shape array (58x240) %
for i = 1 : nframes,
  data = landmarkAlign(:,:,i);
  shape(:,i) = data(:);
end

% -- Mean vector and eigenvector -- %

[meanvec eigVec eigVal] = pca_shape(shape);

% -- Number of modes of variation -- %

nmodes = modes_variation(eigVal);

% -- Top nmodes eigenvectors + eigenvals -- %

eigVec = eigVec(:,1:nmodes);
eigVal = eigVal(1:nmodes,1);

% -- Weight of eigenvecs -- %

fvecs = weight_train(shape, meanvec, eigVec, nmodes);

% -- SAVE -- %

save('mat/shape.mat', 'meanvec', 'eigVec', 'fvecs', 'nmodes');  

% -- Reconstruct training landmarks using different weight values -- %

K = 1;
reconmark = (eigVec(:,K) * fvecs(K,1)) + meanvec;
%reconmark = (eigVec(:,K) * sqrt(eigVal(K))*-3) + meanvec;

% plot %
x = reconmark(1:58,1)';
y = reconmark(59:116,1)';
scatter(x, y, 5);

% Delaunay triangulation (mesh) %
tri = delaunay(x, y);
triplot(tri,x,y);

