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
for i = 1:ncameras
    E = KeyFrames(i).Camera.E;
%     if i == 1
%         figure(f1);
%         hold on;
%     end
%     if i == 2
%         figure(f2);
%         hold on;
%     end
    
    
    

    for j = 1:npoints
        row = row + 2;
        id = Map.points(j).id;
        pointIndex = map{i}(id);
        if pointIndex > 0
        imagePoint = KeyFrames(i).ImagePoints(pointIndex).location;
        
            pointCamera = E*Map.points(j).location;
            X = pointCamera(1);
            Y = pointCamera(2);
            Z = pointCamera(3);
            x = X/Z;
            y = Y/Z;


            imagePoint = K\imagePoint;

            u = imagePoint(1);
            v = imagePoint(2);
%             
%             plot(u,v,'rx');
%             
%             plot(x,y,'bx');

            r(row) = (x-u);
            r(row + 1) = (y-v);

            if calcJ
                for p = 1:pointparams
                    [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                    J(row,p + 3*(j-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                    J(row + 1,p + 3*(j-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                end

                if i > 1
                    for c = 1:camparams
                        [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                        J(row,3*npoints + c + 6*(i-2)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                        J(row + 1,3*npoints + c + 6*(i-2)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                    end
                end
            end


        end
    end
end
    
    
end



