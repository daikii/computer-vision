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

% delaunay triangulation %
% each row shows which 3 points from landmarkMean are connected %
% indcated in index of landmarkMean %
deltri = delaunay(landmarkMean(:,1), landmarkMean(:,2));

pad = 20;
[landmarkMean, height, width] = meanshape_origin(deltri, landmarkMean, pad, nmark);

% -- Set all landmark area to (0,0) and extract img -- %

data     = load('mat/landmark.mat');
landmark = data.landmark;
data     = load('mat/face.mat');
face     = data.face;

[landmarkFix, faceFix] = all_orginextract(face, landmark, height, width, pad, nmark, nframes);
imshow(faceFix(:,:,:,1))
%{
maxX = max(landmarkMean(:,1));
maxY = max(landmarkMean(:,2));
minX = min(landmarkMean(:,1));
minY = min(landmarkMean(:,2));

% subtract min from each point so that 
% it is aligned from (0,0) to the of landmark area %
landmarkMean = landmarkMean - repmat([minX - pad, minY - pad], [nmark, 1]);

% height and width of the extracted area %
height = ceil(maxY - minY + 50);
width  = ceil(maxX - minX + 40);
%}

% -- Piecewise affine warp 1 : Barycentric coordinate for mean shape -- %

[deltriMap, alphaMap, betaMap, gammaMap] = pawarp1_barymean(deltri, landmarkMean, height, width);

%{
% delaunay triangulation %
% each row shows which 3 points from landmarkMean are connected %
% shown in index of landmarkMean %
deltri = delaunay(landmarkMean(:,1), landmarkMean(:,2));
[ntri col] = size(deltri);

% map of delaunay tri to show which triangle each point is located at %
deltriMap = zeros(height, width);
alphaMap  = zeros(height, width);
betaMap   = zeros(height, width);
gammaMap  = zeros(height, width);

% compute barycentric coordinate for every pixel %
for y = 1 : height,
  for x = 1 : width,
    for i = 1 : ntri,
    % loop until matches triangle %
        
      % t-th triangle %
      tri = deltri(i,:);
      
      % coordinate for t-th triangle vertices %
      x1 = landmarkMean(tri(1), 1);
      y1 = landmarkMean(tri(1), 2);
      x2 = landmarkMean(tri(2), 1);
      y2 = landmarkMean(tri(2), 2);
      x3 = landmarkMean(tri(3), 1);
      y3 = landmarkMean(tri(3), 2);
      
      % barycentric coordinate (alpha and beta) %
      divisor = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
      alpha   = ((x - x1) * (y3 - y1) - (y - y1) * (x3 - x1)) / divisor;
      beta    = ((y - y1) * (x2 - x1) - (x - x1) * (y2 - y1)) / divisor;
      
      % check if a point belongs into this triangle %
      if (alpha >= 0 && beta >= 0 && (alpha + beta) <= 1),
        deltriMap(y,x) = i;
        alphaMap(y,x)  = alpha;
        betaMap(y,x)   = beta;
        gammaMap(y,x)  = 1 - alpha - beta;
        break;
      end    
    end
  end
end
%}

% -- Piecewise affine warp 2 : warp img to mean shape -- %

warpFace = pawarp2_warp(deltri, landmarkFix, faceFix, deltriMap, alphaMap, ...
                        gammaMap, betaMap, height, width, nframes);

%{
faceFix     = zeros(height, width, 3, nframes);
landmarkFix = zeros(nmark, 2, nframes);

for i = 1 : nframes,
    
  % extract landmark area %  
  minX = min(landmark(:,1,i));
  minY = min(landmark(:,2,i));

  % subtract min from each point so that 
  % it is aligned from (0,0) to the of landmark area %
  landmarkFix(:,:,i) = landmark(:,:,i) - repmat([minX - pad, minY - pad], [nmark, 1]);
  
  % extract landmark area from img %
  indX    = ceil(minX - 20);
  indXmax = ceil(indX + width - 1);
  indY    = ceil(minY - 20);
  indYmax = ceil(indY + height - 1);
  
  % convert to double-type img and then store %
  data = face(indY:indYmax,indX:indXmax,:,i);
  faceFix(:,:,:,i) = double(data) / 255;
  
end
%}

%imshow(faceFix(:,:,:,1));
%hold on
%scatter(landmarkFix(:,1,1), landmarkFix(:,2,1));

%warpFace = zeros(height, width, 3, nframes);
%{
for i = 1 : nframes,
  %deltri     = sortrows(sort(delaunay(landmarkFix(:,1,i), landmarkFix(:,2,i)), 2));
  %[ntri col] = size(deltri);
  
  for y = 1 : height,
    for x = 1: width,
        
      % corresponding triangle in new data %
      if (deltriMap(y,x) == 0),
        warpFace(y,x,:,i) = 0;
      else
        tri = deltri(deltriMap(y,x),:);
        
        x1 = landmarkFix(tri(1), 1, i);
        y1 = landmarkFix(tri(1), 2, i);
        x2 = landmarkFix(tri(2), 1, i);
        y2 = landmarkFix(tri(2), 2, i);
        x3 = landmarkFix(tri(3), 1, i);
        y3 = landmarkFix(tri(3), 2, i);

        % corresponding pixel coordinate in image %
        coord = ceil([x1 x2 x3; y1 y2 y3] * [gammaMap(y,x) alphaMap(y,x) betaMap(y,x)]');
        if (coord(1) > width || coord(2) > height),
          warpFace(y,x,:,i) = 0;
        else
          warpFace(y,x,:,i) = faceFix(coord(2),coord(1),:,i);
        end
      end
    end
  end
end
      %}
imshow(warpFace(:,:,:,100));


