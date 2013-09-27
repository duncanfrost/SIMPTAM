function [r, J] = scalecalculateresiduals2(PTAM, range, counts, map,calcJ,ids,C)
%CALCULATERESIDUALS Summary of this function goes here
%   Detailed explanation goes here

% ncameras = size(KeyFrames,2);
% npoints = size(Map.points,2);



KeyFrames = PTAM.KeyFrames;
Map = PTAM.Map;
nresi = 2*round(sum(counts)) + sum(sum(C>0));
npoints = size(ids,1);
nparam = 3*npoints + 6*size(range,2);


r = zeros(nresi,1);
J = zeros(nresi,nparam);

K = PTAM.Camera.K;
row = -1;
pointparams = 3;
camparams = 6;
ncameras = size(KeyFrames,2);
npoints = size(Map.points,2);




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
            pix = K*[x y 1]';
            x = pix(1);
            y = pix(2);
            
            
            
            
            
            %imagePoint = imagePoint;
            
            u = imagePoint(1);
            v = imagePoint(2);
            %
            %             plot(u,v,'rx');
            %
            %             plot(x,y,'bx');
            
            r(row) = (u-x);
            r(row + 1) = (v-y);
            
            
            fx = K(1,1);
            fy = K(2,2);
            
            point = id;
            cam = i;
            
            
            if calcJ
               
                
                if i > 1
                    for c = 1:camparams
                        [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                        J(row,c + 6*(cam-2)) = fx*(dX_dp*Z - dZ_dp*X)/(Z^2);
                        J(row + 1,c + 6*(cam-2)) = fy*(dY_dp*Z - dZ_dp*Y)/(Z^2);
                    end
                end
                
                 for p = 1:pointparams
                    [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                    J(row,6*(ncameras-1) + p + 3*(point-1)) = fx*(dX_dp*Z - dZ_dp*X)/(Z^2);
                    J(row + 1,6*(ncameras-1) + p + 3*(point-1)) = fy*(dY_dp*Z - dZ_dp*Y)/(Z^2);
                end
            end
        end
        
        
        
    end
end
row = row + 1;

lambda = 100;

N = zeros(3,1);
for i = 1:npoints
    for j = i+1:npoints
        if C(i,j) > 0
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
                J(row,6*(ncameras-1) + 3*(i-1)+1) = (lambda*N(1))/sqrt(U);
                J(row,6*(ncameras-1) + 3*(i-1)+2) = (lambda*N(2))/sqrt(U);
                J(row,6*(ncameras-1) + 3*(i-1)+3) = (lambda*N(3))/sqrt(U);
                
                
                J(row,6*(ncameras-1) + 3*(j-1)+1) = (-lambda*N(1))/sqrt(U);
                J(row,6*(ncameras-1) + 3*(j-1)+2) = (-lambda*N(2))/sqrt(U);
                J(row,6*(ncameras-1) + 3*(j-1)+3) = (-lambda*N(3))/sqrt(U);
            end
            
        end
        
    end
end












