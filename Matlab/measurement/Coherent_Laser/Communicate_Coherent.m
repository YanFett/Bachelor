function power = Communicate_Coherent(command)
%      directory = '/home/xuser/Documents/MATLAB/PowerMax';
%      py_path = py.sys.path;
%      py_path.append(directory);
    py.importlib.import_module('Communicate_Coherent');
    commhandle = py.Communicate_Coherent.Communicate_Coherent();
    power = commhandle.communicate(command);
end