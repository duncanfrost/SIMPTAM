function [ Output ] = pointcloudplane(Plane,XLim, YLim, res)
%POINTCLOUDPLANE Summary produces a cloud of point clouds in a plane defined
%by the corners arugment



Output = [];

for x = 0:res:1
  
    
    for y = 0:res:1
        X = Corners(1,1) + x*dxX + y*dyX;
        Y = Corners(2,1) + x*dxY + y*dyY;
        Z = Corners(3,1) + x*dxZ + y*dyZ;
        newPoint = [X Y Z 1]';
        Output = [Output newPoint];
  
        
    end
end



end

