clear all;
home;

% -------------------------------------- %
% -- AAM script 0 : Load initial data -- %
% -------------------------------------- %

% folder containing data %
dirData = '../dataset/face_db';

% folder saving data %
dirSave = 'mat/'; 

% -- Face landmarks and images -- %

% convert each landmark data from asf to mat format %
asf2annotations(dirData);

% put landmark data into array (58x2x240) %
dirlistMark = dir(sprintf('%s/*.jpg.mat', dirData));
dirlistImg  = dir(sprintf('%s/*.jpg', dirData));
nframes = numel(dirlistMark);

for i = 1 : nframes,
  dataMark = load(sprintf('%s/%s', dirData, dirlistMark(i).name));
  dataImg  = imread(sprintf('%s/%s', dirData, dirlistImg(i).name));
  
  % flip y-coordinate to fit image coordinate %
  data = dataMark.annotations;
  data(:,2) = 480 - data(:,2);
  
  landmark(:,:,i) = data;  
  face(:,:,:,i)   = dataImg;
end

save(sprintf('%s/landmark.mat', dirSave), 'landmark');
save(sprintf('%s/face.mat', dirSave), 'face');


