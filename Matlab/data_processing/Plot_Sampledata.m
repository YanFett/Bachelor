directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\Sample_Data\\';
filename = 'Processed_Data_03.29_2.mat';
file_data = Sort_tresholddata(directory);
filename_VNA = 'Sample_VNA';
filename_VNA_der = 'Sample_VNA_der';
filename_SA = 'Sample_SA';
linmag = false;
recalculate = false;
check = true;
draw_helpers = true;
saving = true;


if(recalculate)
    file_data = Sort_tresholddata(directory);
    %x = 1;
    %load(file_data(x).file);
    %Plot_Simple(rawdata)


    Baseline_correction = false;
    linmag = true;
    wait = waitbar(0,'starting to process');
    file_data = strip_metadata_Tresholddata(file_data,Baseline_correction,linmag,wait);
    save([directory,filename], 'file_data')
else
    load([directory,filename])
end

%% Plot VNA
file = file_data(2);
[figure2,points] = plot_filedata(file,draw_helpers);
figure3 = figure(45);
%% Plot SA
file = file_data(1);
[figure1,~] = plot_filedata(file,draw_helpers,points,linmag);

%% create eps files
if(saving)
    export_eps(figure1,['Sampledata\\',filename_SA])
    export_eps(figure2,['Sampledata\\',filename_VNA])
    export_eps(figure3,['Sampledata\\',filename_VNA_der])
end
return
