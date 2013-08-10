function [X x ids] = findmapkeyframematches(Map, KeyFrame)
%FINDMAPKEYFRAMEMATCHES Finds map points that have the same id's as those
%in a specified keyframe

X = [];
x = [];
ids = [];

for i = 1:size(KeyFrame.ImagePoints,2)
    for j = 1:size(Map.points,2)
        if (Map.points(j).id == KeyFrame.ImagePoints(i).id)
            X = [X Map.points(j).location];
            ids = [ids Map.points(j).id];
            x = [x input(1:3,i)];
        end
    end
end


end

