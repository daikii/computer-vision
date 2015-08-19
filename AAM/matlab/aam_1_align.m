clear all;
home;

% -------------------------------------------------------- %
% -- AAM script 1 : Alignment using Procrustes Analysis -- %
% -------------------------------------------------------- %

% -- Generalized orthogonal Procrustes Analysis -- %

landmark = load('mat/landmark.mat');
landmark = landmark.landmark;

% aligned landmark data % 
landmarkAlign = gpa(landmark);

% save aligned landmark data %
save('mat/aligned.mat', 'landmarkAlign');

% -- Test GPA -- %

[nmark ndims nframes] = size(landmark);

x = landmarkAlign(:,1,1)';
y = landmarkAlign(:,2,1)';

for i = 2 : nframes,
  x = [x landmarkAlign(:,1,i)'];
  y = [y landmarkAlign(:,2,i)'];
end

scatter(x,y,5);
