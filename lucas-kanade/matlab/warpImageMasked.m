function warpim = warpImageMasked(im, H, mask)

%Function to warp an image with a linear transform (affine or projective)
%
%Inputs
%
% im  - input image: a greyscale or color image (2D or 3D matrix), should
% be double not char.
% H   - a 3x3 matrix for the transform to apply to the image
% a pixel with coordinates [u v 1]' in the input image will move to
% H[u v 1]' in the output image
% mask - (optional) a mask image, the same size as the input. Output will
% only be computed at pixels where the mask is set to a non zero value.
%
%Outputs
% warpim - output image: a greyscale or color image the same size as im.
% contains the transformed version of the input. At any point outside the
% mask or at a point where the pixel value is undefined, the flag value
% -1e6 is stored.

[R, C, D] = size(im);

if (nargin < 3)
    mask = true(R,C);
end

% get size of matrix
warpim = -1e6 * zeros([R, C, D]);

% compute all points in the warped image
[wY, wX] = find(mask);
idx      = find(mask);
allwp = [wX(:)' ; wY(:)' ; ones(1, numel(wX))];

alluwp = H \ allwp;

% compute the inverse warped positions in the original image
alluwp = H \ allwp;
if (any(H(3,:) ~= [0 0 1]))
    alluwp(1,:) = alluwp(1,:) ./ alluwp(3,:);
    alluwp(2,:) = alluwp(2,:) ./ alluwp(3,:);
end

% compute the image values for each dimension
for i = 1:D
    warpimi = interp2(im(:,:,i),alluwp(1,:),alluwp(2,:),'nearest',-1e6);
    warpim(idx + (i-1)*R*C) = warpimi;
end

