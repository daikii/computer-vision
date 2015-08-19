function Wout = affineLKTrackerRobust(img, tmp, mask, Win, context)

% Inverse of Hessian and Jacobian %
H = context.H;
J = (context.J)';

% Extract the masked part of template %
tmp = tmp(mask > 0);

%%%
% Scale the brightness of current img %
%%%

% Extract the current track portion %
imgTmp = warpImageMasked(img, Win, mask);
imgTmp = imgTmp(mask > 0);

% Average pixel val of template and current img %
avrT = mean(tmp(:));
avrIm = mean(imgTmp(:));
ratio = avrT / avrIm;

% Scale the brightness of img %
% only if the difference is relatively large %
if (ratio > 1.15 || ratio < 0.9),
  img = img * ratio;
  %img(abs(avrT - img) > 0.7) = img(abs(avrT - img) > 0.7) * ratio;
end

count = 0;
deltaP = Inf;

% iterate over until delta p is optimized %
% computer no more than 10 times %
while (norm(deltaP) > 0.03 && count < 10),
  
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
  
  count = count + 1;
  
end

Wout = Win;
