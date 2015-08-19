function Wout = affineLKTrackerPyramid(img, tmp, mask, Win, context)

H = context.H;
J = (context.J)';

[row col] = size(img);

% Make arrays for image pyramid %
imgPyr = zeros(row,col,3);
tmpPyr = zeros(row,col,3);

imgPyr(:,:,1) = img;
tmpPyr(:,:,1) = tmp;

% gaussian size? %
filter = fspecial('gaussian', [9,9], 2);

for i = 2 : 3,
  img = imfilter(img, filter);
  imgPyr(:,:,i) = img;
  tmp = imfilter(tmp, filter);
  tmpPyr(:,:,i) = tmp;
end

thresh = Inf;

% Test 3 levels of img pyramid %
for i = 3 : -1 : 1;
    
  img = imgPyr(:,:,i);
  tmp = tmpPyr(:,:,i);
  
  img = warpImageMasked(img, Win, mask);

  tmp = tmp(mask > 0);
  
  % iterate over until delta p is optimized %
  % computer no more than 10 times %
  while (thresh > 0.3),
  
    %%%
    % Compute delta p %
    %%%
    
    % warp I(x) %
    imgW = warpImageMasked(img, Win, mask);
    imgW = imgW(mask > 0);
    
    % Ignore pixels with large difference %
    threshErr = imgW - tmp;
    threshErr(threshErr < -0.33) = 0;
  
    deltaP = H * (J * threshErr);
  
    %%%
    % Update warp %
    %%%

    Wnew = [1+deltaP(1) deltaP(3) deltaP(5) ; ...
            deltaP(2) 1+deltaP(4) deltaP(6) ; ...
            0 0 1];

    Win = Win / inv(Wnew);
    
    % Iteration value : more emphasis on parameters 1 - 4 (1.5 land) %  
    thresh = 1.5 * norm([deltaP(1) deltaP(2) deltaP(3) deltaP(4)]) + ...
             norm([deltaP(5) deltaP(6)]);
  
  end
  
  thresh = Inf;

end

Wout = Win;
