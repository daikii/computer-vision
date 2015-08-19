clear all;
home;

% ----------------------------------------------------- %
% -- AAM Script 5 : Pre-compute Jacobian and Hessian -- %
% ----------------------------------------------------- %

data         = load('mat/mapping.mat');
faceMap      = data.faceMap;
deltri       = data.deltri;
deltriMap    = data.deltriMap;
landmarkMean = data.landmarkMean(:);

data   = load('mat/shape.mat');
eigSh = data.eigVec;

data    = load('mat/appearance.mat');
eigApp  = data.eigVec;
appMean = data.appMean;

nmarks  = size(landmarkMean);
nmarks2 = nmarks(1) / 2;


% -- Basis for global shape transform -- %

n1_trans                   = landmarkMean;
n2_trans(1:nmarks2)        = -landmarkMean(nmarks2+1:end);
n2_trans(nmarks2+1:nmarks) = landmarkMean(1:nmarks2);
n3_trans(1:nmarks2)        = ones(nmarks2, 1);
n3_trans(nmarks2+1:nmarks) = zeros(nmarks2, 1);
n4_trans(1:nmarks2)        = zeros(nmarks2, 1);
n4_trans(nmarks2+1:nmarks) = ones(nmarks2, 1);
	
% orthonormalize %
n_trans_eig(:,1) = n1_trans;
n_trans_eig(:,2) = n2_trans;
n_trans_eig(:,3) = n3_trans;
n_trans_eig(:,4) = n4_trans;

n_trans_eig(:,5:size(eigSh,2)+4) = eigSh;
	
% Orthogonalize the basis %
n_trans_eig = gs_orthonorm(n_trans_eig);
		
% Basis for global shape transform %
n = n_trans_eig(:,1:4);

% Basis for the shape model
s = n_trans_eig(:,5:end);

% -- Compute Jacobian -- %

[height width rgb nframes] = size(faceMap);

% Jacobina and global shape normalization %
dw_dp = zeros(height, width, 2, size(s, 2));
dn_dq = zeros(height, width, 2, 4);

for y = 1 : height,
  for x = 1 : width,
    if (deltriMap(y,x) ~= 0),
      t = deltri(deltriMap(y,x),:);
      
      for k = 1 : 3,
        dik_dp = s(t(k),:);
        djk_dp = s(ceil(t(k)+nmarks2),:);  
          
        dik_dq = n(t(k),:);
        djk_dq = n(ceil(t(k)+nmarks2),:);
        
        t2    = t;
        t2(1) = t(k);
        t2(k) = t(1);
        
        x1 = landmarkMean(t2(1));
        y1 = landmarkMean(ceil(nmarks2 + t2(1)));
        x2 = landmarkMean(t2(2));
        y2 = landmarkMean(ceil(nmarks2 + t2(2)));
        x3 = landmarkMean(t2(3));
        y3 = landmarkMean(ceil(nmarks2 + t2(3)));
        
        % barycentric coordinate (alpha and beta) %
        divisor = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
        alpha   = ((x - x1) * (y3 - y1) - (y - y1) * (x3 - x1)) / divisor;
        beta    = ((y - y1) * (x2 - x1) - (x - x1) * (y2 - y1)) / divisor;       
      
        dw_dij = 1 - alpha - beta;

        dw_dp(y,x,:,:) = squeeze(dw_dp(y,x,:,:)) + dw_dij * [dik_dp; djk_dp];
        dn_dq(y,x,:,:) = squeeze(dn_dq(y,x,:,:)) + dw_dij * [dik_dq; djk_dq];
      end
    end
  end
end

% -- Steepest descent algorithm -- %

appMean = reshape(appMean, [height width rgb size(appMean, 2)]);

for i = 1 : rgb,
  [di dj] = gradient_2d(appMean(:,:,i), deltriMap);
  mean_app_gradient(:,:,i,1) = di;
  mean_app_gradient(:,:,i,2) = dj;
end
	
dA0 = mean_app_gradient;

app_modes = reshape(eigApp, [height width rgb size(eigApp, 2)]);
SD = zeros(height, width, rgb, 4 + size(dw_dp, 4));

for i = 1 : 4,
  prj_diff = zeros(rgb, size(eigApp, 2));
  for j = 1 : size(eigApp, 2),
    for c = 1 : rgb,
      prj_diff(c,j) = sum(sum(app_modes(:,:,c,j) .* (dA0(:,:,c,1) .* dn_dq(:,:,1,i) + dA0(:,:,c,2) .* dn_dq(:,:,2,i))));
    end
  end
  
  for c = 1 : rgb,
    SD(:,:,c,i) = dA0(:,:,c,1) .* dn_dq(:,:,1,i) + dA0(:,:,c,2) .* dn_dq(:,:,2,i);
  end
  
  for j = 1 : size(eigApp, 2),
    for c = 1 : rgb,
	  SD(:,:,c,i) = SD(:,:,c,i) - prj_diff(c,j) * app_modes(:,:,c,j);
    end
  end
end
 
for i = 1 : size(dw_dp, 4),      
  prj_diff = zeros(rgb, size(eigApp, 2));
  for j = 1 : size(eigApp, 2),
    for c = 1 : rgb,
	  prj_diff(c,j) = sum(sum(app_modes(:,:,c,j) .* (dA0(:,:,c,1) .* dw_dp(:,:,1,i) + dA0(:,:,c,2) .* dw_dp(:,:,2,i))));
    end
  end
  for c = 1 : rgb,
    SD(:,:,c,i+4) = dA0(:,:,c,1) .* dw_dp(:,:,1,i) + dA0(:,:,c,2) .* dw_dp(:,:,2,i);
  end
  for j = 1 : size(eigApp, 2)
    for c = 1 : rgb,
	  SD(:,:,c,i+4) = SD(:,:,c,i+4) - prj_diff(c,j) * app_modes(:,:,c,j);
    end
  end
end

data = SD;
SD = zeros(size(SD, 4), size(eigApp,1));
	
for i = 1 : size(data, 4)
  SD(i,:) = reshape(data(:,:,:,i), 1, []);
end

H = SD * SD';
inverseH = inv(H);
R = inverseH * SD;

