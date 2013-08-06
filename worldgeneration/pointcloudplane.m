function [ Output ] = pointcloudplane(Corners, res)
%POINTCLOUDPLANE Summary produces a cloud of point clouds in a plane defined
%by the corners arugment

dxX = (Corners(1,2)-Corners(1,1))/res;
dyX = (Corners(1,3)-Corners(1,1))/res;
dxY = (Corners(2,2)-Corners(2,1))/res;
dyY = (Corners(2,3)-Corners(2,1))/res;
dxZ = (Corners(3,2)-Corners(3,1))/res;
dyZ = (Corners(3,3)-Corners(3,1))/res;


Output = [];

for y = 0:res
  
    
    for x = 0:res
        X = Corners(1,1) + x*dxX + y*dyX;
        Y = Corners(2,1) + x*dxY + y*dyY;
        Z = Corners(3,1) + x*dxZ + y*dyZ;
        newPoint = [X Y Z 1]';
        Output = [Output newPoint];
  
        
    end
end



end

