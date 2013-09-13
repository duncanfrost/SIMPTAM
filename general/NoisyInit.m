function NoisyInit(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

framestatus = 1; 



CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,0,false,1);
CurrFrame.Camera = World.Camera;


World.KeyFrames(1) = CurrFrame;



PTAM.kfcount = 1;


if framestatus == 3
    load Frames;
    CurrFrame.ImagePoints = Frames(1).ImagePoints;
    
else
    CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,PTAM.noise,false,1);
end



PTAM.KeyFrames(1).ImagePoints = CurrFrame.ImagePoints;
PTAM.KeyFrames(1).Camera = World.Camera;
Frames(1) = CurrFrame;

setappdata(handles.figure1,'world',World);
PathStep(handles);
World = getappdata(handles.figure1,'world');

CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,0,false,1);
CurrFrame.Camera = World.Camera;
World.KeyFrames(2) = CurrFrame;


if framestatus == 3
    load Frames;
    CurrFrame.ImagePoints = Frames(2).ImagePoints;
else
    CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,PTAM.noise,false,2);
end


PTAM.KeyFrames(2).ImagePoints = CurrFrame.ImagePoints;
PTAM.KeyFrames(2).Camera = World.Camera;
Frames(2) = CurrFrame;
PTAM.kfcount = 2;
   

PTAM.Camera = World.Camera;



KeyFrame1 = PTAM.KeyFrames(PTAM.kfcount);

KeyFrame2 = PTAM.KeyFrames(PTAM.kfcount-1);


if ~isempty(KeyFrame2)
    [m1 m2] = findunassmatches(KeyFrame1, KeyFrame2);
    
    [KeyFrame1, KeyFrame2, PTAM, World ] = reprojectselective(KeyFrame1, KeyFrame2,m1,m2, PTAM, World);
    
    PTAM.KeyFrames(PTAM.kfcount) = KeyFrame1;
    PTAM.KeyFrames(PTAM.kfcount-1) = KeyFrame2;
   
    pointsadded = size(m1,2);
    display([int2str(pointsadded) ' points added']);
end




% PTAM = bundleadjust(PTAM,World);




setappdata(handles.figure1,'ptam',PTAM);
setappdata(handles.figure1,'world',World);
setappdata(handles.figure1,'frames',Frames);

end