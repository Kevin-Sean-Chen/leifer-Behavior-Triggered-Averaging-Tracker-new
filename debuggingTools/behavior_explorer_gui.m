function varargout = behavior_explorer_gui(varargin)
% behavior_explorer_gui MATLAB code for behavior_explorer_gui.fig
%      behavior_explorer_gui, by itself, creates a new behavior_explorer_gui or raises the existing
%      singleton*.
%
%      H = behavior_explorer_gui returns the handle to a new behavior_explorer_gui or the handle to
%      the existing singleton*.
%
%      behavior_explorer_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in behavior_explorer_gui.M with the given input arguments.
%
%      behavior_explorer_gui('Property','Value',...) creates a new behavior_explorer_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before behavior_explorer_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to behavior_explorer_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help behavior_explorer_gui

% Last Modified by GUIDE v2.5 18-Sep-2015 00:06:11

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @behavior_explorer_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @behavior_explorer_gui_OutputFcn, ...
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
end

% --- Executes just before behavior_explorer_gui is made visible.
function behavior_explorer_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to behavior_explorer_gui (see VARARGIN)

    % Choose default command line output for behavior_explorer_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    hObject.UserData = varargin;  
    
    worm_images = hObject.UserData{1};
    Track = hObject.UserData{2};
    worm_frame_start_index = hObject.UserData{3};
    worm_frame_end_index = hObject.UserData{4};
    
    

    current_frame = worm_frame_start_index;
    hObject.UserData{6} = current_frame; %current frame
    
    load('reference_embedding.mat')
    hObject.UserData{7} = L;
    hObject.UserData{8} = xx;
    hObject.UserData{9} = density;
    hObject.UserData{10} = behavioral_space_to_behavior(Track.Embeddings, L, xx);
    hObject.UserData{11} = behavior_names;
    
    display_frame(hObject, current_frame);
end

% --- Outputs from this function are returned to the command line.
function varargout = behavior_explorer_gui_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in GoButton.
function GoButton_Callback(hObject, eventdata, handles)
    % hObject    handle to GoButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    axes(handles.image_axes);
    cla;

    h = findobj('Tag','figure1');
    popup_sel_index = get(handles.ActionsPopupMenu, 'Value');
    h.UserData{7} = popup_sel_index;
    uiresume
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
    % hObject    handle to FileMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
    % hObject    handle to OpenMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    file = uigetfile('*.fig');
    if ~isequal(file, 0)
        open(file);
    end
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
    % hObject    handle to PrintMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    printdlg(handles.figure1)
end
% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
    % hObject    handle to CloseMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                         ['Close ' get(handles.figure1,'Name') '...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
    h = findobj('Tag','figure1');
    popup_sel_index = get(handles.ActionsPopupMenu, 'Value');
    h.UserData{7} = popup_sel_index;
    uiresume
end

% --- Executes on selection change in ActionsPopupMenu.
function ActionsPopupMenu_Callback(hObject, eventdata, handles)
    % hObject    handle to ActionsPopupMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns ActionsPopupMenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from ActionsPopupMenu

end
% --- Executes during object creation, after setting all properties.
function ActionsPopupMenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ActionsPopupMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
         set(hObject,'BackgroundColor','white');
    end

%     set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});
end

% --- Executes on button press in BackButton.
function BackButton_Callback(hObject, eventdata, handles)
    % hObject    handle to BackButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    h = findobj('Tag','figure1');
    Track = h.UserData{2};
    worm_frame_start_index = h.UserData{3};
    worm_frame_end_index = h.UserData{4};
    current_frame = h.UserData{6};
    if current_frame > 1
        current_frame = current_frame - 1;
    end
    display_frame(h, current_frame);
    
    h.UserData{6} = current_frame;
end

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
    % hObject    handle to NextButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    h = findobj('Tag','figure1');
    Track = h.UserData{2};
    worm_frame_start_index = h.UserData{3};
    worm_frame_end_index = h.UserData{4};
    current_frame = h.UserData{6};
    if current_frame < length(Track.Frames)
        current_frame = current_frame + 1;
    end
    display_frame(h, current_frame);
    
    h.UserData{6} = current_frame;
end

function display_frame(hObject, frame_index)
    worm_images = hObject.UserData{1};
    Track = hObject.UserData{2};
    track_index = hObject.UserData{5};
    L = hObject.UserData{7};
    xx = hObject.UserData{8};
    density = hObject.UserData{9};
    behavior_timeseries = hObject.UserData{10};
    behavior_names = hObject.UserData{11};
    
    [ii,jj] = find(L==0);
    I = squeeze(worm_images(:,:,frame_index));
    maxDensity = max(density(:));
    plot_embedding = Track.Embeddings;
    
    axes_handle = findobj('Tag', 'image_axes');
    axes(axes_handle)
    set(gca, 'position', [-0.225 0 0.8 0.8])    
    
    plot_worm_frame(I, squeeze(Track.Centerlines(:,:,frame_index)), ...
        [], ...
        Track.Eccentricity(frame_index), Track.Direction(frame_index), ...
        Track.Speed(frame_index),  Track.TotalScore(frame_index), Track.UncertainTips(frame_index), 1);
    set(gca, 'Tag', 'image_axes');
    axis tight
    freezeColors
    
    axes_handle = findobj('Tag', 'axes2');
    axes(axes_handle)
    set(gca, 'position', [-0.1 -0.225 1.25 1.25])   
    xlim('auto');
    ylim('auto');
    axis off square % image
    
    hold on
    imagesc(xx,xx,density)
    
    caxis([0 maxDensity * .8])
    colormap(jet)
    plot(xx(jj),xx(ii),'k.') %watershed borders
    plot(plot_embedding(frame_index,1), plot_embedding(frame_index,2), 'om', 'MarkerSize', 15, 'LineWidth', 3)
    watershed_centroids = regionprops(L, 'centroid');
    watershed_centroids = vertcat(watershed_centroids.Centroid);
    watershed_centroids = round(watershed_centroids);
    for region_index = 1:size(watershed_centroids,1)
        text(xx(watershed_centroids(region_index,1)), ...
            xx(watershed_centroids(region_index,2)), ...
            num2str(region_index), 'color', 'k', ...
            'fontsize', 12, 'horizontalalignment', 'center', ...
            'verticalalignment', 'middle');
    end
    hold off

    set(gca, 'Tag', 'axes2');


    current_behaviors = find(double(Track.Behaviors(:,frame_index))');

    text_handle = findobj('Tag', 'PropertiesText');
    text_handle.String = {['Track #: ', num2str(track_index)], ...
        ['Frame #: ', num2str(frame_index)], ...
        ['Error: ', problem_code_lookup(Track.PotentialProblems(frame_index))], ...
        ['Watershed #: ', num2str(behavior_timeseries(frame_index))], ...
        ['Behaviors: ', num2str(current_behaviors)] ...
        
        };
    
%     normalized_colors = jet(size(Track.Behaviors,1)) ./ size(Track.Behaviors,1);
%     calculated_color = current_behaviors * normalized_colors;
%     
%     if sum(calculated_color) > 0
%         text_handle.BackgroundColor = calculated_color;
%     else
%         text_handle.BackgroundColor = [0.94, 0.94, 0.94];
%     end

end
