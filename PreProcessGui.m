function varargout = PreProcessGui(varargin)
% PREPROCESSGUI MATLAB code for PreProcessGui.fig
%      PREPROCESSGUI, by itself, creates a new PREPROCESSGUI or raises the existing
%      singleton*.
%
%      H = PREPROCESSGUI returns the handle to a new PREPROCESSGUI or the handle to
%      the existing singleton*.
%
%      PREPROCESSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSGUI.M with the given input arguments.
%
%      PREPROCESSGUI('Property','Value',...) creates a new PREPROCESSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PreProcessGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PreProcessGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PreProcessGui

% Last Modified by GUIDE v2.5 31-Jul-2014 09:57:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreProcessGui_OpeningFcn, ...
                   'gui_OutputFcn',  @PreProcessGui_OutputFcn, ...
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


% --- Executes just before PreProcessGui is made visible.
function PreProcessGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PreProcessGui (see VARARGIN)
handles.InputImage = varargin{1};
handles.sublevel = varargin{2};
handles.InputImage.img = single(handles.InputImage.img);
subs = SubSampleImage(handles.InputImage,[handles.sublevel,handles.sublevel,handles.sublevel]);
handles.SubInput = subs{1};
handles.tmpInput = subs{1};
handles.isovalue = 30;
handles.minthresh = 0;
handles.maxthresh = 100;
handles.cropx = 0;
handles.cropy = 0;
handles.cropz = 0;
set(handles.slider3,'Value',100);


% Choose default command line output for PreProcessGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PreProcessGui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PreProcessGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.isovalue;
varargout{2} = handles.minthresh;
varargout{3} = handles.maxthresh;
CropX = handles.cropx*handles.SubInput.hdr.dime.pixdim(2);
CropY = handles.cropy*handles.SubInput.hdr.dime.pixdim(3);
CropZ = handles.cropz*handles.SubInput.hdr.dime.pixdim(4);
varargout{4} = [CropX,CropY,CropZ];
close(handles.figure1);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isovalue = get(hObject,'Value');
set(handles.text3,'String',handles.isovalue)
guidata(hObject,handles);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.minthresh = get(hObject,'Value');
set(handles.text4,'String',handles.minthresh);
guidata(hObject,handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
uiresume(handles.figure1);

function doPlot(handles)

Input.img = zeros(size(handles.SubInput.img));
cropx = handles.cropx;
cropy = handles.cropy;
cropz = handles.cropz;

Input.img((cropx+1):(end-cropx),(cropy+1):(end-cropy),(cropz+1):(end-cropz)) =...
      handles.SubInput.img((cropx+1):(end-cropx),(cropy+1):(end-cropy),(cropz+1):(end-cropz));
Mask = (Input.img > handles.minthresh).*(Input.img < handles.maxthresh);

handles.tmpInput.img = double(Input.img).*double(Mask);

axes(handles.axes1)
[handles.az,handles.el] = view;
cla reset
dims = size(handles.tmpInput.img);
h = patch(isosurface(handles.tmpInput.img,handles.isovalue));
set(h,'EdgeColor','none','FaceColor',[1,0,0]);
alpha(h,0.8);
lighting gouraud;
axis equal
camlight;
    xlabel('xaxis');
    ylabel('yaxis');
    zlabel('zaxis');
view(handles.az,handles.el);
rotate3d on
pause(0.1);


% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doPlot(handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton2.
function pushbutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.maxthresh = get(hObject,'Value');
set(handles.text6,'String',handles.maxthresh);
guidata(hObject,handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.cropx > 0
    handles.cropx = handles.cropx - 1;
end
set(handles.text8,'String',handles.cropx);
guidata(hObject,handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cropx = handles.cropx + 1;
set(handles.text8,'String',handles.cropx);
guidata(hObject,handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.cropy > 0
    handles.cropy = handles.cropy - 1;
end
set(handles.text10,'String',handles.cropy);
guidata(hObject,handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cropy = handles.cropy + 1;
guidata(hObject,handles);
set(handles.text10,'String',handles.cropy);



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.cropz > 0
    handles.cropz = handles.cropz - 1;
end
set(handles.text12,'String',handles.cropz);
guidata(hObject,handles);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cropz = handles.cropz + 1;
set(handles.text12,'String',handles.cropz);
guidata(hObject,handles);
