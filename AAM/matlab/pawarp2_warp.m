function faceMap = pawarp2_warp(deltri, landmark, face, deltriMap, alphaMap, ... 
                                gammaMap, betaMap, height, width, nframes)

% ----------------------------------------------------------- %
% -- Piecewise Affine Warp 2 : warp to align to mean shape -- %
% ----------------------------------------------------------- %

faceMap = zeros(height, width, 3, nframes);

% reference delaunay tri and barycentric coordinate from mean shape %
for i = 1 : nframes,  
  for y = 1 : height,
    for x = 1: width,
        
      % look for corresponding triangle in each data %
      % USE DELAUNAY TRI VALUES FROM MEAN SHAPE TO CREATE TRI IN WARPING DATA %
      if (deltriMap(y,x) == 0),
        faceMap(y,x,:,i) = 0;
      else
        tri = deltri(deltriMap(y,x),:);
        
        x1 = landmark(tri(1), 1, i);
        y1 = landmark(tri(1), 2, i);
        x2 = landmark(tri(2), 1, i);
        y2 = landmark(tri(2), 2, i);
        x3 = landmark(tri(3), 1, i);
        y3 = landmark(tri(3), 2, i);

        % corresponding pixel coordinate in image %
        coord = [x1 x2 x3; y1 y2 y3] * [gammaMap(y,x) alphaMap(y,x) betaMap(y,x)]';
        xx = coord(1);
        yy = coord(2);
        
        if (face(ceil(yy),ceil(xx),:,i) ~= 0),
          val = double(face(ceil(yy),ceil(xx),:,i)) / 255;
          faceMap(y,x,:,i) = val;
        else        
          % bilinear interpolation %
          % take output coordinate and compute its pixel val from surrounding input pixels
          f11 = double(face(ceil(yy),ceil(xx),:,i)) / 255;
          f12 = double(face(ceil(yy),ceil(xx)+1,:,i)) / 255;
          f21 = double(face(ceil(yy)+1,ceil(xx),:,i)) / 255;
          f22 = double(face(ceil(yy)+1,ceil(xx)+1,:,i)) / 255;

          valR = f11(1) * (ceil(xx)+1-xx) * (ceil(yy)+1-yy) + ...
                 f12(1) * (ceil(xx)+1-xx) * (yy-ceil(yy)) + ...
                 f21(1) * (xx-ceil(xx)) * (ceil(yy)+1-yy) + ...
                 f22(1) * (xx-ceil(xx)) * (yy-ceil(yy));
          valG = f11(2) * (ceil(xx)+1-xx) * (ceil(yy)+1-yy) + ...
                 f12(2) * (ceil(xx)+1-xx) * (yy-ceil(yy)) + ...
                 f21(2) * (xx-ceil(xx)) * (ceil(yy)+1-yy) + ...
                 f22(2) * (xx-ceil(xx)) * (yy-ceil(yy));
          valB = f11(3) * (ceil(xx)+1-xx) * (ceil(yy)+1-yy) + ...
                 f12(3) * (ceil(xx)+1-xx) * (yy-ceil(yy)) + ...
                 f21(3) * (xx-ceil(xx)) * (ceil(yy)+1-yy) + ...
                 f22(3) * (xx-ceil(xx)) * (yy-ceil(yy));
        
          % map it out %
          val = [valR valG valB];
          faceMap(y,x,:,i) = val;
        end
      end
      
    end
  end
end
      

