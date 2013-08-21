function [r, J] = scalecalculateresiduals2(PTAM, range, counts, map,calcJ,ids,C)
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





for i = 1:size(PTAM.KeyFrames,2)
    for j = 1:npoints
        
        E = PTAM.KeyFrames(i).Camera.E;
        pointIndex = map{i}(ids(j));
        imagePoint = [];
        if pointIndex > 0
            imagePoint = PTAM.KeyFrames(i).ImagePoints(pointIndex).location;
        end
        
        
        
        if ~isempty(imagePoint)
            row = row + 2;
            
            
            
            
            
            mapPoint = PTAM.Map.points(ids(j));
            
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
            
            if calcJ
                for p = 1:pointparams
                    [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                    J(row,p + 3*(j-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                    J(row + 1,p + 3*(j-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                end
                
                if sum(i==range)>0
                    kfcount = find(range==i);
                    for c = 1:camparams
                        [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                        J(row,3*npoints + c + 6*(kfcount-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                        J(row + 1,3*npoints + c + 6*(kfcount-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                    end
                end
            end
            
            
            
        end
    end
end
row = row + 1;

lambda = 0.01;

N = zeros(3,1);
for i = 1:npoints
    for j = i+1:npoints
        if C(i,j) >= 0
            row = row + 1;
            X1 = PTAM.Map.points(ids(i)).location;
            X2 = PTAM.Map.points(ids(j)).location;
            N(1) = X1(1) - X2(1);
            N(2) = X1(2) - X2(2);
            N(3) = X1(3) - X2(3);
            
            U = N'*N;
            
            
            
            
            
            residual = sqrt(U) - C(i,j);
            r(row) = lambda*residual;
            
            if calcJ
                J(row,3*(i-1)+1) = (lambda*N(1))/sqrt(U);
                J(row,3*(i-1)+2) = (lambda*N(2))/sqrt(U);
                J(row,3*(i-1)+3) = (lambda*N(3))/sqrt(U);
                
                
                J(row,3*(j-1)+1) = (-lambda*N(1))/sqrt(U);
                J(row,3*(j-1)+2) = (-lambda*N(2))/sqrt(U);
                J(row,3*(j-1)+3) = (-lambda*N(3))/sqrt(U);
            end
            
        end
        
    end
end












