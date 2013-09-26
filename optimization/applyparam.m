function [outPTAM] = applyparam(PTAM, param)
%APPLYPARAM Summary of this function goes here
%   Detailed explanation goes here

ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);

for i = 1:ncameras
    if i > 1
        mu = param(1 + 6*(i-2):6 + 6*(i-2));
        change = expmap(mu);
        PTAM.KeyFrames(i).Camera.E = change*PTAM.KeyFrames(i).Camera.E;
    end
end

for j = 1:npoints
    PTAM.Map.points(j).location(1:3) = PTAM.Map.points(j).location(1:3) + param((ncameras-1)*6 + 1 + 3*(j-1):(ncameras-1)*6 + 3 + 3*(j-1));
end

outPTAM = PTAM;
        

end

