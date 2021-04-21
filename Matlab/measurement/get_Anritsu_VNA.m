function obj1 = get_Anritsu_VNA()
%% Anritsu VNA Connection
%IP of the Anritsu Device
IP = '192.168.1.4';
%Port the Device is listening on
Port = 5001;


% Find a tcpip object.
obj1 = instrfind('Type', 'tcpip', 'RemoteHost', IP, 'RemotePort', Port, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
     obj1 = tcpip(IP, Port);
%     obj1 = visa('NI', 'TCPIP0::192.168.1.4::5001::SOCKET');
else
    fclose(obj1);
    obj1 = obj1(1);
end
obj1.InputBuffer = 1024^2;
obj1.timeout=20;
% Connect to instrument object, obj1.
fopen(obj1);
end