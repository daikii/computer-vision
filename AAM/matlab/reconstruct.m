function reconimage = reconstruct(fvec, meanvec, basis, imsize)

% -- Face Reconstruction -- %
% reconstruct img of top K eigenfaces %

[K col] = size(fvec);
sumVec  = 0;

for i = 1 : K,
  sumVec = sumVec + (basis(:,i) * fvec(i,1));
end

reconimg = sumVec + meanvec;

reconimg = fn_double2img(reconimg);
reconimage(:,:,1) = reshape(reconimg(:,1), imsize(1), imsize(2));

