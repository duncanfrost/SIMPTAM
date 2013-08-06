function [r, J] = calculateresidualscamonly(Camera, Frame, Map ,map,calcJ)
%CALCULATERESIDUALSCAMONLY Calculates the residuals, and optionally
%jacobain for single camera only optimisation



npoints = size(Map.points,2);

camparams = 6;


r = zeros(2*npoints,1);

J = zeros(2*npoints,camparams);




row = -1;

for j = 1:npoints
    
    row = row + 2;
    id = Map.points(j).id;
    pointIndex = map(id);
    imagePoint = [];
    if pointIndex > 0
        imagePoint = Frame.ImagePoints(pointIndex).location;
    end


    if ~isempty(imagePoint)        
        pointCamera = Camera.E*Map.points(j).location;
        X = pointCamera(1);
        Y = pointCamera(2);
        Z = pointCamera(3);
        x = X/Z;
        y = Y/Z;



        imagePoint = Camera.K\imagePoint;

        u = imagePoint(1);
        v = imagePoint(2);

        r(row) = (x-u);
        r(row + 1) = (y-v);

        if calcJ            
            for c = 1:camparams
                [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                J(row,c) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                J(row + 1,c) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
            end
        end

    end


end
    





end

