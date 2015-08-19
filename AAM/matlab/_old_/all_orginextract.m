function [landmarkFix, faceFix] = all_orginextract(face, landmark, height, width, pad, nmark, nframes)

% ---------------------------------------------------- %
% -- Set all landmark area to (0,0) and extract img -- %
% ---------------------------------------------------- %

for i = 1 : nframes,
    
  minX = min(landmark(:,1,i));
  minY = min(landmark(:,2,i));

  % subtract min from each point so that it is aligned to (0,0) %
  landmarkFix(:,:,i) = landmark(:,:,i) - repmat([minX - pad, minY - pad], [nmark, 1]);
  
  % extract landmark area from img %
  indX    = ceil(minX - pad);
  indXmax = ceil(indX + width - 1);
  indY    = ceil(minY - pad);
  indYmax = ceil(indY + height - 1);
  
  % convert to double-type img and then store %
  data = face(indY:indYmax,indX:indXmax,:,i);
  faceFix(:,:,:,i) = double(data) / 255;
  
end