function [ ids ] = findpoints(Keyframe, ImagePoints)
ids = [];
for i = 1:size(ImagePoints,2)
    for j = 1:size(Keyframe.ImagePoints,2)
        if ImagePoints(i).id == Keyframe.ImagePoints(j).id
            ids =[ids ImagePoints(i).id];
        end
    end
end





end

