function [landmarkMean, height, width] = meanshape_origin(landmarkMean, pad, nmark)

% ----------------------------- %
% -- Set mean shape to (0,0) -- %
% ----------------------------- %

maxX = max(landmarkMean(:,1));
maxY = max(landmarkMean(:,2));
minX = min(landmarkMean(:,1));
minY = min(landmarkMean(:,2));

% subtract min from each point so that it is aligned to (0,0) %
landmarkMean = landmarkMean - repmat([minX - pad, minY - pad], [nmark, 1]);

% height and width of the extracted area %
height = ceil(maxY - minY + pad * 2);
width  = ceil(maxX - minX + pad * 2);