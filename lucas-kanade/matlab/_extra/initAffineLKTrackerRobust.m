function [affineLKContext] = initAffineLKTrackerRobust(tmp, mask, sizeTmp)

%%%
% Jacobian of affine warp %
%%%

% Extract the masked part of template %
row = sizeTmp(1);
col = sizeTmp(2);

tmp = tmp(mask > 0);
tmp = reshape(tmp, row, col);

% Compute the index matrix of x and y %
jacobU = kron([1 : col], ones(row, 1));
jacobU = jacobU(:);
jacobV = kron([1 : row]', ones(1, col));
jacobV = jacobV(:);
jacobZero = zeros(row, col);
jacobZero = jacobZero(:);
jacobOne = ones(row, col);
jacobOne = jacobOne(:);

% store each vector in 3D format %
dWdp = zeros(2,6);
for i = 1 : size(jacobU),
  dWdp(:,:,i) = [jacobU(i) jacobZero(i) jacobV(i) jacobZero(i) jacobOne(i) jacobZero(i) ; ...
                 jacobZero(i) jacobU(i) jacobZero(i) jacobV(i) jacobZero(i) jacobOne(i)];
end

%%%
% Jacobian of error function L %
%%%

% u / v - gradient image %
% initial warp parameters are zeros, so no need for warping %
[dTdu dTdv] = gradient(tmp);

dTdu = dTdu(:);
dTdv = dTdv(:);

gradT = [dTdu dTdv];

% compute steepest descent images (jacobian)  %
sum = 0;
[row col depth] = size(dWdp);

for i = 1 : col,
  for j = 1 : 2,
    dWdpTemp = reshape(dWdp(j,i,:), depth, 1);
    sum = sum + (gradT(:,j) .* dWdpTemp);
  end
  affineLKContext.J(:,i) = sum;
  sum = 0;
end

%%%
% Hessian matrix %
%%%

affineLKContext.H = inv(affineLKContext.J' * affineLKContext.J);


% test %
%{
a = reshape(affineLKContext.J, 192, 200);
figure(1), imshow(a);
affineLKContext.H
%}
