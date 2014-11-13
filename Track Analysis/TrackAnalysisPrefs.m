function varargout = TrackAnalysisPrefs(varargin)
% TRACKANALYSISPREFS M-file for TrackAnalysisPrefs.fig
%      TRACKANALYSISPREFS, by itself, creates a new TRACKANALYSISPREFS or raises the existing
%      singleton*.
%
%      H = TRACKANALYSISPREFS returns the handle to a new TRACKANALYSISPREFS or the handle to
%      the existing singleton*.
%
%      TRACKANALYSISPREFS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKANALYSISPREFS.M with the given input arguments.
%
%      TRACKANALYSISPREFS('Property','Value',...) creates a new TRACKANALYSISPREFS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackAnalysisPrefs_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrackAnalysisPrefs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackAnalysisPrefs

% Last Modified by GUIDE v2.5 12-Feb-2008 22:27:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrackAnalysisPrefs_OpeningFcn, ...
                   'gui_OutputFcn',  @TrackAnalysisPrefs_OutputFcn, ...
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


% --- Executes just before TrackAnalysisPrefs is made visible.
function TrackAnalysisPrefs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackAnalysisPrefs (see VARARGIN)

% Choose default command line output for TrackAnalysisPrefs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrackAnalysisPrefs wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global Prefs;

set(findobj('Tag', 'SAMPLE_RATE'), 'String', num2str(Prefs.SampleRate))
set(findobj('Tag', 'WIN_SIZE'), 'String', num2str(Prefs.SmoothWinSize))
set(findobj('Tag', 'SPEED_STEP_SIZE'), 'String', num2str(Prefs.StepSize))

set(findobj('Tag', 'ANALYZE_DIRECTION'), 'Value', Prefs.PlotDirection)
set(findobj('Tag', 'ANALYZE_SPEED'), 'Value', Prefs.PlotSpeed)
set(findobj('Tag', 'ANALYZE_ANG_SPEED'), 'Value', Prefs.PlotAngSpeed)

set(findobj('Tag', 'PIR_ID_THRESH'), 'String', num2str(Prefs.PirThresh))
set(findobj('Tag', 'MAX_SHORT_RUN'), 'String', num2str(Prefs.MaxShortRun))
set(findobj('Tag', 'FF_SPEED'), 'String', num2str(Prefs.FFSpeed))
set(findobj('Tag', 'PIXEL_SIZE'), 'String', num2str(1/Prefs.PixelSize))
set(findobj('Tag', 'DEFAULT_DIR'), 'String', Prefs.DefaultPath)

set(findobj('Tag', 'SPEED_HIST_BIN_SPACING'), 'String', Prefs.BinSpacing)
set(findobj('Tag', 'SPEED_HIST_MAX_BIN'), 'String', Prefs.MaxSpeedBin)
set(findobj('Tag', 'PARAL_SPEED_THRESH'), 'String', Prefs.P_MaxSpeed)
set(findobj('Tag', 'PARAL_MIN_TRACK_FRACTION'), 'String', Prefs.P_TrackFraction)
set(findobj('Tag', 'PARAL_WRITE_EXCEL'), 'Value', Prefs.P_WriteExcel)



% --- Outputs from this function are returned to the command line.
function varargout = TrackAnalysisPrefs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in ANAL_SAVE_DEFAULT.
function ANAL_SAVE_DEFAULT_Callback(hObject, eventdata, handles)
% hObject    handle to ANAL_SAVE_DEFAULT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Prefs;

ApplyAnalPrefsChanges;

ExcelFileName = 'C:\Matlab Functions\Worm Tracker Preferences';
WorkSheet = 'Analysis Prefs';
SaveData = struct2cell(Prefs);
SaveData{10} = 1/SaveData{10};  % Convert Pixel Size to pixels/mm measure
xlswrite(ExcelFileName, SaveData, WorkSheet, 'B1:B16');



% --- Executes on button press in ANAL_CANCEL.
function ANAL_CANCEL_Callback(hObject, eventdata, handles)
% hObject    handle to ANAL_CANCEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closereq;



% --- Executes on button press in ANAL_OKAY.
function ANAL_OKAY_Callback(hObject, eventdata, handles)
% hObject    handle to ANAL_OKAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ApplyAnalPrefsChanges;
closereq;



function ApplyAnalPrefsChanges
% This function runs when OK or Save Tracker Prefs is selected, and updates
% WormTrackerPrefs to reflect any changes made by the user

global Current;
global Prefs;

x = str2num(get(findobj('Tag', 'SAMPLE_RATE'), 'String'));
if Prefs.SampleRate ~= x
    Prefs.SampleRate = x;
    Current.Analyzed = 0;
end
x = str2num(get(findobj('Tag', 'WIN_SIZE'), 'String'));
if Prefs.SmoothWinSize ~= x
    Prefs.SmoothWinSize = x;
    Current.Analyzed = 0;
end
x = str2num(get(findobj('Tag', 'SPEED_STEP_SIZE'), 'String'));
if Prefs.StepSize ~= x
    Prefs.StepSize = x;
    Current.Analyzed = 0;
end

Prefs.PlotDirection = get(findobj('Tag', 'ANALYZE_DIRECTION'), 'Value');
Prefs.PlotSpeed = get(findobj('Tag', 'ANALYZE_SPEED'), 'Value');
Prefs.PlotAngSpeed = get(findobj('Tag', 'ANALYZE_ANG_SPEED'), 'Value');

x = str2num(get(findobj('Tag', 'PIR_ID_THRESH'), 'String'));
if Prefs.PirThresh ~= x
    Prefs.PirThresh = x;
    Current.Analyzed = 0;
end
x = str2num(get(findobj('Tag', 'MAX_SHORT_RUN'), 'String'));
if Prefs.MaxShortRun ~= x
    Prefs.MaxShortRun = x;
    Current.Analyzed = 0;
end
x = 1/str2num(get(findobj('Tag', 'PIXEL_SIZE'), 'String'));
if Prefs.PixelSize ~= x
    Prefs.PixelSize = x;
    Current.Analyzed = 0;
end

Prefs.FFSpeed = str2num(get(findobj('Tag', 'FF_SPEED'), 'String'));
Prefs.DefaultPath = get(findobj('Tag', 'DEFAULT_DIR'), 'String');

Prefs.BinSpacing = str2num(get(findobj('Tag', 'SPEED_HIST_BIN_SPACING'), 'String'));
Prefs.MaxSpeedBin = str2num(get(findobj('Tag', 'SPEED_HIST_MAX_BIN'), 'String'));
Prefs.P_MaxSpeed = str2num(get(findobj('Tag', 'PARAL_SPEED_THRESH'), 'String'));
Prefs.P_TrackFraction = str2num(get(findobj('Tag', 'PARAL_MIN_TRACK_FRACTION'), 'String'));
Prefs.P_WriteExcel = get(findobj('Tag', 'PARAL_WRITE_EXCEL'), 'Value');




% -------------------------------------------------------------------------
% 'Create Functions' for all Text Edit Fields................
% -------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function SAMPLE_RATE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SAMPLE_RATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function WIN_SIZE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WIN_SIZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SPEED_STEP_SIZE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPEED_STEP_SIZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PIR_ID_THRESH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PIR_ID_THRESH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function MAX_SHORT_RUN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAX_SHORT_RUN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function FF_SPEED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FF_SPEED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PIXEL_SIZE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PIXEL_SIZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function DEFAULT_DIR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DEFAULT_DIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SPEED_HIST_BIN_SPACING_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPEED_HIST_BIN_SPACING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SPEED_HIST_MAX_BIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPEED_HIST_MAX_BIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PARAL_SPEED_THRESH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARAL_SPEED_THRESH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PARAL_MIN_TRACK_FRACTION_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARAL_MIN_TRACK_FRACTION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


