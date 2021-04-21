clearvars -except average_frequency_vna centerfield
%To use this Measurement you first have to start the server in 
%the xeprapi_server folder found on the Desktop. rpc_server.py has to be
%started from Xenon. The Keysight Spectrum Analyser has to be turned on.
converged = true;




%% connect to devices
vna = get_Anritsu_VNA;               
xepr_rec = get_receiver(7998);

%%setup cleanup
cleanupobj = onCleanup(@() fclose(vna));
cleanupobjwait = onCleanup(@() close(wait));
%% wait for frequency to converge
if(not(converged))
rawdata = frequency_converge(vna);
end

%% setup Variables/var/spool/mail/xuser
if(1==exist('centerfield','var'))
    centerfield = centerfield;
else
    centerfield = 4279; %set manually
    %centerfield = 4279.0; %set manually
end
rawdata.startfield=centerfield - 5; %5 standard
rawdata.endfield=centerfield + 5; %5 standard
%rawdata.startfield=4278.75;
%rawdata.endfield=4288.75;
rawdata.fieldpoints=201; %201 standard

rawdata.Centerfield = (rawdata.startfield+rawdata.endfield)/2;
rawdata.Sweepwidth  = rawdata.endfield-rawdata.startfield;
% xepr_set(xepr_rec, "CenterField", "False"178p5,rawdata.Centerfield);
% xepr_set(xepr_rec, "SweepWidth", "False",rawdata.Sweepwidth);
xepr_set(xepr_rec, "SweepWidth", "False",0);

%% set vna parameters
fprintf(vna, 'CALCulate1:PARAmeter1:MARKer1:x?');
freq_center = str2double(fscanf(vna, '%s'));
freq_span = 5e6; % 5e6
npts = 501;
bw = 1000;
avg = 1;
S_para = 'S21';

set_VNA_Param(vna, freq_center, freq_span, npts, bw, avg, S_para);

freq_axis = linspace(freq_center-freq_span/2, freq_center+freq_span/2, npts);

%% Experiment Name
rawdata.ExpName = ['Y2021-02-19-V_VNA-S21-n55dBm_RT_0.23W_11-Turns_', num2str(rawdata.startfield, '%0.4i'),'-', ...
                    num2str(rawdata.endfield, '%0.4i'), 'G_' num2str(freq_center/1e6, '%0.0f'), ...
                    'MHz_', num2str(freq_span/1e3, '%0.0f'), 'kHz'];
% rawdata.ExpName = ['2020-12-09A_VNA-S11_RT_' num2str(freq_center/1e6, '%0.0f'), ...
%                     'MHz_', num2str(freq_span/1e3, '%0.0f'), 'kHz_crit-coup-characterisation'];

%% 
rawdata.bfield = linspace(rawdata.startfield,rawdata.endfield,rawdata.fieldpoints);
rawdata.frequency = freq_axis;
rawdata.Real = zeros(length(rawdata.bfield),length(freq_axis));
rawdata.Imag = zeros(length(rawdata.bfield),length(freq_axis));
%%
idx = 1;
wait = waitbar(0,'starting Measurement');
timeobj = tic;
for i=1:length(rawdata.bfield)
    set_precise_field(xepr_rec,rawdata.bfield(i));
    %xepr_set(xepr_rec, "CenterField", "False",rawdata.bfield(i));
%     set_field(xepr_rec,rawdata.bfield(i));
    pause(0.1)
    fprintf(vna, ':SENS1:HOLD:FUNC SING');
    fprintf(vna, ':TRIG:SING');
    fprintf(vna, 'CALCulate1:PARAmeter1:DATA:SDATa?');
    pause(0.1)
%     data = binblockread(vna, 'float32');
%     data2 = fread(vna, npts, 'float32');

    for n = 1:length(rawdata.frequency)
        try
            data = fscanf(vna, '%s');
                if n == 1

                    rawdata.Real(i,n) = str2double(data(12:25));
                    rawdata.Imag(i,n) = str2double(data(25:end));

                else

                    rawdata.Real(i,n) = str2double(data(1:14));
                    rawdata.Imag(i,n) = str2double(data(15:end));

                end
        catch
            fclose(vna);
            vna = get_Anritsu_VNA;
            fprintf(vna, ':SENS1:HOLD:FUNC SING');
            fprintf(vna, ':TRIG:SING');
            fprintf(vna, 'CALCulate1:PARAmeter1:DATA:SDATa?');
            pause(0.1);
            data = fscanf(vna, '%s');
            'caught vna'
                if n == 1

                    rawdata.Real(i,n) = str2double(data(12:25));
                    rawdata.Imag(i,n) = str2double(data(25:end));

                else

                    rawdata.Real(i,n) = str2double(data(1:14));
                    rawdata.Imag(i,n) = str2double(data(15:end));

                end
        end

    end
    elapsed = toc(timeobj);
    rawdata.vna_time(i) = elapsed;
    if(i>2)
    elapsed = seconds(round(elapsed));
    remaining = round((elapsed/i*rawdata.fieldpoints)-elapsed);
    elapsed.Format = 'mm:ss';
    remaining.Format = 'mm:ss';
    waitbar(i/rawdata.fieldpoints,wait,['iteration: ', num2str(i),' of ',num2str(rawdata.fieldpoints),' time: ',char(elapsed), ' remaining: ', char(remaining)]);
    end
    %     
%     idx = idx + 1;
%     if idx == 100
%         
%         fclose(vna);
%         pause(1);
%         vna = get_Anritsu_VNA;
%         /var/spool/mail/xuser

%     end
        
end

rawdata.LinMag = sqrt(rawdata.Real.^2 + rawdata.Imag.^2);
rawdata.dBMag = 20.*log10(rawdata.LinMag);


%% check if file exists
while(2 == exist(['/home/xuser/Data/Maser/2020-12-10_GoldRes_10mm-Res_NV/', rawdata.ExpName,'.mat'],'file'))
    num=2;
    rawdata.ExpName = [rawdata.ExpName,sprintf('(%d)',num)];
    num=num+1;
end
%% save
save(['/home/xuser/Data/Maser/2020-12-10_GoldRes_10mm-Res_NV/', rawdata.ExpName,'.mat'], 'rawdata')

%% get average frequency of dip
[average_frequency_vna,~] = vna_average(rawdata);
[rawdata,points] = get_peak_field(rawdata,true);
centerfield = points.centerfield.field;

%% plotting
figure1 = figure(42);
    set(figure1 ...
    , 'Units', 'pixels' ...
    , 'Position', [2150 1115 560 440])
clf(figure1);
axis1 = axes('Parent', figure1);

cmap = pmkmp(256, 'CubicL');

pcolor(rawdata.bfield, rawdata.frequency, rawdata.dBMag')
grid off
shading flat
hold on
colormap (cmap)
colorbar

xlabel('Magnetic Field (G)', 'FontSize', 14);
ylabel('Frequency (GHz)', 'FontSize', 14);
close(wait)
set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency],'or')
fclose(vna);