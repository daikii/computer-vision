function appNorm = normalize_face(app)

% --------------------------------------------------- %
% -- Photometric normalization for each face image -- %
% --------------------------------------------------- %

[ndims nframes] = size(app);

appNorm = app;
prev    = Inf;
count   = 0;

while (count < 1),

  prev = appNorm;
  
  % mean appearance %
  for i = 1 : ndims,
    appMean(i,1) = mean(appNorm(i,:));
  end

  % standardized mean %
  appStd = appMean(:) - mean(appMean(:));

  % scale %
  variance = mean((appMean(:) - mean(appMean(:))) .^ 2) / 10000;
  appMean(:) = abs(appStd / sqrt(variance));

  % alpha and beta, apply photometric normalization %
  for i = 1 : nframes,
    alpha = dot(appNorm(:,i), appMean(:));
    beta  = mean(appNorm(:,i));
    
    appNorm(:,i) = (appNorm(:,i) - beta) / alpha;
    %sum(appNorm(:,i))
  end
  
  count = count + 1;

end


%{
while (norm(prev - appMean) > 10),

  % align to mean shape by ofsetting %
  %offset = appMean - mean(appMean);  
  
  %prevApp  = appMean;  
  %appMean  = offset / sqrt(variance);

  % normalization %
  for i = 1 : nframes,
    for j = 1 : ndims,
      if (app(j,i) ~= 0 && appMean(j) ~= 0),
        alpha = (app(j,i) .* appMean(j));
        beta  = app(j,i) ./ ndims;
        %alpha
        %beta
        appNorm(j,i) = (app(j,i) - beta) ./ alpha;
      end
    end
  end
  
  prev    = appMean;
  appMean = mean(appNorm, 2);

  norm(prev-appMean)
  
end
%}
  