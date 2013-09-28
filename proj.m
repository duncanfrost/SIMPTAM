function varargout = proj(varargin)
% PROJ MATLAB code for proj.fig
%      PROJ, by itself, creates a new PROJ or raises the existing
%      singleton*.
%
%      H = PROJ returns the handle to a new PROJ or the handle to
%      the existing singleton*.
%
%      PROJ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJ.M with the given input arguments.
%
%      PROJ('Property','Value',...) creates a new PROJ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before proj_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to proj_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help proj

% Last Modified by GUIDE v2.5 18-Sep-2013 11:15:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @proj_OpeningFcn, ...
    'gui_OutputFcn',  @proj_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before proj is made visible.
function proj_OpeningFcn(hObject, eventdata, handles, varargin)
clc;


movegui(hObject,'east');

a = getappdata(0,'inarg');
s = RandStream('mt19937ar','Seed',1);
RandStream.setGlobalStream(s);
          
          

addpath('gui');
addpath('geometry');
addpath('processing');
addpath('optimization');
addpath('rotations');
addpath('worldgeneration');
addpath('pathgeneration');
addpath('posegraph');
addpath('localbundle');
addpath('abfilter');
addpath('scale');
addpath('dataassociation');
addpath('drawing');
addpath('general');
addpath('datacollection');

set(handles.checkbox_runptam, 'Value',1);


Path.dtheta = 2*pi/20;
Path.time = 0;
% Path.type = 'straight';
Path.type = 'tangentcircle';
Path.radius = 8;

setappdata(handles.figure1,'path',Path);


Init(handles, Path);
NoisyInit(handles);
UpdateTick(handles);


% Choose default command line output for proj
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%pushbutton_path_Callback(0,0,handles);


% UIWAIT makes proj wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function Init(handles, Path)

loadfromframes = false;


if loadfromframes
    load Map;
    set(handles.viewtopdown,'YLim',[-15 15]);
else
    if strcmp(Path.type, 'straight');
        Map.points = passagegenerate(2,100,2, 1000);
        set(handles.viewtopdown,'YLim',[0 100]);
        
    else
        Map.points = generateworldpoints3(10,3);
        set(handles.viewtopdown,'YLim',[-15 15]);
    end
end



Camera.f = 0.5;
ay = 480*Camera.f;
ax = 640*Camera.f;
u0 = 640/2;
v0 = 480/2;
Camera.K = [ax 0 u0; 0 ay v0; 0 0 1];


Camera.thetax = 0;
Camera.thetay = pi/2;
Camera.thetaz = 0;
Camera.E = eye(4,4);

[trans, angle] = genpath(Path.time, Path.dtheta, Path.radius, Path.type);
Camera = movecamera(Camera,trans,angle,true);

World.Camera = Camera;
World.Map = Map;
PTAM.Camera = Camera;

PTAM.Map = [];
PTAM.Map.points(1).location = [0 0 0 0]';
PTAM.Map.points(1).id = 1;
PTAM.Map.points(1).gtid = [];
PTAM.velocity = zeros(6,1);
PTAM.position = zeros(6,1);
PTAM.iter = 0;
PTAM.storage = [];
PTAM.kfcount = 0;
PTAM.noise = 1;
PTAM.run = true;
PTAM.mapcount = 0;
setappdata(handles.figure1,'world',World);
setappdata(handles.figure1,'ptam',PTAM);

% --- Outputs from this function are returned to the command line.
function varargout = proj_OutputFcn(~, ~, handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

varargout{1} = PTAM;
varargout{2} = World;

%close all;

% --- Executes on button press in pushbutton_w.
function pushbutton_w_Callback(~, ~, handles)
ManualMove(handles, [0 0 1 0]', 0);

% --- Executes on button press in pushbutton_d.
function pushbutton_d_Callback(~, ~, handles)
ManualMove(handles, [1 0 0 0]', 0);

% --- Executes on button press in pushbutton_s.
function pushbutton_s_Callback(~, ~, handles)
ManualMove(handles, [0 0 -1 0]', 0);

% --- Executes on button press in pushbutton_a.
function pushbutton_a_Callback(~, ~, handles)
ManualMove(handles, [-1 0 0 0]', 0);

% --- Executes on button press in pushbutton_right.
function pushbutton_right_Callback(~, ~, handles)
ManualMove(handles, [], 0.1);

% --- Executes on button press in pucamerashbutton_left.
function pushbutton_left_Callback(~, ~, handles)
ManualMove(handles, [], -0.1);

function ManualMove(handles, translation, angle)
World = getappdata(handles.figure1,'world');
World.Camera = movecamera(World.Camera,translation,angle,false);
setappdata(handles.figure1,'world',World);
UpdateTick(handles);

function DisplayFrame(handles , AxesHandle)
cla(AxesHandle);
axes(AxesHandle);
hold on;

World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

CurrFrame_World.ImagePoints = makeimage(World.Camera, World.Map,0,false,0);
CurrFrame_PTAM.ImagePoints = makeimage(World.Camera, PTAM.Map,0,false,0);

displayimage(CurrFrame_World.ImagePoints,[1 0 0]);
displayimage(CurrFrame_PTAM.ImagePoints,[0 0 1]);
hold off;


% --- Executes on button press in pushbutton_path.
function pushbutton_path_Callback(~, ~, handles)
PTAM = getappdata(handles.figure1,'ptam');
Path = getappdata(handles.figure1,'path');

while PTAM.kfcount < 18
    
    PathStep(handles);
    
    if PTAM.run
        EstimateCamera(handles);
        AddKeyFrame(handles);
        RunLocalScaleAdjustBA(handles);
%     RunLocalBA(handles);
        
    end
    
%     UpdateTick(handles);
%     drawnow;    
    PTAM = getappdata(handles.figure1,'ptam');
end






function UpdateTick(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
displayerror(handles);
DisplayFrame(handles, handles.view3d);
displaytopdown(World, PTAM, handles.viewtopdown,true,true);

% --- Executes on button press in pushbutton_estcam.
function pushbutton_estcam_Callback(hObject, eventdata, handles)
EstimateCamera(handles);
UpdateTick(handles);

% --- Executes on button press in pushbutton_update.
function pushbutton_update_Callback(hObject, eventdata, handles)
UpdateTick(handles);

% --- Executes on button press in pushbutton_addkeyframe.
function pushbutton_addkeyframe_Callback(hObject, eventdata, handles)
AddKeyFrame(handles);

% --- Executes on button press in pushbutton_pathstep.
function pushbutton_pathstep_Callback(hObject, eventdata, handles)
PTAM = getappdata(handles.figure1,'ptam');
PathStep(handles);
if PTAM.run
    EstimateCamera(handles);
    
    AddKeyFrame(handles);
    %     RunScaleAdjustBA(handles);
end

UpdateTick(handles);
drawnow;

% --- Executes on button press in pushbutton_displaykf.
function pushbutton_displaykf_Callback(hObject, eventdata, handles)
PTAM = getappdata(handles.figure1,'ptam');
DisplayKeyFrames(PTAM.KeyFrames, handles.viewtopdownest);

% --- Executes on button press in pushbutton_bundle.
function pushbutton_bundle_Callback(hObject, eventdata, handles)
PTAM = getappdata(handles.figure1,'ptam');
World = getappdata(handles.figure1,'world');
PTAM = bundleadjust(PTAM,World);
PTAM.Camera = PTAM.KeyFrames(PTAM.kfcount).Camera;
setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);

% --- Executes on button press in pushbutton_view3d.
function pushbutton_view3d_Callback(hObject, eventdata, handles)
view3d(handles);

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
Path = getappdata(handles.figure1,'path');
save DATA World PTAM Path


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
load DATA
setappdata(handles.figure1,'world',World);
setappdata(handles.figure1,'ptam',PTAM);
setappdata(handles.figure1,'path',Path);
UpdateTick(handles);


% --- Executes on button press in pushbutton_posegraph.
function pushbutton_posegraph_Callback(hObject, eventdata, handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
Ext = getappdata(handles.figure1,'ext');
display('applying pose graph optimization');
PTAM = posegraph2(PTAM,World,Ext);
setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);


% --- Executes on button press in pushbutton_constraints.
function pushbutton_constraints_Callback(hObject, eventdata, handles)
display('Calculating constraints');
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
for i = 1:size(PTAM.KeyFrames,2)
    
    if i == size(PTAM.KeyFrames,2)
        j = 1;
    else
        j = i + 1;
    end
    
    W12 = World.KeyFrames(i).Camera.E/World.KeyFrames(j).Camera.E;
    tprior = -W12(1:3,1:3)*W12(1:3,4);
    pl = norm(tprior);
    
    %     [Ext{i} E1 F1] = calculateext(PTAM.KeyFrames(i),PTAM.KeyFrames(j),PTAM.KeyFrames(i).Camera.K,pl);
    ExtGT{i} = World.KeyFrames(j).Camera.E/World.KeyFrames(i).Camera.E;
    
    if i == size(PTAM.KeyFrames,2)
        Ext{i} = ExtGT{i};
    else
        Ext{i} = PTAM.KeyFrames(j).Camera.E/PTAM.KeyFrames(i).Camera.E;
    end
    
    %     Ext{i} = ExtGT{i};
    
end
setappdata(handles.figure1,'ext',Ext);
display('done');

% --- Executes on button press in pushbutton_localba.
function pushbutton_localba_Callback(~, ~, handles)
RunLocalBA(handles)

% --- Executes on button press in pushbutton_scale.
function pushbutton_scale_Callback(~, ~, handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
measurescale(PTAM, World);

% --- Executes on button press in pushbutton_localscale.
function pushbutton_localscale_Callback(~, ~, handles)
RunLocalScaleAdjustBA(handles)

% --- Executes on selection change in popupmenu_dataset.
function popupmenu_dataset_Callback(hObject, ~, handles)
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
    case 'Loop Tangent Direction'
        Path.radius = 8;
        Path.type = 'tangentcircle';
        
    case 'Loop Normal Direction'
        Path.radius = 8;
        Path.type = 'normalcircle';
    case 'Passage'
        Path.type = 'straight';
        Path.radius = 0;
        
end

Path.dtheta = 2*pi/20;
Path.time = 0;
setappdata(handles.figure1,'path',Path);

Init(handles,Path);
SimpleInit(handles);
UpdateTick(handles);

% Save the handles structure.
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_dataset_CreateFcn(hObject, ~, ~)

strings{1} = 'Loop Tangent Direction';
strings{2} = 'Loop Normal Direction';
strings{3} = 'Passage';
set(hObject,'String',strings);
set(hObject,'Value',1);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end

% --- Executes on button press in checkbox_runptam.
function checkbox_runptam_Callback(hObject, ~, handles)
val = get(hObject,'Value');
PTAM = getappdata(handles.figure1,'ptam');

if val == 1
    PTAM.run = true;
else
    PTAM.run = false;
end

setappdata(handles.figure1,'ptam',PTAM);

% --- Executes on button press in pushbutton_closeloop.
function pushbutton_closeloop_Callback(~, ~, handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
[PTAM, World] = closeloop(PTAM, World);
setappdata(handles.figure1,'ptam',PTAM);
setappdata(handles.figure1,'world',World);
UpdateTick(handles);

% --- Executes on button press in pushbutton_kfdisplay.
function pushbutton_kfdisplay_Callback(~, ~, handles)
PTAM = getappdata(handles.figure1,'ptam');
plotkeyframe(PTAM.KeyFrames(PTAM.kfcount));
plotkeyframe(PTAM.KeyFrames(PTAM.kfcount-1));

% --- Executes on button press in pushbutton_settogt.
function pushbutton_settogt_Callback(~, ~, handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
outPTAM = settogt(PTAM, World);
setappdata(handles.figure1,'ptam',outPTAM);
UpdateTick(handles);

% --- Executes on button press in pushbutton_checkids.
function pushbutton_checkids_Callback(~, ~, handles)
PTAM = getappdata(handles.figure1,'ptam');
checkforemptyids(PTAM);

function RunLocalBA(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
outPTAM = localbundleadjust(PTAM, World,4);
PTAM = outPTAM;
setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);

function RunLocalScaleAdjustBA(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
load Constraints;

% ngtpoints = size(World.Map.points,2);
% C = zeros(ngtpoints,ngtpoints);

PTAM = scalebundleadjust(PTAM, World,4,2,C);

setappdata(handles.figure1,'ptam',PTAM);
% UpdateTick(handles);



function RunGlobalScaleAdjustBA(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
load Constraints;

ngtpoints = size(World.Map.points,2);
C = zeros(ngtpoints,ngtpoints);


nConstraints = 20;
[ vConstraints ] = generateconstraints(PTAM, World, nConstraints);

% vConstraints{1}.p1 = 1;
% vConstraints{1}.p2 = 6;
% vConstraints{1}.value = 1;
% 
% vConstraints{2}.p1 = 5;
% vConstraints{2}.p2 = 7;
% vConstraints{2}.value = 1;
% 
% vConstraints{3}.p1 = 3;
% vConstraints{3}.p2 = 4;
% vConstraints{3}.value = 1;
%vConstraints = [];

    


kfcount = size(PTAM.KeyFrames,2);




PTAM = globalscalebundleadjust(PTAM, World,kfcount,4,vConstraints);

setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);

function C = AddConstraint(C,p1,p2,World)
l1 = World.Map.points(p1).location;
l2 = World.Map.points(p2).location;

D = [l1(1)-l2(1) l1(2)-l2(2) l1(3)-l2(3)]';
D = D'*D;
D = sqrt(D);


C(p1,p2) = D;





% --- Executes on button press in pushbutton_genconstraint.
function pushbutton_genconstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_genconstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
World = getappdata(handles.figure1,'world');
% load Frames;
Frames = PTAM.KeyFrames;
counts = ones(18,1);
% counts = 200000;
C = constraintmatrix(Frames, World,counts);
save Constraints C;
display('Written constraint matrix');






% --- Executes on button press in pushbutton_globalscale.
function pushbutton_globalscale_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_globalscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunGlobalScaleAdjustBA(handles);


% --- Executes on button press in pushbutton_camadjust.
function pushbutton_camadjust_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_camadjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');

PTAM = camadjust(PTAM, World);

setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);


% ---  Executes on button press in pushbutton_writetofiles.
function pushbutton_writetofiles_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writetofiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PTAM = getappdata(handles.figure1,'ptam');
World = getappdata(handles.figure1,'world');

%Write Camera Stuff
fCams = fopen('Cams.txt','w');
for i = 1:size(PTAM.KeyFrames,2)
    log = logmap(PTAM.KeyFrames(i).Camera.E);
    for j = 1:6
        fprintf(fCams,'%d ',double(log(j)));
    end
    display(logmap(PTAM.KeyFrames(i).Camera.E));
    display(expmap(logmap(PTAM.KeyFrames(i).Camera.E)));
    display(PTAM.KeyFrames(i).Camera.E);
end
fclose(fCams);

pointCount = 0;
fPoints = fopen('Points.txt','w');
for i = 1:size(PTAM.Map.points,2)
    location = PTAM.Map.points(i).location;
    for j = 1:3
        fprintf(fPoints,'%f ',double(location(j)));
        pointCount = pointCount+1;
    end
    
    fprintf(fPoints,'%f ',double(PTAM.Map.points(i).gtid));
   
end
fclose(fPoints);

fGTPoints = fopen('GTPoints.txt','w');
for i = 1:size(World.Map.points,2)
    location = World.Map.points(i).location;
    for j = 1:3
        fprintf(fGTPoints,'%f ',double(location(j)));
    end
end
fclose(fGTPoints);

fMeas= fopen('Meas.txt','w');
for i = 1:size(PTAM.KeyFrames,2)
    
    
    for j = 1:size(PTAM.KeyFrames(i).ImagePoints,2)
        if ~isempty(PTAM.KeyFrames(i).ImagePoints(j).id)
            
            fprintf(fMeas,'%d ',double(i));
            fprintf(fMeas,'%d ',double(PTAM.KeyFrames(i).ImagePoints(j).id));
            fprintf(fMeas,'%d ',double(PTAM.KeyFrames(i).ImagePoints(j).location(1)));
            fprintf(fMeas,'%d ',double(PTAM.KeyFrames(i).ImagePoints(j).location(2)));
        end
    end
   
end

fclose(fMeas);


% --- Executes on button press in pushbutton_kfdistances.
function pushbutton_kfdistances_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_kfdistances (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PTAM = getappdata(handles.figure1,'ptam');
World = getappdata(handles.figure1,'world');

pc1 = camcentre(PTAM.KeyFrames(1).Camera.E);
pc2 = camcentre(PTAM.KeyFrames(2).Camera.E);

wc1 = camcentre(World.KeyFrames(1).Camera.E);
wc2 = camcentre(World.KeyFrames(2).Camera.E);

pdiff = norm(pc1 - pc2);
wdiff = norm(wc1 - wc2);

display(pdiff);
display(wdiff);


% --- Executes on button press in pushbutton_loadfromc.
function pushbutton_loadfromc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadfromc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PTAM = getappdata(handles.figure1,'ptam');
row = 1;
cpointsraw = load('/home/avlinux/Working/PTAM2/PTAM/outpoints.txt');
for i = 1:size(PTAM.Map.points,2)
        

        PTAM.Map.points(i).location(1) = cpointsraw(row);
        row = row + 1;
        PTAM.Map.points(i).location(2) = cpointsraw(row);
        row = row + 1;
        PTAM.Map.points(i).location(3) = cpointsraw(row);
        row = row + 1;
end


ccamsraw = load('/home/avlinux/Working/PTAM2/PTAM/outcams.txt');
mu = zeros(6,1);
row = 1;
for i = 1:size(PTAM.KeyFrames,2)
    mu(1) = ccamsraw(row);
    row = row + 1;
    mu(2) = ccamsraw(row);
    row = row + 1;
    mu(3) = ccamsraw(row);
    row = row + 1;
    mu(4) = ccamsraw(row);
    row = row + 1;
    mu(5) = ccamsraw(row);
    row = row + 1;
    mu(6) = ccamsraw(row);
    row = row + 1;
    PTAM.KeyFrames(i).Camera.E = expmap(mu);
end


setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);



   


% --- Executes on button press in pushbutton_writeconstraints.
function pushbutton_writeconstraints_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeconstraints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PTAM = getappdata(handles.figure1,'ptam');
World = getappdata(handles.figure1,'world');

nPoints = size(PTAM.Map.points,2);
nConstraints = 20000;

fConstraints = fopen('Constraints.txt','w');

for i = 1:nConstraints

    p1 = randi([1 nPoints]);
    p2 = randi([1 nPoints]);

    while (p2 == p1)
        p2 = randi([1 nPoints]);
    end


    gtid1 = PTAM.Map.points(p1).gtid;
    gtid2 = PTAM.Map.points(p2).gtid;


    location1 = World.Map.points(gtid1).location;
    location2 = World.Map.points(gtid2).location;

    value = norm(location1-location2);


    fprintf(fConstraints,'%d ',p1);
    fprintf(fConstraints,'%d ',p2);
    fprintf(fConstraints,'%d ',double(value));

end


fclose(fConstraints);










