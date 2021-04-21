function power = get_power_PowerMax()
%      directory = '/home/xuser/Documents/MATLAB/PowerMax';
%      py_path = py.sys.path;
%      py_path.append(directory);
    py.importlib.import_module('PowerMax');
    PowerMax = py.PowerMax.PowerMax();
    power = PowerMax.communicate();
end