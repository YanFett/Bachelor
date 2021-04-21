clearvars -except average_frequency_vna centerfield points converged
%To use this Measurement you first have to start the server in 
%the fmeasurement folder found on the Desktop. rpc_server.py has to be
%started from Xenon. The Keysight Spectrum Analyser has to be turned on.
%
%to access Keysight Measured dataset you first have to run this command as
%root:xepr@linux

%mount -t cifs //192.168.1.4/users /home/xuser/Keysight/
%with password Keysight4u!
%then the data will be accessible under /home/xuser/Keysight/Instrument/Documents/RTSA/data/results


%% connect to devices
vna = get_Anritsu_VNA;       
Keysight = get_Keysight;               
xepr_rec = get_receiver(7998);

%% setup cleanup object
cleanupobj = onCleanup(@() fclose(vna));
cleanupobj2 = onCleanup(@() fclose(Keysight));
cleanupobjwait = onCleanup(@() close(wait));
%% setup Variables
if(~exist('converged','var'))
    converged = true;
end
if(1==exist('centerfield','var'))
    centerfield = centerfield;
else
    centerfield = 4.2812e+03; %4283.5; %set manually
end
fielddiff = 1.5;
rawdata.startfield=centerfield-fielddiff;
rawdata.endfield=centerfield+fielddiff;
rawdata.fieldpoints=81;%81;
shift = false;
rawdata.Centerfield = (rawdata.startfield+rawdata.endfield)/2;
rawdata.Sweepwidth  = rawdata.endfield-rawdata.startfield;
% xepr_set(xepr_rec, "CenterField", "False",rawdata.Centerfield);
% xepr_set(xepr_rec, "SweepWidth", "False",rawdata.Sweepwidth);
xepr_set(xepr_rec, "SweepWidth", "False",0);
%% Setup Spectrum Analyzer in Real Time Spectrum Analyzer Mode
set_Keysight_mode(Keysight, 'RTSA');
query(Keysight, '*OPC?'); %Wait to finish
fprintf(Keysight, ':DISP:VIEW SPEC');
pause(5)

filepath = '/home/xuser/Keysight/Instrument/Documents/RTSA/data/results';

%% Setup SA Parameters
if(1==exist('average_frequency_vna','var'))
    freq_center = average_frequency_vna-0.0003e9;
else
    freq_center = 9.1269e9; %set manually
end
total_time = 900;
timeobj = tic;
freq_span = 1e6;
avg_count = 301;
res_bandwidth = 'RBW2'; %accepted values: RBW1=4.8kHz | RBW2=9.61kHz | RBW3=19.2kHz | RBW4=38.4kHz | RBW5=76.9kHz | RBW6=154kHz
acq_time = 105e-6;
attenuation = 0;

set_Keysight_RTSA_Param(Keysight, freq_center, freq_span, avg_count, res_bandwidth, acq_time, attenuation);

freq_axis = linspace(freq_center-freq_span/2,freq_center+freq_span/2,821); %in RTSA mode the frequency traces are fixed to 821 points

%% Experiment Name
rawdata.ExpName = ['Y2021-02-19-V_Spectro_RT_0.23W_11-Turns_', num2str(rawdata.startfield, '%0.4i'),'-', ...
                    num2str(rawdata.endfield, '%0.4i'),'G_', num2str(freq_center/1e6, '%0.0f'), ...
                    'MHz_', num2str(freq_span/1e6, '%0.0f'), 'MHz'];
%% Measure frequency shift
if(shift)
rawdata_before = frequency_shift(vna,total_time,timeobj,false);                
fig = uifigure;                
uiconfirm(fig,'flip the switch to SA','Confirm Close','Icon','warning');

fprintf(vna, ['SENS:FREQ:CENT ', num2str(10e9)]);
fprintf(vna, ':TRIG:SING');
end                
%% 
wait = waitbar(0,'starting Measurement');
first = true;
rawdata.bfield = linspace(rawdata.startfield,rawdata.endfield,rawdata.fieldpoints);
rawdata.time = linspace(acq_time, acq_time*avg_count, avg_count);
rawdata.frequency = freq_axis;
rawdata.signal = cell(length(rawdata.bfield), 1);%zeros(length(rawdata.bfield),length(freq_axis),length(rawdata.bfield));
rawdata.signal_time = zeros(length(rawdata.bfield), 1);%zeros(length(rawdata.bfield),length(freq_axis),length(rawdata.bfield));
for i=1:length(rawdata.bfield)
    
    set_precise_field(xepr_rec,rawdata.bfield(i));
    %xepr_set(xepr_rec, "CenterField", "False",rawdata.bfield(i));
%     set_field(xepr_rec,rawdata.bfield(i));
    if(first)
        pause(1)
        first = false;
    end
    pause(0.5)
    
    get_spectrogram(Keysight, avg_count);
    pause(1)
    
    rawdata.signal{i,1} = import_spectrogram_data(filepath, 'spectrotrace.csv', avg_count);
    elapsed=toc(timeobj);
    rawdata.signal_time(i) = elapsed;
    if(i>2)
    elapsed = seconds(round(elapsed));
    remaining = round((elapsed/i*rawdata.fieldpoints)-elapsed);
    elapsed.Format = 'mm:ss';
    remaining.Format = 'mm:ss';
    waitbar(i/rawdata.fieldpoints,wait,['iteration: ', num2str(i),' of ',num2str(rawdata.fieldpoints),' time: ',char(elapsed), ' remaining: ', char(remaining)]);
    end
end

%% Measure frequency shift
if(shift)
fprintf(vna, ['SENS:FREQ:CENT ', num2str(average_frequency_vna)]);
fprintf(vna, ':SENS1:HOLD:FUNC CONT');

fig = uifigure;                
uiconfirm(fig,'flip the switch to VNA','Confirm Close','Icon','warning');
rawdata_after = frequency_shift(vna,total_time,timeobj,false); 

fprintf(vna, ['SENS:FREQ:CENT ', num2str(10e9)]);
fprintf(vna, ':TRIG:SING');
end   
%%
% try
%     close 42
% end
% figure1 = figure(42);
% set(figure1 ...
%     ,'Units', 'centimeters' ...
%     ,'Position', [-25 8 18 18])
% 
% axis1 = axes('Parent', figure1);
% 
% cmap = pmkmp(256, 'CubicL');
% 
% pcolor(rawdata.frequency./1e6, rawdata.time, rawdata.signal{round(end/2),1})
% grid off
% shading flat
% colormap (cmap)
% colorbar
% 
% xlabel('Frequency (MHz)', 'FontSize', 14);
% ylabel('Time (s)', 'FontSize', 14);
% 
% set(axis1, 'FontName', 'Arial', 'FontSize', 12 ...
%     , 'Box', 'on' ...
%     , 'Position', [.12 .16 .7 .7] ...
%     , 'XMinorTick', 'on' ...
%     , 'YMinorTick', 'on' ...
%     , 'Layer', 'top')
%% plot summary plot
[data,figure2,rawdata] = spectrogramplot(rawdata, true, false, false, points, converged, true);
if(shift)
    rawdata.debug.convergence_before.timeaxis = rawdata_before.debug.convergence_timeaxis;
    rawdata.debug.convergence_before.frequencies = rawdata_before.debug.convergence_frequencies;
    
    rawdata.debug.convergence_after.timeaxis = rawdata_after.debug.convergence_timeaxis;
    rawdata.debug.convergence_after.frequencies = rawdata_after.debug.convergence_frequencies;
    
    rawdata.debug.convergence_before.fit_a = rawdata_before.debug.convergence_fit.a;
    rawdata.debug.convergence_before.fit_b = rawdata_before.debug.convergence_fit.b;
    rawdata.debug.convergence_before.fit_c = rawdata_before.debug.convergence_fit.c;
    
    rawdata.debug.convergence_after.fit_a = rawdata_after.debug.convergence_fit.a;
    rawdata.debug.convergence_after.fit_b = rawdata_after.debug.convergence_fit.b;
    rawdata.debug.convergence_after.fit_c = rawdata_after.debug.convergence_fit.c;
end
%% check if file exists
while(2 == exist(['/home/xuser/Data/Maser/2020-12-10_GoldRes_10mm-Res_NV/', rawdata.ExpName,'.mat'],'file'))
    num=2;
    rawdata.ExpName = [rawdata.ExpName,sprintf('(%d)',num)];
    num=num+1;
end
%% save
save(['/home/xuser/Data/Maser/2020-12-10_GoldRes_10mm-Res_NV/', rawdata.ExpName,'.mat'],'rawdata')
%%

for i=1:size(rawdata.signal)
    trace = rawdata.signal{i};
end
close(wait)
%%reset vna to measurement ready mode
fprintf(vna, ['SENS:FREQ:CENT ', num2str(average_frequency_vna)]);
fprintf(vna, ':SENS1:HOLD:FUNC CONT');
fclose(Keysight);
fclose(vna);