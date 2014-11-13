function varargout = VideoCapture(varargin)
%VIDEOCAPTURE M-file for VideoCapture.fig
%      VIDEOCAPTURE, by itself, creates a new VIDEOCAPTURE or raises the existing
%      singleton*.
%
%      H = VIDEOCAPTURE returns the handle to a new VIDEOCAPTURE or the handle to
%      the existing singleton*.
%
%      VIDEOCAPTURE('Property','Value',...) creates a new VIDEOCAPTURE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to VideoCapture_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VIDEOCAPTURE('CALLBACK') and VIDEOCAPTURE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VIDEOCAPTURE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VideoCapture

% Last Modified by GUIDE v2.5 25-Jan-2007 12:26:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VideoCapture_OpeningFcn, ...
                   'gui_OutputFcn',  @VideoCapture_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before VideoCapture is made visible.
function VideoCapture_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VideoCapture (see VARARGIN)

% Choose default command line output for VideoCapture
handles.output = hObject;

global vid
global VideoPrefs

% Get Video Prefs from Excel File
ExcelFileName = 'C:\Matlab Functions\Worm Tracker Preferences';
WorkSheet = 'Video Capture Prefs';
[N, T, D] = xlsread(ExcelFileName, WorkSheet);
VideoPrefs.SampleRate = N(1);
VideoPrefs.ExperimentDuration = N(2);
VideoPrefs.CaptureEvery = N(3);
VideoPrefs.CaptureTime = N(4);
VideoPrefs.savePath = T{5,2};
VideoPrefs.saveName = T{6,2};
VideoPrefs.AdaptorName = T{7,2};
VideoPrefs.VideoFormat = T{8,2};

% Close and delete all exisiting video objects
out = imaqfind;
if ~isempty(out)
    delete(out);
    clear out;
end

% create global video object, so it can be used in any callback...
vid = videoinput(VideoPrefs.AdaptorName, 1, VideoPrefs.VideoFormat);
vid.LoggingMode = 'memory';
vid.StopFcn = 'StopVidCapture';


% Set text fields in GUI to default values
set(findobj('Tag', 'savePath'), 'String', VideoPrefs.savePath);
set(findobj('Tag', 'saveName'), 'String', VideoPrefs.saveName);
set(findobj('Tag', 'ExperimentDuration'), 'String', num2str(VideoPrefs.ExperimentDuration));
set(findobj('Tag', 'CaptureEvery'), 'String', num2str(VideoPrefs.CaptureEvery));
set(findobj('Tag', 'CaptureTime'), 'String', num2str(VideoPrefs.CaptureTime));

% Initialize Gain Slider
InitGain = get(getselectedsource(vid), 'Gain');
set(findobj('Tag', 'camGain'),  ...
    'SliderStep', [1,10]/(2228-2048), ...
    'Max', 2228, ...
    'Min', 2048, ...
    'Value', InitGain);
set(findobj('Tag', 'GainValue'), 'String', num2str(InitGain));


% Initialize Shutter Slider
InitShutter = get(getselectedsource(vid), 'Shutter');
set(findobj('Tag', 'camShutter'),  ...
    'SliderStep', [1,10]/(3119-1928), ...
    'Max', 3119, ...
    'Min', 1928, ...
    'Value', InitShutter);
set(findobj('Tag', 'ShutterValue'), 'String', num2str(InitShutter));

% Update handles structure
guidata(hObject, handles);



% --------------------------------------------------------------------------
% --- Excutes when VideoCapture is closed
function VideoCapture_Close(hObject, eventdata, handles)

%  Close and delete video object
global vid

if ~isempty(vid)
    if strcmp(vid.Previewing, 'on')
        closepreview(vid)
    end
    delete(vid)
    clear vid
end

closereq



% --- Outputs from this function are returned to the command line.
function varargout = VideoCapture_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------------
% --- Executes on button press in Preview.
function Preview_Callback(hObject, eventdata, handles)
% hObject    handle to Preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global vid
preview(vid);



% --- Executes on slider movement.
function camGain_Callback(hObject, eventdata, handles)
% hObject    handle to camGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global vid

Gain = round(get(hObject, 'Value'));
set(getselectedsource(vid), 'Gain', Gain);
set(findobj('Tag', 'GainValue'), 'String', num2str(Gain));



% --- Executes on slider movement.
function camShutter_Callback(hObject, eventdata, handles)
% hObject    handle to camShutter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global vid

Shutter = round(get(hObject, 'Value'));
set(getselectedsource(vid), 'Shutter', Shutter);
set(findobj('Tag', 'ShutterValue'), 'String', num2str(Shutter));


