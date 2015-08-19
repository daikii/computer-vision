clear all;
home;

% ---------------- %
% -- Test print -- %
% ---------------- %
%{
% -- landmarks on img --%

imshow(face(:,:,:,1));
hold on

%landmark(:,1,1) = ceil(640 - landmark(:,1,1));
landmark(:,2,1) = ceil(480 - landmark(:,2,1));
scatter(landmark(:,1,1), landmark(:,2,1));
%}

% folder containing data %
dirData = '../dataset/face_db';

dirlistMark = dir(sprintf('%s/*.jpg.mat', dirData));
nframes = numel(dirlistMark);

for i = 1 : nframes,
  dataMark = load(sprintf('%s/%s', dirData, dirlistMark(i).name));
  
  data = dataMark.annotations;
  
  landmark(:,:,i) = data;  
end

[nmark ndims nframes] = size(landmark);

x = landmark(:,1,1)';
y = landmark(:,2,1)';

for i = 2 : nframes,
  x = [x landmark(:,1,i)'];
  y = [y landmark(:,2,i)'];
end

scatter(x,y,5);