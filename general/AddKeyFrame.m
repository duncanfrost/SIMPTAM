function AddKeyFrame(handles)

PTAM = getappdata(handles.figure1,'ptam');
World = getappdata(handles.figure1,'world');

PTAM.kfcount = PTAM.kfcount + 1;
PTAM.KeyFrames(PTAM.kfcount) = PTAM.CurrFrame;

CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,0,false);
CurrFrame.Camera = World.Camera;
World.KeyFrames(PTAM.kfcount) = CurrFrame;

% Add some world points from this keyframe
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

setappdata(handles.figure1,'ptam',PTAM);
setappdata(handles.figure1,'world',World);
end