%READWAVEFORM M-Code for communicating with an instrument. 
%  
%   This is the machine generated representation of an instrument control 
%   session using a device object. The instrument control session comprises  
%   all the steps you are likely to take when communicating with your  
%   instrument. These steps are:
%       
%       1. Create a device object   
%       2. Connect to the instrument 
%       3. Configure properties 
%       4. Invoke functions 
%       5. Disconnect from the instrument 
%  
%   To run the instrument control session, type the name of the M-file,
%   readwaveform, at the MATLAB command prompt.
% 
%   The M-file, READWAVEFORM.M must be on your MATLAB PATH. For additional information
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command
%   prompt.
%
%   Example:
%       readwaveform;
%
%   See also ICDEVICE.
%

%   Creation time: 20-May-2009 14:06:28 

ip = '169.254.196.250';
%iptcp = ['TCPIP-',ip];
% Create a TCPIP object.
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', ip, 'RemotePort', 1861, 'Tag', '');
change_field= @set_field_py;
% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = tcpip(ip, 1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Create a device object. 
deviceObj = icdevice('lecroy_basic_driver.mdd', interfaceObj);
set(interfaceObj, 'InputBufferSize', 2000000);


% Connect device object to hardware.
connect(deviceObj);

%prompt = 'How many measurements should be carried out?';

NumberMeasurements = 1; %input(prompt);

params.Freq_Vector = 1e-9*linspace(params.Freq_Start,params.Freq_End,821);

params.Field_Center = 4452.7; %Gauss
params.Field_Sweep = 5; %Gauss
params.Field_Step = 0.01;%0.001; %Gauss
params.Field_Start = params.Field_Center - 0.5*params.Field_Sweep;
params.Field_End = params.Field_Center + 0.5*params.Field_Sweep;
params.Field_Vector = params.Field_Start:params.Field_Step:params.Field_End;

spectra = zeros(length(params.Field_Vector),821);
tic
for Field = params.Field_Vector
for i = 1:NumberMeasurements

% Execute device object function(s).
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);

[Y,X,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel1');

Measurements(:,i) = Y;

end

AverageSignal = mean(Measurements,2);

plot(X(1:(end-1)),Measurements(1:(end-1),:)); % plot figure
title('WaveMaster Waveform Data'); % label title
xlabel('s'); % label x axis
ylabel('V'); % label y axis

% Delete objects.
delete([deviceObj interfaceObj]);
