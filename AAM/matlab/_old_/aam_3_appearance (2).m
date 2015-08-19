clear all;
home;

% --------------------------------------------- %
% -- AAM script 3 : PCA for appearance model -- %
% --------------------------------------------- %

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

% -- Set all landmark area to (0,0) and extract img -- %

data     = load('mat/landmark.mat');
landmark = data.landmark;
data     = load('mat/face.mat');
face     = data.face;

%pad = 40;
%height = heightMean + 80;
%width  = widthMean + 70;

%[landmarkFix, faceFix] = all_orginextract(face, landmark, height, width, ...
%                                          pad, nmark, nframes);
%imshow(faceFix(:,:,:,1));
%hold on;
%scatter(landmarkFix(:,1,1), landmarkFix(:,2,1));

% -- Piecewise affine warp 1 : Barycentric coordinates for mean shape -- %

% delaunay triangulation %
% each row shows which 3 points from landmarkMean are connected %
% indcated in index of landmarkMean %
deltri = delaunay(landmarkMean(:,1), landmarkMean(:,2));

[deltriMap, alphaMap, betaMap, gammaMap] = pawarp1_barymean(deltri, landmarkMean, ...
                                                            height, width);

% -- Piecewise affine warp 2 : warp img to mean shape -- %

warpFace = pawarp2_warp(deltri, landmark, face, deltriMap, alphaMap, ...
                        gammaMap, betaMap, height, width, nframes);

imshow(warpFace(:,:,:,1))
                    
%{
for i = 1 : nframes,
  ind = int2str(i);
  imwrite(warpFace(:,:,:,i), ['appearance mapping/map_0' ind '.jpg']);
end
%}

