directory = 'E:\Bachelor_data\2020-12-10_GoldRes_10mm-Res_NV\Treshold\';
file = '4T_603mW_VNA_02-03-B.mat';
filee = load([directory,file]);
filee.rawdata.debug = rmfield(filee.rawdata.debug, 'converence_plot');
rawdata = filee.rawdata;
save([directory,file],'rawdata');