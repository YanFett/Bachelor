function obj1 = get_Keysight()
%% Keysight Connection
%IP of the Keysight Device
IP = '192.168.1.4';
%Port the Device is listening on
Port = 5025;


% Find a tcpip object.
obj1 = instrfind('Type', 'tcpip', 'RemoteHost', IP, 'RemotePort', Port, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
     obj1 = tcpip(IP, Port);
%     obj1 = visa('NI', 'TCPIP0::134.196.22.1::5025::SOCKET');
else
    fclose(obj1);
    obj1 = obj1(1);
end
obj1.InputBuffer = 1024^2;
obj1.timeout=20;
% Connect to instrument object, obj1.
fopen(obj1);
end