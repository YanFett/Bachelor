function rec=get_receiver(port)
%adding to javapath could be done cleaner
jlibpath = '/home/xuser/Documents/MATLAB/lib/';
java_libraries = {...
    'commons-logging-1.1.jar', ...
    'ws-commons-util-1.0.2.jar', ...
    'xmlrpc-client-3.1.3.jar', ...
    'xmlrpc-common-3.1.3.jar', ...
    'xmlrpc-server-3.1.3.jar' ...
    };

for jlib = 1:length(java_libraries)
    javaaddpath([jlibpath, java_libraries{jlib}], '-end');
end

client = javaObject('org.apache.xmlrpc.client.XmlRpcClient');

config = javaObject('org.apache.xmlrpc.client.XmlRpcClientConfigImpl');

url = javaObject('java.net.URL', ['http://192.168.1.1:',num2str(port)]);

config.setServerURL(url);

client.setConfig(config);
rec = client;
end
%gets a connection to a server on this machine.
    

