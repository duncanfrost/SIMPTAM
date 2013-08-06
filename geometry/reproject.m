function [ outpoints ] = reproject(KeyFrame1, KeyFrame2)

E1 = KeyFrame1.Camera.E(1:3,:);
E2 = KeyFrame2.Camera.E(1:3,:);
K = KeyFrame1.Camera.K;


X = [];

[kf1points kf2points ids] = findkfkfmatches(KeyFrame1, KeyFrame2);
kf1points = removeintrinsics(kf1points,K);
kf2points = removeintrinsics(kf2points,K);
outpoints = [];
XX = [];
for i = 1:size(kf1points,2)
    newpoint = linearreproject(kf1points(:,i),kf2points(:,i),E1,E2);
    if ~isempty(newpoint)
        XX = [XX newpoint];
        outpoints(i).location = newpoint;
        outpoints(i).id = ids(i);
    end
end


end




