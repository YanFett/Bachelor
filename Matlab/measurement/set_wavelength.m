function temp=set_wavelength(wavelength)
min = 405.0;
max = 685.0; % 650.0
if(wavelength>max)
    'wavelength to big'
    temp = -2;
    return
end
if(wavelength<min)
    'wavelength to small'
    temp = -1;
    return
end
%pyversion /opt/rh/rh-python36/root/usr/bin/python3.6
P = py.sys.path;
if count(P,'/home/xuser/Matlab/python') == 0
    insert(P,int32(0),'/home/xuser/Matlab/python');
end
temp = py.wavelength.set_wavelength(wavelength); %this call is slow and can be 
%further optimized, because the connection is opened each time it is called
