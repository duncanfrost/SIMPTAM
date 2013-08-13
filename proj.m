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

% Last Modified by GUIDE v2.5 12-Aug-2013 13:11:15

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

% UIWAIT makes proj wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function Init(handles, Path)


if strcmp(Path.type, 'straight');
    Map.points = passagegenerate(2,100,2, 1000);
    set(handles.viewtopdown,'YLim',[0 100]);
    
else
    Map.points = generateworldpoints3(10,3);
    set(handles.viewtopdown,'YLim',[-15 15]);
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
varargout{1} = handles.output;

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

CurrFrame_World.ImagePoints = makeimage(World.Camera, World.Map,0,false);
CurrFrame_PTAM.ImagePoints = makeimage(World.Camera, PTAM.Map,0,false);

displayimage(CurrFrame_World.ImagePoints,[1 0 0]);
displayimage(CurrFrame_PTAM.ImagePoints,[0 0 1]);
hold off;


% --- Executes on button press in pushbutton_path.
function pushbutton_path_Callback(~, ~, handles)
PTAM = getappdata(handles.figure1,'ptam');
Path = getappdata(handles.figure1,'path');

while PTAM.kfcount < 16
    PTAM = getappdata(handles.figure1,'ptam');
    PathStep(handles);
    
    if PTAM.run
        EstimateCamera(handles);
        AddKeyFrame(handles);
        RunScaleAdjustBA(handles);
    end

    UpdateTick(handles);
    drawnow;

    
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

% --- Executes on button press in pushbutton_cscale.
function pushbutton_cscale_Callback(~, ~, handles)
RunScaleAdjustBA(handles)

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
[PTAM World] = closeloop(PTAM, World);
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
outPTAM = localbundleadjust(PTAM, World,2);
PTAM = outPTAM;
setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);

function RunScaleAdjustBA(handles)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
load Constraints;

% ngtpoints = size(World.Map.points,2);
% C = zeros(ngtpoints,ngtpoints);

PTAM = scalebundleadjust(PTAM, World,4,2,C);

setappdata(handles.figure1,'ptam',PTAM);
UpdateTick(handles);


% --- Executes on button press in pushbutton_errorhist.
function pushbutton_errorhist_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_errorhist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
World = getappdata(handles.figure1,'world');
PTAM = getappdata(handles.figure1,'ptam');
[ ~, ~, errors] = calculateworlderror(World.Map, PTAM.Map);
figure;
bar(errors);


% --- Executes on button press in pushbutton_genconstraint.
function pushbutton_genconstraint_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_genconstraint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
World = getappdata(handles.figure1,'world');
load Frames;
counts = ones(17,1)*1;
C = constraintmatrix(Frames, World,counts);
save Constraints C;
display('Written constraint matrix');

