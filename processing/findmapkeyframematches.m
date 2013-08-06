function [X x ids] = findmapkeyframematches(Map, KeyFrame,npoints,randomize)
%FINDMAPKEYFRAMEMATCHES Finds map points that have the same id's as those
%in a specified keyframe

X = [];
x = [];
ids = [];

if npoints > size(KeyFrame.ImagePoints,2) || npoints == 0
    npoints = size(KeyFrame.ImagePoints,2);
end

for i = 1:size(KeyFrame.ImagePoints,2)
    input(1:3,i) = KeyFrame.ImagePoints(i).location;
    input(4,i) = KeyFrame.ImagePoints(i).id;
end

if randomize
    input = input(:,randperm(size(input,2)));
end

for i = 1:npoints
    for j = 1:size(Map.points,2)
        if (Map.points(j).id == input(4,i))
            X = [X Map.points(j).location];
            ids = [ids Map.points(j).id];
            x = [x input(1:3,i)];
        end
    end
end


end

