function [kf1points, kf2points, ids] = findkfkfmatches(KeyFrame1, KeyFrame2)
%FINDKFKFMATCHES Summary of this function goes here
%   Detailed explanation goes here

kf1points = [];
kf2points = [];
ids = [];

for i = 1:length(KeyFrame1.ImagePoints)
    for j = 1:length(KeyFrame2.ImagePoints)
        if (KeyFrame1.ImagePoints(i).id == KeyFrame2.ImagePoints(j).id)
            
            kf1p = KeyFrame1.ImagePoints(i).location;
            kf2p = KeyFrame2.ImagePoints(j).location;
            
            kf1points = [kf1points kf1p];
            kf2points = [kf2points kf2p];
            ids = [ids KeyFrame1.ImagePoints(i).id];
            %             X = [X inpoints(KeyFrame1.ImagePoints(i).id).location];
            
        end
        
    end
end



end

