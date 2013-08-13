function [r, J] = scalecalculateresiduals(PTAM, range, counts, map,calcJ,ids,C)
%CALCULATERESIDUALS Summary of this function goes here
%   Detailed explanation goes here

% ncameras = size(KeyFrames,2);
% npoints = size(Map.points,2);




nresi = 2*round(sum(counts)) + sum(sum(C>0));
npoints = size(ids,1);
nparam = 3*npoints + 6*size(range,2);


r = zeros(nresi,1);
J = zeros(nresi,nparam);

K = PTAM.Camera.K;
row = -1;
pointparams = 3;
camparams = 6;





for i = 1:npoints
    for j = 1:size(PTAM.KeyFrames,2)
         
        E = PTAM.KeyFrames(j).Camera.E;
        pointIndex = map{j}(ids(i));
        imagePoint = [];
        if pointIndex > 0
            imagePoint = PTAM.KeyFrames(j).ImagePoints(pointIndex).location;
        end
        
        
        
        if ~isempty(imagePoint)  
            row = row + 2;
            
            
            
            
            
            mapPoint = PTAM.Map.points(ids(i));
            
            pointCamera = E*mapPoint.location;
            X = pointCamera(1);
            Y = pointCamera(2);
            Z = pointCamera(3);
            x = X/Z;
            y = Y/Z;
            
            
            imagePoint = K\imagePoint;
            
            u = imagePoint(1);
            v = imagePoint(2);
            
            r(row) = (x-u);
            r(row + 1) = (y-v);
            
            for p = 1:pointparams
                [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                J(row,p + 3*(i-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                J(row + 1,p + 3*(i-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
            end
            
            if sum(j==range)>0
                kfcount = find(range==j);
                for c = 1:camparams
                    [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                    J(row,3*npoints + c + 6*(kfcount-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                    J(row + 1,3*npoints + c + 6*(kfcount-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                end
            end
            
            
            
        end
    end
end
row = row + 1;

lambda = 0.01;

for i = 1:npoints
       for j = i+1:npoints
           if C(i,j) > 0
                row = row + 1;
                X1 = PTAM.Map.points(ids(i)).location;
                X2 = PTAM.Map.points(ids(j)).location;
                N(1) = X1(1) - X2(1);
                N(2) = X1(2) - X2(2);
                N(3) = X1(3) - X2(3);
                
                
                
                
                
                residual = norm(N)^2 - C(i,j)^2;
                r(row) = lambda*residual;
                
                
                J(row,3*(i-1)+1) = 2*lambda*N(1);
                J(row,3*(i-1)+2) = 2*lambda*N(2);
                J(row,3*(i-1)+3) = 2*lambda*N(3);
                
                
                J(row,3*(j-1)+1) = -2*lambda*N(1);
                J(row,3*(j-1)+2) = -2*lambda*N(2);
                J(row,3*(j-1)+3) = -2*lambda*N(3);
                
           end
            
       end
end












