function error = EstimateCamera(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

%framestatus = 1 just makes new frames, 2 creates new and saves them, 3
%uses previously saved frames.
framestatus = 3; 


if framestatus == 2 
    Frames = getappdata(handles.figure1,'frames');
end

if framestatus == 3 
	load Frames
else
    CurrFrame.ImagePoints = makeimage(World.Camera, World.Map,PTAM.noise,false);
end

if framestatus == 2 
    Frames(PTAM.kfcount + 1).ImagePoints = CurrFrame.ImagePoints;
end

if framestatus == 3  
    CurrFrame.ImagePoints = Frames(PTAM.kfcount + 1).ImagePoints;
end

CurrFrame = associatekeyframes(PTAM.KeyFrames(PTAM.kfcount),CurrFrame);

PTAM.CurrFrame = CurrFrame;

display('Estimating pose...');
PTAM = estimatepose(PTAM);
PTAM.CurrFrame.Camera = PTAM.Camera;
display('Done estimating!');

if framestatus == 2 
    setappdata(handles.figure1,'frames',Frames);
    save Frames Frames;
end

setappdata(handles.figure1,'ptam',PTAM);

end