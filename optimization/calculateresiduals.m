function [r, J] = calculateresiduals(KeyFrames, Map ,map,calcJ)
%CALCULATERESIDUALS Summary of this function goes here
%   Detailed explanation goes here

ncameras = size(KeyFrames,2);
npoints = size(Map.points,2);
camparams = 6;
pointparams = 3;
r = zeros(2*(ncameras)*npoints,1);
J = zeros(2*(ncameras)*npoints,6*(ncameras-1) + 3*npoints);
K = KeyFrames(1).Camera.K;




% f1 = figure;
% f2 = figure;
%
% hold on;

row = -1;
for i = 1:size(KeyFrames,2)
    
    for j = 1:size(KeyFrames(i).ImagePoints,2)
        
        id = KeyFrames(i).ImagePoints(j).id;
        if ~isempty(id)
 
            row = row + 2;
            E = KeyFrames(i).Camera.E;
            
            imagePoint = KeyFrames(i).ImagePoints(j).location;
            
            pointCamera = E*Map.points(id).location;
            X = pointCamera(1);
            Y = pointCamera(2);
            Z = pointCamera(3);
            x = X/Z;
            y = Y/Z;
%             pix = K*[x y 1]';
%             x = pix(1);
%             y = pix(2);
            
            
            
            
            
            %imagePoint = imagePoint;
            
            u = imagePoint(1);
            v = imagePoint(2);
            %
            %             plot(u,v,'rx');
            %
            %             plot(x,y,'bx');
            
            r(row) = (x-u);
            r(row + 1) = (y-v);
            
            
%             fx = K(1,1);
%             fy = K(2,2);
            
            point = id;
            cam = i;
            
            
            if calcJ
               
                
                if i > 1
                    for c = 1:camparams
                        [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                        J(row,c + 6*(cam-2)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                        J(row + 1,c + 6*(cam-2)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                    end
                end
                
                 for p = 1:pointparams
                    [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                    J(row,6*(ncameras-1) + p + 3*(point-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                    J(row + 1,6*(ncameras-1) + p + 3*(point-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                end
            end
        end
        
        
        
    end
end


end



