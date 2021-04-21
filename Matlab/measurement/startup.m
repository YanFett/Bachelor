directory = '/home/xuser/Documents/MATLAB/PowerMax';
directory2 = '/home/xuser/Documents/MATLAB/Coherent_Laser';
addpath '/home/xuser/Documents/MATLAB/Coherent_Laser';
py_path = py.sys.path;
py_path.append(directory);
py_path.append(directory2);
clear all