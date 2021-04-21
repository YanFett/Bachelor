directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\show_Data\\';
filename = 'Processed_Data_03.29_2.mat';


linmag = false;
recalculate = false;
check = true;
to_plot = false;
draw_helpers = false;
wait_for_user = to_plot;
cmap = pmkmp(256, 'CubicL');
saving_all = true;
saving = true;

if(recalculate)
    file_data = Sort_tresholddata(directory);
    %x = 1;
    %load(file_data(x).file);
    %Plot_Simple(rawdata)


    Baseline_correction = true;
    linmag_gen = true;
    wait = waitbar(0,'starting to process');
    file_data = strip_metadata_Tresholddata(file_data,Baseline_correction,linmag_gen,wait);
    save([directory,filename], 'file_data')
else
    load([directory,filename])
end
%% remove zooms and other unwanted data
VNA_count = 1;
SA_count = 1;
for(i = 1: length(file_data))
    if(file_data(i).date == '02-19' && strlength(file_data(i).id) == 1)
        if(file_data(i).type == 'SA')
            hr_treshold(SA_count,1) = file_data(i);
            SA_count = SA_count + 1;
        else
            hr_treshold(VNA_count,2) = file_data(i);
            VNA_count = VNA_count + 1;
        end
    end
end

%% check for pairedness

if(check)
err_count = 0;
for(i=1:length(hr_treshold(:,1)))
    for ii = 1:length(hr_treshold(i,:))
        if(~(hr_treshold(i,ii).mW == hr_treshold(i,ii).mW && hr_treshold(i,ii).T == hr_treshold(i,ii).T && hr_treshold(i,ii).id == hr_treshold(i,ii).id))
            err_count = err_count + 1;
            T_err(err_count) = i;
            mW_err(err_count) = ii;
        end
    end
end
if(err_count>0)
    for(i=1:length(T_err))
        ['T: ',num2str(T_err(i)),' mW: ',num2str(mW_err(i))]
    end
    error('measurements not partnered')
end
end


%% find peaks
for(i =1 : length(hr_treshold))
    if(wait_for_user)
        w = 0;
        while w == 0
            w = waitforbuttonpress;
        end
    end
    [low,center,high]=findpeaks(hr_treshold(i,2),hr_treshold(i,1),0.10,linmag,to_plot, draw_helpers);
    for(ii = 1: length(low))
        low_peaks(i,ii) = low(ii);
    end
    for(ii = 1: length(center))
        center_peaks(i,ii) = center(ii);
    end
    for(ii = 1: length(high))
        high_peaks(i,ii) = high(ii);
    end
end

%% save pcolor
if(saving_all)
    draw_helpers = false;
    for(i=1:length(hr_treshold))
        file = hr_treshold(i,2);
        [figure2,points] = plot_filedata(file,draw_helpers);
        filename = split(file.file,'\');
        filename = filename(end);
        filename = filename{1};
        filename = filename(1:end-4);
        export_eps(figure2,['Showdata\\',filename])
        file = hr_treshold(i,1);
        [figure1,~] = plot_filedata(file,draw_helpers,points,linmag);
        filename = split(file.file,'\');
        filename = filename(end);
        filename = filename{1};
        filename = filename(1:end-4);
        export_eps(figure1,['Showdata\\',filename])
    end
    return
end

%% plot treshold
if(exist('tresh_figure1','var'))
   try
   clf(tresh_figure1);
   close(tresh_figure1);
   end
   clear tresh_figure1;
end
save_treshold = true;
do_gradient = true;
doublelog = false;
linmag_tresh = false;
for(i = 1: length(hr_treshold(:,1)))
    mW_axis(i) = hr_treshold(i,1).mW * 1000;
end
% linmag
if(linmag_tresh || doublelog)
    plot_peaks(1,:) = 10.^(low_peaks(:,3)/10); 
    plot_peaks(2,:) = 10.^(center_peaks(:,3)/10); 
    plot_peaks(3,:) = 10.^(high_peaks(:,3)/10); 
end

figure(12312)
clf
hold on
if(~do_gradient)
    plot_peaks(1,:) = low_peaks(:,3); 
    plot_peaks(2,:) = center_peaks(:,3); 
    plot_peaks(3,:) = high_peaks(:,3); 
else
    plot_peaks(1,:) = gradient(gradient(low_peaks(:,3))); 
    plot_peaks(2,:) = gradient(gradient(center_peaks(:,3))); 
    plot_peaks(3,:) = gradient(gradient(high_peaks(:,3))); 
end
if(doublelog)
    mW_axis = log(mW_axis);
end
    
legendstr = ["low-field peak","center-field peak","high-field peak"];
titlestr = "";%"Maximum peak intensities";
for(i=1:3)
    %tresh_figure1
    if(~exist('tresh_figure1','var'))

        tresh_figure1 = plot_treshold(mW_axis,plot_peaks(i,:),legendstr(i),titlestr,do_gradient);
    else
        tresh_figure1 = plot_treshold(mW_axis,plot_peaks(i,:),legendstr(i),"",do_gradient,tresh_figure1);
    end
    %tresh_figure1
    hold on

                
end
sz = 8;
for(i = 1: 3)
    if(i==1) % lowfield
        %plot(
    end
    if(i==2) % centerfield
        h = plot(mW_axis(10),plot_peaks(i,10),'bd');
        h.MarkerFaceColor = 'b'; 
        h.MarkerSize = sz; 
        h = plot(mW_axis(6),plot_peaks(i,6),'gd');
        h.MarkerFaceColor = 'g'; 
        h.MarkerSize = sz; 
    end
    if(i==3) % highfield
        h = plot(mW_axis(12),plot_peaks(i,12),'gd');
        h.MarkerFaceColor = 'g'; 
        h.MarkerSize = sz; 
    end
end
if(save_treshold)
    if(~doublelog)
        if(~do_gradient)
            export_eps(tresh_figure1,'Showdata\\Showdata_treshold');
        else
            export_eps(tresh_figure1,'Showdata\\Showdata_treshold_gradient');
        end
    else
        export_eps(tresh_figure1,'Showdata\\Showdata_tresholddl');
    end
end

return

%% plot cuts field
linewidth = 1.5;
fieldcuts = figure(1231);
clf(fieldcuts)
hold on
diff = 20;
for(ii = 1: length(hr_treshold(:,1)))
    i = length(hr_treshold(:,1))-(ii-1); 
    if(~linmag)
        plot_data = log10(hr_treshold(i,1).Metadata.plot_data)*10;
    end
    x_axis = hr_treshold(i,1).Metadata.bfield*100;
    peak_field = center_peaks(i,4);
    shift = x_axis(peak_field);
    lower_bound = max(peak_field-diff,1);
    upper_bound = min(peak_field+diff,length(plot_data(:,1)));
    cut = plot_data(lower_bound:upper_bound,center_peaks(i,5));
    plot_xaxis = x_axis(lower_bound:upper_bound) - shift;
    plot(plot_xaxis ,cut,'LineWidth',linewidth)
    legappend(num2str(hr_treshold(i,1).mW*1000));
    field_axis=x_axis(lower_bound:upper_bound);
    leftside = cut(1:maxima_i(ii));
    rightside = cut(maxima_i(ii):end);
    ldiff_val = (maxima(ii)+leftside(1))/2;
    rdiff_val = (maxima(ii)+rightside(end))/2;
    [lhalfheight(ii),lhalfheight_i(ii)]=min(abs(leftside-ldiff_val));
    [rhalfheight(ii),rhalfheight_i(ii)]=min(abs(rightside-rdiff_val));
    halfwidth_field(i) = fwhm(plot_xaxis,cut-min(cut));
    mW(ii) = hr_treshold(i,1).mW*1000;
end
xlabel('\Delta Magnetic Field (\muT)', 'FontSize', 14);
ylabel('MASER emission intensity (dBm)', 'FontSize', 14);
set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
leg = legend();
hlt = text(...
    'Parent', leg.DecorationContainer, ...
    'String', 'pump laser power (mW)', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.00, 0], ...
    'Units', 'normalized');

set(leg,'Position', [0.2050 0.4010 0.1286 0.4598]);
axis tight;
hold on
export_eps(fieldcuts,'Showdata\\fieldcuts');
%% plot cuts frequency
freqcuts = figure(1232);
clf(freqcuts)
%leg = legend();

hold on
diff = 20;
big_diff = 50;
singlecut = false;
linewidth = 1.5;
for(ii = 1: length(hr_treshold(:,1)))
    i = length(hr_treshold(:,1))-(ii-1);

    
    %i = length(hr_treshold(:,1))-(ii-1); 
    if(~linmag)
        plot_data = log10(hr_treshold(i,1).Metadata.plot_data)*10;
    else
        plot_data = hr_treshold(i,1).Metadata.plot_data;
    end
    x_axis = hr_treshold(i,1).Metadata.frequency;
    peak_freq = center_peaks(i,5);
    

    if(~singlecut)
        shift = x_axis(peak_freq);
        lower_bound = max(peak_freq-diff,1);
        upper_bound = min(peak_freq+diff,length(plot_data(1,:)));
        cut = plot_data(center_peaks(i,4),lower_bound:upper_bound);
        fit_cut = cut-min(cut);
        plot_xaxis = (x_axis(lower_bound:upper_bound) - shift)/10^3;
        [fit,gof] = gaussFit(plot_xaxis,fit_cut);
        plot(plot_xaxis,cut,'LineWidth',linewidth);
        hold on
        FWHM = fwhm(plot_xaxis,fit_cut);
        halfwidth_freq(i) = FWHM;
        %plot([-FWHM/2,FWHM/2],[33.14/2+min(cut), 33.14/2+min(cut)],'*r')

    else
        file = hr_treshold(i,1);
        mat_file = matfile([file.file]);
        rawdata = mat_file.rawdata;
        Fieldarray = rawdata.signal;
        Waterfall_cell=Fieldarray(center_peaks(i,4));
        Waterfall = Waterfall_cell{1,1};
        for(Waterfall_i=1:length(Waterfall(:,1)))
            temp_lower = max(peak_freq-big_diff,1);
            temp_upper = min(peak_freq-big_diff,length(Waterfall(1,:)));
            cut = Waterfall(Waterfall_i,450:end);%lower_bound:upperbound)
            basecut(Waterfall_i,:) = cut;
            [maxi,max_i]=max(cut);
            %shift(Waterfall_i) = x_axis(max_i);
            lower_bound = max(max_i-diff,1);
            upper_bound = min(max_i+diff,length(Waterfall(1,:)));
            try
            onecut(Waterfall_i,:) = cut(lower_bound:upper_bound);
            end
        end
        freqcut.cuthistograms(i,:,:) = onecut;
        freqcut.cuts(i,:) = sum(onecut,1)/length(onecut(:,1));
        shift = x_axis(diff+1);
        freqcut.frequencies(i,:)= (x_axis(1:41)-shift)/10^3;
        
        plot(freqcut.frequencies(i,:),freqcut.cuts(i,:),'LineWidth',linewidth);
        
    end
    
    legappend(num2str(hr_treshold(i,1).mW*1000));
    [maxima(ii),maxima_i(ii)]=max(cut);
%     freq_axis=x_axis(lower_bound:upper_bound);
%     leftside = cut(1:maxima_i(ii));
%     rightside = cut(maxima_i(ii):end);
%     ldiff_val = (maxima(ii)+leftside(1))/2;
%     rdiff_val = (maxima(ii)+rightside(end))/2;
%     [lhalfheight(ii),lhalfheight_i(ii)]=min(abs(leftside-ldiff_val));
%     [rhalfheight(ii),rhalfheight_i(ii)]=min(abs(rightside-rdiff_val));
%     halfwidth_freq(ii) = abs(freq_axis(rhalfheight_i(ii))-freq_axis(lhalfheight_i(ii)));

    mW(ii) = hr_treshold(i,1).mW*1000;
end
xlabel('\Delta Frequency (kHz)', 'FontSize', 14);
ylabel('MASER emission intensity (dBm)', 'FontSize', 14);
set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
leg = legend();
hlt = text(...
    'Parent', leg.DecorationContainer, ...
    'String', 'pump laser power (mW)', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.00, 0], ...
    'Units', 'normalized');

set(leg,'Position', [0.2050 0.4010 0.1286 0.4598]);

axis tight;
hold on
if(saving)
    export_eps(freqcuts,'Showdata\\freqcuts');
end
do_contour = true;
%% 2d surface stack
fig =figure(1233);
clf
axis = gca;
axis.Visible = 'off';
axis.XTick = [];
axis.YTick = []; 
axis.ZTick = []; 
hold on
grid off
shading interp
diff_x = 30;
diff_y = 30;
caxis auto
for(i = 1:length(hr_treshold(:,1)))
    if(~linmag)
        plot_data = log10(hr_treshold(i,1).Metadata.plot_data*10);
    end
    ax(i) = axes;
    x_axis = hr_treshold(i,1).Metadata.bfield;
    y_axis = hr_treshold(i,1).Metadata.frequency;
    peak_field = center_peaks(i,4);
    peak_frequency = center_peaks(i,5);
    shift_field = x_axis(peak_field);
    shift_frequency = y_axis(peak_frequency);
    lower_bound_field = max(peak_field-diff_x,1);
    upper_bound_field = min(peak_field+diff_x,length(plot_data(:,1)));
    lower_bound_frequency = max(peak_frequency-diff_y,1);
    upper_bound_frequency = min(peak_frequency+diff_y,length(plot_data(1,:)));
    total_length = upper_bound_field - lower_bound_field;
    cut = plot_data(lower_bound_field:upper_bound_field,lower_bound_frequency:upper_bound_frequency);
    if(do_contour)
        x=20;
        h = contour3(ax(i),x_axis(lower_bound_field:upper_bound_field) - shift_field,y_axis(lower_bound_frequency:upper_bound_frequency) - shift_frequency,cut',min(40+(x*12)-x*i,120));
    else
        x = 13;
        h = surf(ax(i),x_axis(lower_bound_field:upper_bound_field) - shift_field,y_axis(lower_bound_frequency:upper_bound_frequency) - shift_frequency,cut');
        i
        alph = min(1,(3*((x-i)/(3*x+1-i))))
        set(h, 'edgeAlpha',alph)
        alpha(h,alph)
    end
    colormap (cmap)
    %i

    grid off
end
Link = linkprop(fliplr(ax),{'CameraUpVector', 'CameraPosition', 'CameraTarget','XLim','YLim','ZLim'});
for(i=2:length(ax))
    ax(i).Visible = 'off';
    ax(i).XTick = [];
    ax(i).YTick = []; 
end
drawnow
%%
%for(i = 1: length(file_data))
    if(wait_for_user)
        w = 0;
        while w == 0
            w = waitforbuttonpress;
        end
    end
    i
    file = file_data(i);
    type = file.type;
    rawdata = file.Metadata;
    cmap = pmkmp(256, 'CubicL');
    if(type == 'VNA')
        figure1 = figure(42);
        hold on
        set(figure1 ...
        , 'Units', 'pixels' ...
        , 'Position', [-1120 520 560 440])
        clf(figure1);
        axis1 = axes('Parent', figure1);

        pcolor(rawdata.bfield, rawdata.frequency/10^9, rawdata.dBMag')

        colorbar
        xlabel('Magnetic Field (G)', 'FontSize', 14);
        ylabel('Frequency (GHz)', 'FontSize', 14);
        set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
        title(strjoin(['Turns: ',file.T,' Power: ',file.mW,' ',file.date,' ',file.id]))
        grid on
        shading flat
        hold on
        colormap (cmap)
    else
        if(~linmag)
            rawdata.plot_data = log10(rawdata.plot_data)*10;
        end
        figure1 = figure(44);
        hold on
        set(figure1 ...
        , 'Units', 'pixels' ...
        , 'Position', [-560 520 560 440])
        clf(figure1)


        pcolor(figure1,rawdata.bfield,rawdata.frequency/10^9,rawdata.plot_data');

        colorbar %colorb = colorbar('horiz');
        xlabel('Magnetic Field (G)', 'FontSize', 14);
        ylabel('Frequency (GHz)', 'FontSize', 14);
        set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
        title(strjoin(['Turns: ',file.T,' Power: ',file.mW,' ',file.date,' ',file.id]))
        %set(colorb,'Position',[0.1 0.05 0.7 0.02])
        grid on
        shading flat
        colormap (cmap)
        hold on         
    end
%end

return
%% plot Sample plots

for(i=1:length(x(1,1,:)))
    siz = size(x);
    y = reshape(x,[siz(2:end) 1]);
    
end
    