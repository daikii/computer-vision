function [deltriMap, alphaMap, betaMap, gammaMap] = pawarp1_barymean(deltri, landmarkMean, height, width)

% --------------------------------------------------------------------- %
% -- Piecewise Affine Warp 1 : barycentric coordinate for mean shape -- %
% --------------------------------------------------------------------- %

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

