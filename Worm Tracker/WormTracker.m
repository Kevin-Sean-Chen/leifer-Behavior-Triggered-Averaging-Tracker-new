function varargout = WormTracker(varargin)
% WORMTRACKER M-file for WormTracker.fig
%      WORMTRACKER, by itself, creates a new WORMTRACKER or raises the existing
%      singleton*.
%
%      H = WORMTRACKER returns the handle to a new WORMTRACKER or the handle to
%      the existing singleton*.
%
%      WORMTRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMTRACKER.M with the given input arguments.
%
%      WORMTRACKER('Property','Value',...) creates a new WORMTRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WormTracker_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WormTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WormTracker

% Last Modified by GUIDE v2.5 11-Feb-2008 14:12:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WormTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @WormTracker_OutputFcn, ...
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



% --- Executes just before WormTracker is made visible.
function WormTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WormTracker (see VARARGIN)

% Choose default command line output for WormTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WormTracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global WormTrackerPrefs

% Get Tracker default Prefs from Excel file
ExcelFileName = 'C:\Matlab Functions\Worm Tracker Preferences';
WorkSheet = 'Tracker Prefs';
[N, T, D] = xlsread(ExcelFileName, WorkSheet);
WormTrackerPrefs.MinWormArea = N(1);
WormTrackerPrefs.MaxWormArea = N(2);
WormTrackerPrefs.MaxDistance = N(3);
WormTrackerPrefs.SizeChangeThreshold = N(4);
WormTrackerPrefs.MinTrackLength = N(5);
WormTrackerPrefs.AutoThreshold = N(6);
WormTrackerPrefs.CorrectFactor = N(7);
WormTrackerPrefs.ManualSetLevel = N(8);
WormTrackerPrefs.DarkObjects = N(9);
WormTrackerPrefs.PlotRGB = N(10);
WormTrackerPrefs.PauseDuringPlot = N(11);
WormTrackerPrefs.PlotObjectSizeHistogram = N(12);



% --- Outputs from this function are returned to the command line.
function varargout = WormTracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% -------------------------------------------------------------------------
% 'Create Functions' for all Text Edit Fields................
% -------------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
function MOVIE_NAME_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_NAME_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MOVIE_NAME_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_NAME_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_NAME_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_NAME_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_NAME_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_NAME_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_NAME_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_NAME_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_START_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_START_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_START_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_START_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_START_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_START_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_START_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_START_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_START_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_START_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_END_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_END_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_END_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_END_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_END_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_END_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_END_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_END_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MOVIE_END_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MOVIE_END_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PLOT_FRAME_RATE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PLOT_FRAME_RATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


