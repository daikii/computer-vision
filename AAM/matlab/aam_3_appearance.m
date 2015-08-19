clear all;
home;

% ----------------------------------------------- %
% -- AAM script 3 : PCA for appearance model 1 -- %
% ----------------------------------------------- %

% -- Mean shape from aligned landmark data -- %

data          = load('mat/aligned.mat');
landmarkAlign = data.landmarkAlign;

[nmark ndim nframes] = size(landmarkAlign);

for i = 1 : nmark,
  x = mean(landmarkAlign(i,1,:));
  y = mean(landmarkAlign(i,2,:));
  landmarkMean(i,:) = [x y];
end

% -- Set landmark area of mean shape to (0,0) -- %

pad = 2;
[landmarkMean, height, width] = meanshape_origin(landmarkMean, pad, nmark);

% -- Piecewise affine warp 1 : Barycentric coordinates for mean shape -- %

% delaunay triangulation %
% each row shows which 3 points from landmarkMean are connected %
% indcated in index of landmarkMean %
deltri = delaunay(landmarkMean(:,1), landmarkMean(:,2));

[deltriMap, alphaMap, betaMap, gammaMap] = pawarp1_barymean(deltri, landmarkMean, ...
                                                            height, width);

% -- Piecewise affine warp 2 : map img to mean shape -- %

data     = load('mat/landmark.mat');
landmark = data.landmark;
data     = load('mat/face.mat');
face     = data.face;

faceMap = pawarp2_warp(deltri, landmark, face, deltriMap, alphaMap, ...
                       gammaMap, betaMap, height, width, nframes);

% save data %
save('mat/mapping.mat', 'faceMap', 'deltriMap', 'deltri', 'landmarkMean');                   

for i = 1 : nframes,
  ind = int2str(i);
  imwrite(faceMap(:,:,:,i), ['appearance mapping/map_0' ind '.jpg']);
end

