function SimpleInit(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,0,false);
CurrFrame.Camera = World.Camera;

for i = 1:size(CurrFrame.ImagePoints,2)
    PTAM.mapcount = PTAM.mapcount + 1;
    CurrFrame.ImagePoints(i).id = PTAM.mapcount;
    gtid = CurrFrame.ImagePoints(i).gtid;
    gtlocation = World.Map.points(gtid).location;
    
    PTAM.Map.points(PTAM.mapcount).location = gtlocation;
    PTAM.Map.points(PTAM.mapcount).gtid = gtid;
    PTAM.Map.points(PTAM.mapcount).id = PTAM.mapcount;
    
    World.Map.points(gtid).estids = [World.Map.points(gtid).estids PTAM.mapcount];
    
end



PTAM.Camera = World.Camera;
PTAM.Camera.se3 = [-8 0 0 0 0 0]';


World.KeyFrames(1) = CurrFrame;

% CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,PTAM.noise,false);

PTAM.KeyFrames(1).ImagePoints = CurrFrame.ImagePoints;
PTAM.KeyFrames(1).Camera = World.Camera;
PTAM.KeyFrames(1).Camera.se3 = [-8 0 0 0 0 0]';

PTAM.kfcount = 1;


Frames(1) = CurrFrame;

setappdata(handles.figure1,'ptam',PTAM);
setappdata(handles.figure1,'world',World);
setappdata(handles.figure1,'frames',Frames);
