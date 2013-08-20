function [ PTAM ] = removescaledrift(PTAM, World)


ptamCentre2 = camcentre(PTAM.Camera.E);
ptamCentre1 = camcentre(PTAM.KeyFrames(PTAM.kfcount).Camera.E);
worldCentre2 = camcentre(World.Camera.E);
worldCentre1 = camcentre(World.KeyFrames(PTAM.kfcount).Camera.E);


PTAMDiff = (ptamCentre2-ptamCentre1);
WorldDiff = (worldCentre2-worldCentre1);
ratio = norm(WorldDiff)/norm(PTAMDiff);

ptamCentre2n = ptamCentre1 + PTAMDiff*ratio;

R = PTAM.Camera.E(1:3,1:3);
t = -R*ptamCentre2n(1:3);
PTAM.Camera.E(1:3,4) = t(1:3);


display(ratio);


ptamCentre2 = camcentre(PTAM.Camera.E);
ptamCentre1 = camcentre(PTAM.KeyFrames(PTAM.kfcount).Camera.E);
worldCentre2 = camcentre(World.Camera.E);
worldCentre1 = camcentre(World.KeyFrames(PTAM.kfcount).Camera.E);


PTAMDiff = (ptamCentre2-ptamCentre1);
WorldDiff = (worldCentre2-worldCentre1);
ratio = norm(WorldDiff)/norm(PTAMDiff);

display(ratio);




setappdata(handles.figure1,'ptam',PTAM);
setappdata(handles.figure1,'world',World);

end

