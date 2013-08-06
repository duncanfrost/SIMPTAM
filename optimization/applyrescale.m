function [ outPTAM ] = applyrescale(PTAM,World)


i1 = ProjectPoint(PTAM.Map.points(1), PTAM.KeyFrames(2).Camera.E);



npoints = size(PTAM.Map.points,2);


ptamCentre1 = camcentre(PTAM.KeyFrames(1).Camera.E);
ptamCentre2 = camcentre(PTAM.KeyFrames(2).Camera.E);
worldCentre1 = camcentre(World.KeyFrames(1).Camera.E);
worldCentre2 = camcentre(World.KeyFrames(2).Camera.E);



PTAMDiff = (ptamCentre2-ptamCentre1);
WorldDiff = (worldCentre2-worldCentre1);
ratio = norm(WorldDiff)/norm(PTAMDiff);


ncameras = size(PTAM.KeyFrames,2);

ptamCentre1 = -PTAM.KeyFrames(1).Camera.E(1:3,1:3)'*PTAM.KeyFrames(1).Camera.E(1:3,4);
for i = 2:ncameras
    ptamCentre2 = -PTAM.KeyFrames(i).Camera.E(1:3,1:3)'*PTAM.KeyFrames(i).Camera.E(1:3,4);
    PTAMDiff = (ptamCentre2-ptamCentre1);
    ptamCentre2n = ptamCentre1 + PTAMDiff*ratio;
    R = PTAM.KeyFrames(i).Camera.E(1:3,1:3);
    t = -R*ptamCentre2n(1:3);
    PTAM.KeyFrames(i).Camera.E(1:3,4) = t(1:3);
end




for j = 1:npoints
     pointWorld = double(PTAM.Map.points(j).location);

     
     pointCamera = PTAM.KeyFrames(1).Camera.E*pointWorld;
     pointCamera(1:3) = pointCamera(1:3)*ratio;
     Rinv = PTAM.KeyFrames(1).Camera.E(1:3,1:3)';
     tinv = -Rinv*PTAM.KeyFrames(1).Camera.E(1:3,4);
     Einv = [Rinv tinv; 0 0 0 1];
     PTAM.Map.points(j).location = Einv*pointCamera;
     
%      if norm(PTAM.Map.points(j).location-pointWorld) > 0
%          display('error');
%      end
     
     
       
end

i2 = ProjectPoint(PTAM.Map.points(1), PTAM.KeyFrames(2).Camera.E);

% display(i1);
% display(i2);

outPTAM = PTAM;




end

function [imagePoint] = ProjectPoint(worldPoint, E)
imagePoint = [0 0 1]';    
camPoint = E*worldPoint.location;
imagePoint(1) = camPoint(1) / camPoint(3);
imagePoint(2) = camPoint(2) / camPoint(3);
end

