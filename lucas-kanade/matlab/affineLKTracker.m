function Wout = affineLKTracker(img, tmp, mask, Win, context)

% Inverse of Hessian and Jacobian %
H = context.H;
J = (context.J)';

% Extract the masked part of template %
tmp = tmp(mask > 0);
 
count = 0;
thresh = Inf;

% iterate over until the convergence of deltaP is trivial %
% computer no more than 10 times (0.3 land) % 
while (thresh > 0.05 && count < 10),
  
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

  count = count + 1;
  
end

Wout = Win;
