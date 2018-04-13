function varargout = sc_gui(varargin)
% SC_GUI MATLAB code for sc_gui.fig
%      SC_GUI, by itself, creates a new SC_GUI or raises the existing
%      singleton*.
%
%      H = SC_GUI returns the handle to a new SC_GUI or the handle to
%      the existing singleton*.
%
%      SC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SC_GUI.M with the given input arguments.
%
%      SC_GUI('Property','Value',...) creates a new SC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sc_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sc_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sc_gui

% Last Modified by GUIDE v2.5 30-Oct-2017 02:03:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sc_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sc_gui_OutputFcn, ...
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


% --- Executes just before sc_gui is made visible.
function sc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sc_gui (see VARARGIN)

%disable all commands except load image
enableButtons(handles, 'off')


set(handles.loadImageButton, 'enable', 'on');
%%% set(handles.loadVideoButton, 'enable', 'on');

% Choose default command line output for sc_gui
handles.output = hObject;

handles.pressedRemove = 0;

handles.isImage = 0;

set (hObject, 'WindowButtonDownFcn', @mButtonDownPo);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sc_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function mButtonDownPo(h, eventdata)
m_type = get(h, 'selectionType');
handles = guidata( ancestor(h, 'figure') );
if strcmp(m_type, 'alt') && ( get(handles.srCB, 'Value')|| handles.pressedRemove)
    %save default callbacks
    defCB.WindowButtonMotionFcn = get(h,'WindowButtonMotionFcn');
    defCB.WindowButtonUpFcn = get(h,'WindowButtonUpFcn');
    setappdata(h,'GuiDefCallbacks2',defCB);

    set(h,'WindowButtonMotionFcn',@mouseMotionPo)
    set(h,'WindowButtonUpFcn', @mButtonUpPo)
end

function mButtonUpPo(h, eventdata)
defCB = getappdata(h,'GuiDefCallbacks2');
set(h,defCB);


function mouseMotionPo(h, eventdata)
C = get (gca, 'CurrentPoint');
x = floor(C(1,1));
y = floor(C(1,2));
t = 10;
handles = guidata( ancestor(h, 'figure') );
if x >= (1+t) && y >= (1+t) && x <= (size(handles.currImg,2)-t) && y <= (size(handles.currImg,1)-t)
    handles.poMask((y-t):1:(y+t),(x-t):1:(x+t)) = 1;
end

highlighted_img = handles.currImg;
red_channel = highlighted_img(:,:,1);
red_channel(logical(handles.poMask)) = 1;
highlighted_img(:,:,1) = red_channel; 
%set imgPanel
imshow(highlighted_img, 'Parent', handles.imgPanel);

% Update handles structure
guidata(h, handles);


function mButtonDown(h, eventdata)
m_type = get(h, 'selectionType');
if strcmp(m_type, 'normal')
    %save default callbacks
    defCB.WindowButtonMotionFcn = get(h,'WindowButtonMotionFcn');
    defCB.WindowButtonUpFcn = get(h,'WindowButtonUpFcn');
    setappdata(h,'GuiDefCallbacks',defCB);

    set(h,'WindowButtonMotionFcn',@mouseMotion)
    set(h,'WindowButtonUpFcn', @mButtonUp)
end

function mButtonUp(h, eventdata)
defCB = getappdata(h,'GuiDefCallbacks');
set(h,defCB);

function mouseMotion(h, eventdata)
C = get (gca, 'CurrentPoint');
x = floor(C(1,1));
y = floor(C(1,2));
t = 10;
handles = guidata( ancestor(h, 'figure') );
if x >= (1+t) && y >= (1+t) && x <= (size(handles.currImg,2)-t) && y <= (size(handles.currImg,1)-t)
    handles.roMask((y-t):1:(y+t),(x-t):1:(x+t)) = 1;
end

highlighted_img = handles.currImg;

red_channel = highlighted_img(:,:,1);
red_channel(logical(handles.poMask)) = 1;
highlighted_img(:,:,1) = red_channel; 

green_channel = highlighted_img(:,:,2);
green_channel(logical(handles.roMask)) = 0.9;
highlighted_img(:,:,2) = green_channel; 

%set imgPanel
imshow(highlighted_img, 'Parent', handles.imgPanel);

% Update handles structure
guidata(h, handles);
    

% --- Outputs from this function are returned to the command line.
function varargout = sc_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadImageButton.
function loadImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%load image from user
[FileName,PathName] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';},'Select Image');

if (FileName)==0
    return
end

handles.absolute_path = [PathName,'\',FileName];

loadImgFile(hObject, handles);


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isImage
    loadImgFile(hObject, handles);
end

% Update handles structure
guidata(hObject, handles);


function targetWidth_Callback(hObject, eventdata, handles)
% hObject    handle to targetWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetWidth as text
%        str2double(get(hObject,'String')) returns contents of targetWidth as a double

function seamHeight_Callback(hObject, eventdata, handles)
% hObject    handle to targetWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function seamWidth_Callback(hObject, eventdata, handles)
% hObject    handle to targetWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function seamHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetWidth as text
%        str2double(get(hObject,'String')) returns contents of targetWidth as a double
function seamWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetWidth as text
%        str2double(get(hObject,'String')) returns contents of targetWidth as a double


% --- Executes during object creation, after setting all properties.
function targetWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resizeButton.
function resizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to resizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

input_width = get(handles.targetWidth, 'String');
input_height = get(handles.targetHeight, 'String');

if isempty(str2num(input_width))
    set(handles.targetWidth,'String', handles.currWidth);
    warndlg('Input must be numerical');
    return
end

if isempty(str2num(input_height))
    set(handles.targetHeight,'String', handles.currHeight);
    warndlg('Input must be numerical');
    return
end

input_width = round(str2num(input_width));
input_height = round(str2num(input_height));

if input_width == handles.currWidth && input_height == handles.currHeight
    return
elseif input_width <= 0 || input_width > handles.maxWidth || ...
        input_height <= 0 || input_height > handles.maxHeight
    h = msgbox('Desired dimensions less than 1 or greater than 2 times original image.','Error');
    return
end

%disable all commands except load image
enableButtons(handles, 'off')

set(handles.figure1, 'pointer', 'watch')
drawnow;

updated_img = handles.origImg;

if input_width <= handles.width && input_height <= handles.height
        

         if get(handles.gdCB, 'Value')
            updated_img = gradientDomainReduceImage([input_height input_width], updated_img);
         elseif get(handles.feCB, 'Value')
            if get(handles.graphCutCB, 'Value')
                updated_img = simpleReduceImageGC([input_height input_width], updated_img, zeros(size(updated_img,1), size(updated_img,2)), 'FE');
            else
                updated_img =  simpleReduceImageFE([input_height input_width], updated_img, handles.poMask);
            end
         elseif get(handles.graphCutCB, 'Value')
            updated_img = simpleReduceImageGC([input_height input_width], updated_img, handles.poMask, 'BE');
         elseif get(handles.srCB, 'Value')
            updated_img =  simpleReduceImage([input_height input_width], updated_img, handles.poMask);
         elseif get(handles.line, 'Value')
            updated_img =  simpleReduceImage_line([input_height input_width], updated_img, handles.poMask);
         elseif get(handles.sr_salient_a, 'Value')
            updated_img =  simpleReduceImage_salient([input_height input_width], updated_img, handles.poMask);   
         elseif get(handles.srCB, 'Value')
            updated_img =  simpleReduceImage([input_height input_width], updated_img, handles.poMask);
             
         else 
            updated_img = reduceImage([input_height input_width], updated_img);
         end

elseif input_width >= handles.width && input_height >= handles.height

  
        if get(handles.gdCB, 'Value')
            updated_img = gradientDomainEnlargeImage([input_height input_width], updated_img);
        elseif get(handles.feCB, 'Value')
            if get(handles.graphCutCB, 'Value')
                updated_img = enlargeImageGC([input_height input_width], updated_img, 'FE');
            else
                updated_img = enlargeImage([input_height input_width], updated_img, 'FE');
            end
        elseif get(handles.graphCutCB, 'Value')
            updated_img = enlargeImageGC([input_height input_width], updated_img, 'BE');
        
        elseif get(handles.sr_salient_a, 'Value')
            updated_img = enlargeImage_salient([input_height input_width], updated_img, 'BE');
        else
            updated_img = enlargeImage([input_height input_width], updated_img, 'BE');    
        end
end

handles.currWidth = input_width;
handles.currHeight = input_height;

handles.currImg = updated_img;

%set texts
set(handles.targetHeight, 'String', num2str(handles.currHeight));
set(handles.targetWidth, 'String', num2str(handles.currWidth));
set(handles.seamHeight, 'String', num2str(handles.currHeight));
set(handles.seamWidth, 'String', num2str(handles.currWidth));

%set imgPanel
    pos = getpixelposition(handles.imgPanel);
    set(handles.imgPanel, 'Units', 'pixels', ...
    'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);
    imshow(handles.currImg, 'Parent', handles.imgPanel);

    %enable commands
enableButtons(handles, 'on')
set(handles.figure1, 'pointer', 'arrow')

handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));

% Update handles structure
guidata(hObject, handles);




function targetHeight_Callback(hObject, eventdata, handles)
% hObject    handle to targetHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetHeight as text
%        str2double(get(hObject,'String')) returns contents of targetHeight as a double


% --- Executes during object creation, after setting all properties.
function targetHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showSeamButton.
function showSeamButton_Callback(hObject, eventdata, handles)
% hObject    handle to showSeamButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.isImage
    input_width = get(handles.seamWidth, 'String');
    input_height = get(handles.seamHeight, 'String');

    if isempty(str2num(input_width))
        set(handles.seamWidth,'String', handles.currWidth);
        warndlg('Input must be numerical');
        return
    end

    if isempty(str2num(input_height))
        set(handles.seamHeight,'String', handles.currHeight);
        warndlg('Input must be numerical');
        return
    end

    input_width = round(str2num(input_width));
    input_height = round(str2num(input_height));

    if input_width == handles.currWidth && input_height == handles.currHeight
        return
    elseif input_width <= 0 || input_width > handles.maxWidth || ...
            input_height <= 0 || input_height > handles.maxHeight
        h = msgbox('Desired dimensions less than 1 or greater than 2 times original image.','Error');
        return
    end

    enableButtons(handles, 'off')
    set(handles.figure1, 'pointer', 'watch')
    drawnow;
    curr_img = handles.currImg;

       % showSeams([input_height input_width], curr_img, handles.imgPanel, 'BE');
    if get(handles.feCB, 'Value')
        if get(handles.graphCutCB, 'Value')
            showSeamsGC([input_height input_width], curr_img, handles.imgPanel, 'FE');
        else
            showSeams([input_height input_width], curr_img, handles.imgPanel, 'FE');
        end
    elseif get(handles.graphCutCB, 'Value')
        showSeamsGC([input_height input_width], curr_img, handles.imgPanel, 'BE');
    else
        showSeams([input_height input_width], curr_img, handles.imgPanel, 'BE');
    end

    %enable commands
    enableButtons(handles, 'on')
    set(handles.figure1, 'pointer', 'arrow')
end


% --- Executes on button press in gdCB.
function gdCB_Callback(hObject, eventdata, handles)
% hObject    handle to gdCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gdCB


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get output file name
[FileName,PathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';},'Output Filename');

if (FileName)==0
    return
end

absolute_path = [PathName,'\',FileName];

I = getframe(handles.imgPanel);
imwrite(I.cdata, absolute_path); 

%copied from demoMATLABTricksFun.m
function annotated_img = saveAnnotatedImg(fh)
figure(fh); % Shift the focus back to the figure fh

% The figure needs to be undocked
set(fh, 'WindowStyle', 'normal');

% The following two lines just to make the figure true size to the
% displayed image. The reason will become clear later.
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);

% getframe does a screen capture of the figure window, as a result, the
% displayed figure has to be in true size. 
frame = getframe(fh);
frame = getframe(fh);
pause(0.5); 
% Because getframe tries to perform a screen capture. it somehow 
% has some platform depend issues. we should calling
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;

% --- loads image file and modifies data appropriately
function loadImgFile(hObject, handles)
%read image
try
    img = im2single(imread(handles.absolute_path));
catch
    h = msgbox('Error reading image file. Please try again.','Error');
    return
end

handles.origImg = img;
handles.currImg = img;

%enable commands
enableButtons(handles, 'on')

set(handles.gdCB, 'value', 0);
set(handles.srCB, 'value', 0);
set(handles.sr_salient_a, 'value', 0);
set(handles.line, 'value', 0);

%get width and height
handles.height = size(img, 1);
handles.width = size(img, 2);

handles.currHeight = size(img, 1);
handles.currWidth = size(img, 2);

handles.maxHeight = round(2*size(img, 1));
handles.maxWidth = round(2*size(img, 2));

%set texts
set(handles.targetHeight, 'String', num2str(handles.height));
set(handles.targetWidth, 'String', num2str(handles.width));
set(handles.seamHeight, 'String', num2str(handles.height));
set(handles.seamWidth, 'String', num2str(handles.width));


pos = getpixelposition(handles.imgPanel);
set(handles.imgPanel, 'Units', 'pixels', ...
    'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);

%set imgPanel
imshow(handles.currImg, 'Parent', handles.imgPanel);

handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));

handles.isImage = 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in amplifyButton.
function amplifyButton_Callback(hObject, eventdata, handles)
% hObject    handle to amplifyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%disable all commands except load image
enableButtons(handles, 'off')

set(handles.figure1, 'pointer', 'watch')
drawnow;

updated_img = handles.origImg;

updated_img = amplifyImage(updated_img, handles.poMask, 'simple');

handles.currImg = updated_img;

%set imgPanel
imshow(handles.currImg, 'Parent', handles.imgPanel);

%enable commands
enableButtons(handles, 'on')
set(handles.figure1, 'pointer', 'arrow')
handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in srCB.
function srCB_Callback(hObject, eventdata, handles)
% hObject    handle to srCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of srCB
%%%if handles.isImage
    handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
    %set imgPanel
    imshow(handles.currImg, 'Parent', handles.imgPanel);
%%%else
    
%%%end
% Update handles structure
guidata(hObject, handles);

%function to enable or disable buttons
function enableButtons(handles, type)

if strcmp(type,'on') == 1
    set(handles.targetHeight, 'enable', 'on');
    set(handles.targetWidth, 'enable', 'on');
    set(handles.seamHeight, 'enable', 'on');
    set(handles.seamWidth, 'enable', 'on');

    set(handles.resetButton, 'enable', 'on');
    set(handles.saveButton, 'enable', 'on');
    set(handles.showSeamButton, 'enable', 'on');
    set(handles.gdCB, 'enable', 'on');
    set(handles.feCB, 'enable', 'on');
    set(handles.scaleImg, 'enable', 'on');
    set(handles.resizeButton, 'enable', 'on');
    set(handles.amplifyButton, 'enable', 'on');

    set(handles.removeOButton, 'enable', 'on');
    set(handles.line, 'enable', 'on');
    set(handles.loadImageButton, 'enable', 'on');
    set(handles.srCB, 'enable', 'on');
    set(handles.sr_salient_a, 'enable', 'on');
     set(handles.gaussian, 'enable', 'on');
    set(handles.cropImg, 'enable', 'on');
     set(handles.graphCutCB, 'enable', 'on');
    set(handles.figure1, 'pointer', 'arrow')
     set(handles.gchseamButton, 'enable', 'on');
    set(handles.gcvseamButton, 'enable', 'on');
    
else
    set(handles.targetHeight, 'enable', 'off');
    set(handles.targetWidth, 'enable', 'off');
    set(handles.seamHeight, 'enable', 'off');
    set(handles.seamWidth, 'enable', 'off');
    set(handles.gchseamButton, 'enable', 'off');
    set(handles.gcvseamButton, 'enable', 'off');
    set(handles.resetButton, 'enable', 'off');
    set(handles.saveButton, 'enable', 'off');
    set(handles.showSeamButton, 'enable', 'off');
    set(handles.gdCB, 'enable', 'off');
    set(handles.feCB, 'enable', 'off');
    set(handles.resizeButton, 'enable', 'off');
    set(handles.line, 'enable', 'off');
    set(handles.amplifyButton, 'enable', 'off');
    set(handles.removeOButton, 'enable', 'off');
    set(handles.graphCutCB, 'enable', 'off');

    set(handles.loadImageButton, 'enable', 'off');
    set(handles.srCB, 'enable', 'off');
    set(handles.sr_salient_a, 'enable', 'off');
    set(handles.scaleImg, 'enable', 'off');
     set(handles.gaussian, 'enable', 'off');
    set(handles.cropImg, 'enable', 'off'); 
end


% --- Executes on button press in removeOButton.
function removeOButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeOButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.pressedRemove = ~handles.pressedRemove;
[h,main_fig] = gcbo;
if handles.pressedRemove
    enableButtons(handles, 'off')
    set(handles.removeOButton, 'enable', 'on');

    %save default callbacks
    wbdCB.WindowButtonDownFcn = get(main_fig,'WindowButtonDownFcn');
    setappdata(main_fig,'DefWindowButtonDownFcn',wbdCB);
    
    set (main_fig, 'WindowButtonDownFcn', @mButtonDown);
    
    handles.roMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
else
    wbdCB = getappdata(main_fig,'DefWindowButtonDownFcn');
    set(main_fig, wbdCB);
    
    set(handles.figure1, 'pointer', 'watch')
    drawnow;
   % handles.currImg = removeObject(handles.currImg, handles.roMask, handles.poMask, 'BE');
    if get(handles.feCB, 'Value')
        handles.currImg = removeObject(handles.currImg, handles.roMask, handles.poMask, 'FE');
    else
        handles.currImg = removeObject(handles.currImg, handles.roMask, handles.poMask, 'BE');
    end
    handles.currWidth = size(handles.currImg,2);
    handles.currHeight = size(handles.currImg,1);
    
    %set texts
    set(handles.targetHeight, 'String', num2str(handles.currHeight));
    set(handles.targetWidth, 'String', num2str(handles.currWidth));
    set(handles.seamHeight, 'String', num2str(handles.currHeight));
    set(handles.seamWidth, 'String', num2str(handles.currWidth));

    pos = getpixelposition(handles.imgPanel);
    set(handles.imgPanel, 'Units', 'pixels', ...
        'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);

    %set imgPanel
    imshow(handles.currImg, 'Parent', handles.imgPanel);

    handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
    enableButtons(handles, 'on')
    set(handles.figure1, 'pointer', 'arrow')
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in scaleImg.
function scaleImg_Callback(hObject, eventdata, handles)
% hObject    handle to scaleImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

input_width = get(handles.targetWidth, 'String');
input_height = get(handles.targetHeight, 'String');

if isempty(str2num(input_width))
    set(handles.targetWidth,'String', handles.currWidth);
    warndlg('Input must be numerical');
    return
end

if isempty(str2num(input_height))
    set(handles.targetHeight,'String', handles.currHeight);
    warndlg('Input must be numerical');
    return
end

input_width = round(str2num(input_width));
input_height = round(str2num(input_height));

if input_width == handles.currWidth && input_height == handles.currHeight
    return
elseif input_width <= 0 || input_width > handles.maxWidth || ...
        input_height <= 0 || input_height > handles.maxHeight
    h = msgbox('Desired dimensions less than 1 or greater than 2 times original image.','Error');
    return
end

%disable all commands except load image
enableButtons(handles, 'off')

set(handles.figure1, 'pointer', 'watch')
drawnow;

updated_img = handles.origImg;
          if  get(handles.scaleImg,'Value')
            updated_img = imresize(updated_img, [input_height input_width]); 
          end  
handles.currWidth = input_width;
handles.currHeight = input_height;

handles.currImg = updated_img;

%set texts
set(handles.targetHeight, 'String', num2str(handles.currHeight));
set(handles.targetWidth, 'String', num2str(handles.currWidth));
set(handles.seamHeight, 'String', num2str(handles.currHeight));
set(handles.seamWidth, 'String', num2str(handles.currWidth));

%set imgPanel
    pos = getpixelposition(handles.imgPanel);
    set(handles.imgPanel, 'Units', 'pixels', ...
    'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);
    imshow(handles.currImg, 'Parent', handles.imgPanel);

    %enable commands
enableButtons(handles, 'on')
set(handles.figure1, 'pointer', 'arrow')


% Update handles structure
guidata(hObject, handles);        




% --- Executes on button press in cropImg.
function cropImg_Callback(hObject, eventdata, handles)
% hObject    handle to cropImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cropImg

input_width = get(handles.targetWidth, 'String');
input_height = get(handles.targetHeight, 'String');

if isempty(str2num(input_width))
    set(handles.targetWidth,'String', handles.currWidth);
    warndlg('Input must be numerical');
    return
end

if isempty(str2num(input_height))
    set(handles.targetHeight,'String', handles.currHeight);
    warndlg('Input must be numerical');
    return
end

input_width = round(str2num(input_width));
input_height = round(str2num(input_height));

if input_width == handles.currWidth && input_height == handles.currHeight
    return
elseif input_width <= 0 || input_width > handles.maxWidth || ...
        input_height <= 0 || input_height > handles.maxHeight
    h = msgbox('Desired dimensions less than 1 or greater than 2 times original image.','Error');
    return
end

%disable all commands except load image
enableButtons(handles, 'off')

%%set(handles.figure1, 'pointer', 'watch')
drawnow;

updated_img = handles.origImg;
if input_width <= handles.width && input_height <= handles.height
     updated_img = imcrop(updated_img);           
else
    set(handles.cropImg, 'enable', 'off');
end    

handles.currWidth = input_width;
handles.currHeight = input_height;

handles.currImg = updated_img;

%set texts
set(handles.targetHeight, 'String', num2str(handles.currHeight));
set(handles.targetWidth, 'String', num2str(handles.currWidth));
set(handles.seamHeight, 'String', num2str(handles.currHeight));
set(handles.seamWidth, 'String', num2str(handles.currWidth));

%set imgPanel
    pos = getpixelposition(handles.imgPanel);
    set(handles.imgPanel, 'Units', 'pixels', ...
    'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);
    imshow(handles.currImg, 'Parent', handles.imgPanel);

 %enable commands
enableButtons(handles, 'on')

% Update handles structure
guidata(hObject, handles);    


% --- Executes on button press in sr_salient_a.
function sr_salient_a_Callback(hObject, eventdata, handles)
% hObject    handle to sr_salient_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sr_salient_a
%%%if handles.isImage
    handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
    %set imgPanel
    imshow(handles.currImg, 'Parent', handles.imgPanel);
%%%else
    
%%%end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in gaussian.
function gaussian_Callback(hObject, eventdata, handles)
% hObject    handle to gaussian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


input_width = get(handles.targetWidth, 'String');
input_height = get(handles.targetHeight, 'String');

if isempty(str2num(input_width))
    set(handles.targetWidth,'String', handles.currWidth);
    warndlg('Input must be numerical');
    return
end

if isempty(str2num(input_height))
    set(handles.targetHeight,'String', handles.currHeight);
    warndlg('Input must be numerical');
    return
end

input_width = round(str2num(input_width));
input_height = round(str2num(input_height));

if input_width == handles.currWidth && input_height == handles.currHeight
    return
elseif input_width <= 0 || input_width > handles.maxWidth || ...
        input_height <= 0 || input_height > handles.maxHeight
    h = msgbox('Desired dimensions less than 1 or greater than 2 times original image.','Error');
    return
end

%disable all commands except load image
enableButtons(handles, 'off')

set(handles.figure1, 'pointer', 'watch')
drawnow;

updated_img = handles.origImg;

if input_width <= handles.width && input_height <= handles.height
        

        if get(handles.gaussian, 'Value')
            updated_img =  gaussian_reduction([input_height input_width], updated_img, handles.poMask);
         
        end

elseif input_width >= handles.width && input_height >= handles.height
        if get(handles.gaussian, 'Value')
            updated_img =  gaussian_enlarging([input_height input_width], updated_img,'BE');
         
        end
  
       
end


handles.currWidth = input_width;
handles.currHeight = input_height;

handles.currImg = updated_img;

%set texts
set(handles.targetHeight, 'String', num2str(handles.currHeight));
set(handles.targetWidth, 'String', num2str(handles.currWidth));
set(handles.seamHeight, 'String', num2str(handles.currHeight));
set(handles.seamWidth, 'String', num2str(handles.currWidth));

%set imgPanel
    pos = getpixelposition(handles.imgPanel);
    set(handles.imgPanel, 'Units', 'pixels', ...
    'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);
    imshow(handles.currImg, 'Parent', handles.imgPanel);

    %enable commands
enableButtons(handles, 'on')
set(handles.figure1, 'pointer', 'arrow')


% Update handles structure
guidata(hObject, handles); 


% --- Executes on button press in line.
function line_Callback(hObject, eventdata, handles)
% hObject    handle to line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 %%Hint: get(hObject,'Value') returns toggle state of line

    handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
    %set imgPanel
    imshow(handles.currImg, 'Parent', handles.imgPanel);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in graphCutCB.
function graphCutCB_Callback(hObject, eventdata, handles)
% hObject    handle to graphCutCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of graphCutCB
if get(hObject,'Value')
    if handles.isImage
        handles.poMask = zeros(size(handles.currImg,1), size(handles.currImg,2));
        %set imgPanel
        handles.currImg = adjustMedia(handles.currImg, [200, 200], 'image');

        handles.currWidth = size(handles.currImg,2);
        handles.currHeight = size(handles.currImg,1);

        %set texts
        set(handles.targetHeight, 'String', num2str(handles.currHeight));
        set(handles.targetWidth, 'String', num2str(handles.currWidth));
        set(handles.seamHeight, 'String', num2str(handles.currHeight));
        set(handles.seamWidth, 'String', num2str(handles.currWidth));

        pos = getpixelposition(handles.imgPanel);
        set(handles.imgPanel, 'Units', 'pixels', ...
            'Position', [pos(1), pos(2), handles.currWidth, handles.currHeight]);

        %set imgPanel
        imshow(handles.currImg, 'Parent', handles.imgPanel);
    else
        handles.currImg = adjustMedia(handles.currImg, [200, 200], 'video');
        handles.currWidth = size(handles.currImg(1).cdata,2);
        handles.currHeight = size(handles.currImg(1).cdata,1);

        %set texts
        set(handles.targetHeight, 'String', num2str(handles.currHeight));
        set(handles.targetWidth, 'String', num2str(handles.currWidth));
        set(handles.seamHeight, 'String', num2str(handles.currHeight));
        set(handles.seamWidth, 'String', num2str(handles.currWidth));

        pos = getpixelposition(handles.imgPanel);
        set(handles.imgPanel, 'Units', 'pixels', ...
            'Position', [pos(1), pos(2), 0,0]);

        movie(handles.imgPanel, handles.currImg,1,handles.vidObj.FrameRate);
    end
    set(handles.srCB, 'Value',1);
else
    resetButton_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);


% --- Executes on button press in feCB.
function feCB_Callback(hObject, eventdata, handles)
% hObject    handle to feCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of feCB
if handles.isImage
    
end
set(handles.srCB, 'Value',1);

guidata(hObject, handles);

% --- Executes on button press in gcvseamButton.
function gcvseamButton_Callback(hObject, eventdata, handles)
% hObject    handle to gcvseamButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.figure1, 'pointer', 'watch')
drawnow;
enableButtons(handles, 'off')
if handles.isImage
    if get(handles.feCB, 'Value')
        showGraphCutsImageFigure(handles.currImg, 'vertical', 'FE')
    else
        showGraphCutsImageFigure(handles.currImg, 'vertical', 'BE')
    end
    enableButtons(handles, 'on')
    set(handles.saveVideoButton, 'enable', 'off');
    set(handles.playVidButton, 'enable', 'off');
else
    if get(handles.feCB, 'Value')
        showGraphCutsVideoFigure(handles.currImg, 'vertical', 'FE')
    else
        showGraphCutsVideoFigure(handles.currImg, 'vertical', 'BE')
    end
    enableButtons(handles, 'on')
    set(handles.gdCB, 'enable', 'off');
    set(handles.removeOButton, 'enable', 'off');
    set(handles.amplifyButton, 'enable', 'off');
    set(handles.seamHeight, 'enable', 'off');
    set(handles.seamWidth, 'enable', 'off');
    set(handles.showSeamButton, 'enable', 'off');
    set(handles.figure1, 'pointer', 'arrow')
end

% --- Executes on button press in gchseamButton.
function gchseamButton_Callback(hObject, eventdata, handles)
% hObject    handle to gchseamButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'pointer', 'watch')
drawnow;
enableButtons(handles, 'off')
if handles.isImage
    if get(handles.feCB, 'Value')
        showGraphCutsImageFigure(handles.currImg, 'horizontal', 'FE')
    else
        showGraphCutsImageFigure(handles.currImg, 'horizontal', 'BE')
    end
    enableButtons(handles, 'on')
    %set(handles.saveVideoButton, 'enable', 'off');
    set(handles.playVidButton, 'enable', 'off');
else
    if get(handles.feCB, 'Value')
        showGraphCutsVideoFigure(handles.currImg, 'horizontal', 'FE')
    else
        showGraphCutsVideoFigure(handles.currImg, 'horizontal', 'BE')
    end
    enableButtons(handles, 'on')
    set(handles.gdCB, 'enable', 'off');
    set(handles.removeOButton, 'enable', 'off');
    set(handles.amplifyButton, 'enable', 'off');
    set(handles.seamHeight, 'enable', 'off');
    set(handles.seamWidth, 'enable', 'off');
    set(handles.showSeamButton, 'enable', 'off');
    set(handles.figure1, 'pointer', 'arrow')
end


