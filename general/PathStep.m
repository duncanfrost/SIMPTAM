function PathStep(handles)
World = getappdata(handles.figure1,'world');
Path = getappdata(handles.figure1,'path');

Path.time = Path.time + Path.dtheta;
[dt, angle] = genpath(Path.time, Path.dtheta, Path.radius, Path.type);
World.Camera = movecamera(World.Camera,dt,angle,true);

setappdata(handles.figure1,'world', World);
setappdata(handles.figure1,'path', Path);
end