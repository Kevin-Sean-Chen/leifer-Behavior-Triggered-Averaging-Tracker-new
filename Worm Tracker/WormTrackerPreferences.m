function varargout = WormTrackerPreferences(varargin)
% WORMTRACKERPREFERENCES M-file for WormTrackerPreferences.fig
%      WORMTRACKERPREFERENCES, by itself, creates a new WORMTRACKERPREFERENCES or raises the existing
%      singleton*.
%
%      H = WORMTRACKERPREFERENCES returns the handle to a new WORMTRACKERPREFERENCES or the handle to
%      the existing singleton*.
%
%      WORMTRACKERPREFERENCES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMTRACKERPREFERENCES.M with the given input arguments.
%
%      WORMTRACKERPREFERENCES('Property','Value',...) creates a new WORMTRACKERPREFERENCES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WormTrackerPreferences_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WormTrackerPreferences_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WormTrackerPreferences

% Last Modified by GUIDE v2.5 11-Feb-2008 17:05:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WormTrackerPreferences_OpeningFcn, ...
                   'gui_OutputFcn',  @WormTrackerPreferences_OutputFcn, ...
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


% --- Executes just before WormTrackerPreferences is made visible.
function WormTrackerPreferences_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WormTrackerPreferences (see VARARGIN)

% Choose default command line output for WormTrackerPreferences
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WormTrackerPreferences wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global WormTrackerPrefs

set(findobj('Tag', 'MIN_WORM_AREA'), 'String', num2str(WormTrackerPrefs.MinWormArea))
set(findobj('Tag', 'MAX_WORM_AREA'), 'String', num2str(WormTrackerPrefs.MaxWormArea))
set(findobj('Tag', 'MAX_DISTANCE'), 'String', num2str(WormTrackerPrefs.MaxDistance))
set(findobj('Tag', 'MAX_SIZE_CHANGE'), 'String', num2str(WormTrackerPrefs.SizeChangeThreshold))
set(findobj('Tag', 'MIN_TRACK_LENGTH'), 'String', num2str(WormTrackerPrefs.MinTrackLength))

set(findobj('Tag', 'USE_AUTO_THRESH'), 'Value', WormTrackerPrefs.AutoThreshold)
set(findobj('Tag', 'CORRECT_FACTOR'), 'String', num2str(WormTrackerPrefs.CorrectFactor))
set(findobj('Tag', 'MANUAL_LEVEL'), 'String', num2str(WormTrackerPrefs.ManualSetLevel))
set(findobj('Tag', 'DARK_OBJECTS_WHITE_BKGD'), 'Value', WormTrackerPrefs.DarkObjects)
set(findobj('Tag', 'WHITE_OBJECTS_DARK_BKGD'), 'Value', ~WormTrackerPrefs.DarkObjects)
USE_AUTO_THRESH_Callback(hObject, eventdata, handles);

set(findobj('Tag', 'PLOT_RGB'), 'Value', WormTrackerPrefs.PlotRGB)
set(findobj('Tag', 'PAUSE_TRACKER'), 'Value', WormTrackerPrefs.PauseDuringPlot)
set(findobj('Tag', 'PLOT_AREA_HIST'), 'Value', WormTrackerPrefs.PlotObjectSizeHistogram)




% --- Outputs from this function are returned to the command line.
function varargout = WormTrackerPreferences_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in USE_AUTO_THRESH.
function USE_AUTO_THRESH_Callback(hObject, eventdata, handles)
% hObject    handle to USE_AUTO_THRESH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_AUTO_THRESH

if get(findobj('Tag', 'USE_AUTO_THRESH'), 'Value')
    set(findobj('Tag', 'CORRECT_FACTOR_TEXT'), 'Enable', 'On')
    set(findobj('Tag', 'CORRECT_FACTOR'), 'Enable', 'On')
    set(findobj('Tag', 'MANUAL_LEVEL_TEXT'), 'Enable', 'Off')
    set(findobj('Tag', 'MANUAL_LEVEL'), 'Enable', 'Off')
else
    set(findobj('Tag', 'CORRECT_FACTOR_TEXT'), 'Enable', 'Off')
    set(findobj('Tag', 'CORRECT_FACTOR'), 'Enable', 'Off')
    set(findobj('Tag', 'MANUAL_LEVEL_TEXT'), 'Enable', 'On')
    set(findobj('Tag', 'MANUAL_LEVEL'), 'Enable', 'On')
end    
    



% --- Executes on button press in OK_TRACKER_PREFS.
function OK_TRACKER_PREFS_Callback(hObject, eventdata, handles)
% hObject    handle to OK_TRACKER_PREFS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ApplyPrefsChanges;
closereq;



% --- Executes on button press in SAVE_TRACKER_PREFS.
function SAVE_TRACKER_PREFS_Callback(hObject, eventdata, handles)
% hObject    handle to SAVE_TRACKER_PREFS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global WormTrackerPrefs

ApplyPrefsChanges;

ExcelFileName = 'C:\Matlab Functions\Worm Tracker Preferences';
WorkSheet = 'Tracker Prefs';
SaveData = struct2cell(WormTrackerPrefs);
xlswrite(ExcelFileName, SaveData, WorkSheet, 'B1:B12');



function ApplyPrefsChanges
% This function runs when OK or Save Tracker Prefs is selected, and updates
% WormTrackerPrefs to reflect any changes made by the user

global WormTrackerPrefs

WormTrackerPrefs.MinWormArea = str2num(get(findobj('Tag', 'MIN_WORM_AREA'), 'String'));
WormTrackerPrefs.MaxWormArea = str2num(get(findobj('Tag', 'MAX_WORM_AREA'), 'String'));
WormTrackerPrefs.MaxDistance = str2num(get(findobj('Tag', 'MAX_DISTANCE'), 'String'));
WormTrackerPrefs.SizeChangeThreshold = str2num(get(findobj('Tag', 'MAX_SIZE_CHANGE'), 'String'));
WormTrackerPrefs.MinTrackLength = str2num(get(findobj('Tag', 'MIN_TRACK_LENGTH'), 'String'));

WormTrackerPrefs.AutoThreshold = get(findobj('Tag', 'USE_AUTO_THRESH'), 'Value');
WormTrackerPrefs.CorrectFactor = str2num(get(findobj('Tag', 'CORRECT_FACTOR'), 'String'));
WormTrackerPrefs.ManualSetLevel = str2num(get(findobj('Tag', 'MANUAL_LEVEL'), 'String'));
WormTrackerPrefs.DarkObjects = get(findobj('Tag', 'DARK_OBJECTS_WHITE_BKGD'), 'Value');

WormTrackerPrefs.PlotRGB = get(findobj('Tag', 'PLOT_RGB'), 'Value');
WormTrackerPrefs.PauseDuringPlot = get(findobj('Tag', 'PAUSE_TRACKER'), 'Value');
WormTrackerPrefs.PlotObjectSizeHistogram = get(findobj('Tag', 'PLOT_AREA_HIST'), 'Value');





% -------------------------------------------------------------------------
% 'Create Functions' for all Text Edit Fields................
% -------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function MIN_WORM_AREA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIN_WORM_AREA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MAX_WORM_AREA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAX_WORM_AREA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MAX_DISTANCE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAX_DISTANCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MAX_SIZE_CHANGE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAX_SIZE_CHANGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MIN_TRACK_LENGTH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIN_TRACK_LENGTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function CORRECT_FACTOR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CORRECT_FACTOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function MANUAL_LEVEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MANUAL_LEVEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
