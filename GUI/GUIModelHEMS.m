function varargout = GUIModelHEMS(varargin)
% GUIMODELHEMS MATLAB code for GUIModelHEMS.fig
%      GUIMODELHEMS, by itself, creates a new GUIMODELHEMS or raises the existing
%      singleton*.
%
%      H = GUIMODELHEMS returns the handle to a new GUIMODELHEMS or the handle to
%      the existing singleton*.
%
%      GUIMODELHEMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIMODELHEMS.M with the given input arguments.
%
%      GUIMODELHEMS('Property','Value',...) creates a new GUIMODELHEMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIModelHEMS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIModelHEMS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIModelHEMS

% Last Modified by GUIDE v2.5 30-Jan-2018 09:46:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIModelHEMS_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIModelHEMS_OutputFcn, ...
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


% --- Executes just before GUIModelHEMS is made visible.
function GUIModelHEMS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIModelHEMS (see VARARGIN)

% Choose default command line output for GUIModelHEMS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIModelHEMS wait for user response (see UIRESUME)
% uiwait(handles.Start);


% --- Outputs from this function are returned to the command line.
function varargout = GUIModelHEMS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Nbr_Building_Callback(hObject, eventdata, handles)
% hObject    handle to Nbr_Building (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nbr_Building as text
%        str2double(get(hObject,'String')) returns contents of Nbr_Building as a double

str=get(hObject,'String');
if isempty(str2num(str))
    set(hObject,'string','0');
    warndlg('Input must be numerical');
end
% --- Executes during object creation, after setting all properties.
function Nbr_Building_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nbr_Building (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Start,'visible','off');
Gui2

function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on Nbr_Building and none of its controls.
function Nbr_Building_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Nbr_Building (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
allvalue = get(hObject,'String') ;
if isempty(str2num(allvalue))
    set(hObject,'string','0');
    warndlg('Input must be numerical');
end
