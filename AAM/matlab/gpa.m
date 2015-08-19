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
while (norm(landmarkPrev - landmarkMean) > 10),

  % Align to mean shape %
  for i = 1 : nframes,

    [err trans] = procrustes(landmarkMean, landmark(:,:,i));
  
    landmarkAlign(:,:,i) = trans;
  
  end

  landmarkPrev = landmarkMean;

  % compute new mean shape %
  for i = 1 : nmark,
    meanX = mean(landmarkAlign(i,1,:));
    meanY = mean(landmarkAlign(i,2,:));
    landmarkMean(i,:) = [meanX meanY];
  end

end  
  