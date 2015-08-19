function landmarkAlign = gpa(landmark)

% ------------------------------------------------ %
% -- Generalized orthogonal Procrustes Analysis -- %
% ------------------------------------------------ %

% number of landmarks and img (set of landmark) %
[nmark col nframes] = size(landmark);

% fist shape as mean shape %
landmarkMean = landmark(:,:,1);

% set previous landmark mean for the comparison %
landmarkPrev = 0;

% iterate until delta(prev landmark - new landmark) converges %
while (norm(landmarkPrev - landmarkMean) > 1),

  % Align to mean shape %
  for i = 1 : nframes,

    % translate %
    centroidX = mean(landmark(:,1,i));
    centroidY = mean(landmark(:,2,i));
  
    landmarkAlign(:,1,i) = landmark(:,1,i) - centroidX;
    landmarkAlign(:,2,i) = landmark(:,2,i) - centroidY;
    
    % scale %
    landmarkAlign(:,1,i) = landmarkAlign(:,1,i) / norm(landmarkAlign(:,1,i));
    landmarkAlign(:,2,i) = landmarkAlign(:,2,i) / norm(landmarkAlign(:,2,i));
  
    % rotate %
    [U S V] = svd(landmarkMean' * landmarkAlign(:,:,i));
    rotate = V * U;
  
    landmarkAlign(:,:,i) = landmarkAlign(:,:,i) * rotate;
  
  end

  landmarkPrev = landmarkMean;

  % compute new mean shape %
  for i = 1 : nmark,
    meanX = mean(landmarkAlign(i,1,:));
    meanY = mean(landmarkAlign(i,2,:));
    landmarkMean(i,:) = [meanX meanY];
  end
  
  %landmark = landmarkAlign;

end  
  
  