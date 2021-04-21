function [pdatacorr,plot1,rawdata] = spectrogramplot(rawdata,Baseline_correction,name,linmag,points,converged,draw_helpers)
%% data initialization
if(~exist('linmag','var'))
    linmag = true;
end 
if(~exist('draw_helpers','var'))
    draw_helpers = false;
end 
if(~exist('name','var'))
    name = false;
end 

if(~exist('converged','var'))
    converged = true;
end 
if(~exist('Baseline_correction','var'))
    Baseline_correction = true;
end 
Fieldarray = rawdata.signal;
Waterfall_cell=Fieldarray(1);
Waterfall = Waterfall_cell{1,1};    
plot_data = zeros(length(Fieldarray),length(Waterfall(1,:)));
%% iterate over field
for i = 1:length(Fieldarray)
    Waterfall_cell=Fieldarray(i);
    Waterfall = Waterfall_cell{1,1};
    intensities = zeros(length(Waterfall(1,:)),1);
    %% iterate over frequency
    for ii = 1 :length(Waterfall(1,:)) 
        frequency_intensity = Waterfall(:,ii);
        average_intensity = sum(frequency_intensity)/length(frequency_intensity);
        intensities(ii) = average_intensity;
    end
    plot_data(i,:) = intensities;
end
%% Baseline correction
plot_data_corrected = plot_data;
plot_data_baseline = [plot_data(1:10,:)',plot_data(end-9:end,:)']';
if(Baseline_correction)
    baseline=sum(plot_data_baseline,1)/length(plot_data_baseline(:,1));
    plot_data_corrected = plot_data - baseline;
end


%% correction analysis
[~,I] = max(plot_data_corrected,[],'all','linear');
MaxBaseline = plot_data_corrected(I);
MaxNoBaseline = plot_data(I);
Baselineshift = MaxNoBaseline - MaxBaseline;
plot_data_corrected = plot_data_corrected + Baselineshift;
[~,I2] = min(plot_data_corrected,[],'all','linear');
MaxBaseline = plot_data_corrected(I);
MinBaseline = plot_data_corrected(I2);
MinNoBaseline = plot_data(I2);
deltaBaseline = MaxBaseline - MinBaseline;
deltaNobaseline = MaxNoBaseline - MinNoBaseline;
maxdiff = ((deltaBaseline/deltaNobaseline)-1)*100;
difftext = [num2str(maxdiff),'%'];
if(linmag)
    plot_data_corrected = 10.^((plot_data_corrected)/10);
end
pdatacorr=plot_data_corrected;
%% maximum lines
xmeans = zeros(length(plot_data_corrected(:,1)),1);
xmaxima = zeros(length(plot_data_corrected(:,1)),1);
xmaxima_i = zeros(length(plot_data_corrected(:,1)),1);
for i=1:length(plot_data_corrected(:,1))
    [Max,I] = max(plot_data_corrected(i,:));
    xmaxima(i) = Max;
    xmaxima_i(i) = I;
    mean1 = mean(plot_data_corrected(i,:));
    xmeans(i) = mean1;
end

ymeans = zeros(length(plot_data_corrected(1,:)),1);
ymaxima = zeros(length(plot_data_corrected(1,:)),1);
ymaxima_i = zeros(length(plot_data_corrected(1,:)),1);
for i=1:length(plot_data_corrected(1,:))
    [Max,I] = max(plot_data_corrected(:,i));
    ymaxima(i) = Max;
    ymaxima_i(i) = I;
    mean1 = mean(plot_data_corrected(:,i));
    ymeans(i) = mean1;
end

%% plotting
%size(plot)
%size(rawdata.bfield)
%size(rawdata.frequency)
try
    close 44
end
if(name)
plotname = ['Summary Plot: ',rawdata.ExpName];
plot1 = figure("Name",plotname ,"NumberTitle","off");
else
plot1 = figure(44);
end
clf(plot1)
set(plot1 ...
    , 'Units', 'pixels' ...
    , 'Position', [2720 1196 1120 964])
pos1 = [0.1 0.85 0.7 0.1];
ax1 =subplot('Position',pos1);
field_data = plot_data_corrected(:,:);
plot(rawdata.bfield,field_data,'.k');
%plot(rawdata.bfield,xmaxima);
hold on
%plot(rawdata.bfield,xmeans);
xlim([rawdata.bfield(1),rawdata.bfield(end)])

pos3 = [0.85 0.1 0.1 0.7];
ax3 =subplot('Position',pos3);
frequency_data = plot_data_corrected(:,:)';
plot(frequency_data,rawdata.frequency,'.k');
%plot(ymaxima,rawdata.frequency);
hold on
%plot(ymeans,rawdata.frequency);
ylim([rawdata.frequency(1),rawdata.frequency(end)]);




pos2 = [0.1 0.1 0.7 0.7];
ax2 =subplot('Position',pos2);
pcolor(rawdata.bfield,rawdata.frequency,plot_data_corrected');
%if(~(points.centerfield. == ''))
hold on
%% peakfinding
if(exist('points','var'))
    if(~converged)
        delta = 1e+4;
        lowfield_frequency = points.lowfield.frequency-delta;
        centerfield_frequency =points.centerfield.frequency-delta;
        highfield_frequency = points.highfield.frequency-delta;
    else
        lowfield_frequency = points.lowfield.frequency;
        centerfield_frequency =points.centerfield.frequency;
        highfield_frequency = points.highfield.frequency;
    end
    
    stepwidth = rawdata.bfield(2)-rawdata.bfield(1);
    searchsize_field= round(((0.45/stepwidth)/2)-1); %4 as standard if 81 fieldpoints
    searchsize_freq = 60;
    [~,i_lowfield_field] = min(abs(rawdata.bfield-points.lowfield.field));
    [~,i_lowfield_frequency] = min(abs(rawdata.frequency-lowfield_frequency));
    lowfield_xvals = [rawdata.bfield(i_lowfield_field-searchsize_field),rawdata.bfield(i_lowfield_field+searchsize_field),rawdata.bfield(i_lowfield_field+searchsize_field),rawdata.bfield(i_lowfield_field-searchsize_field),rawdata.bfield(i_lowfield_field-searchsize_field)];
    lowfield_yvals = [rawdata.frequency(i_lowfield_frequency-searchsize_freq),rawdata.frequency(i_lowfield_frequency-searchsize_freq),rawdata.frequency(i_lowfield_frequency+searchsize_freq),rawdata.frequency(i_lowfield_frequency+searchsize_freq),rawdata.frequency(i_lowfield_frequency-searchsize_freq)];
    low_searchmatrix = plot_data(i_lowfield_field-searchsize_field:i_lowfield_field+searchsize_field,i_lowfield_frequency-searchsize_freq:i_lowfield_frequency+searchsize_freq);
    l_max = max(low_searchmatrix(:));
    [l_row, l_col] = find(low_searchmatrix ==l_max);
    l_field_i = l_row + i_lowfield_field -searchsize_field-1;
    l_field = rawdata.bfield(l_field_i);
    l_frequency_i = l_col + i_lowfield_frequency -searchsize_freq-1;
    l_frequency = rawdata.frequency(l_frequency_i);
    rawdata.Peaks.low.field = l_field;
    rawdata.Peaks.low.frequency = l_frequency;
    rawdata.Peaks.low.amp = l_max;
    

    [~,i_centerfield_field] = min(abs(rawdata.bfield-points.centerfield.field));
    [~,i_centerfield_frequency] = min(abs(rawdata.frequency-centerfield_frequency));
    centerfield_xvals = [rawdata.bfield(i_centerfield_field-searchsize_field),rawdata.bfield(i_centerfield_field+searchsize_field),rawdata.bfield(i_centerfield_field+searchsize_field),rawdata.bfield(i_centerfield_field-searchsize_field),rawdata.bfield(i_centerfield_field-searchsize_field)];
    centerfield_yvals = [rawdata.frequency(i_centerfield_frequency-searchsize_freq),rawdata.frequency(i_centerfield_frequency-searchsize_freq),rawdata.frequency(i_centerfield_frequency+searchsize_freq),rawdata.frequency(i_centerfield_frequency+searchsize_freq),rawdata.frequency(i_centerfield_frequency-searchsize_freq)];
    center_searchmatrix = plot_data(i_centerfield_field-searchsize_field:i_centerfield_field+searchsize_field,i_centerfield_frequency-searchsize_freq:i_centerfield_frequency+searchsize_freq);
    c_max = max(center_searchmatrix(:));
    [c_row, c_col] = find(center_searchmatrix ==c_max);
    c_field_i = c_row + i_centerfield_field -searchsize_field-1;
    c_field = rawdata.bfield(c_field_i);
    c_frequency_i = c_col + i_centerfield_frequency -searchsize_freq-1;
    c_frequency = rawdata.frequency(c_frequency_i);
    rawdata.Peaks.center.field = c_field;
    rawdata.Peaks.center.frequency = c_frequency;
    rawdata.Peaks.center.amp = c_max;
    
    %c_frequency_i = 
    [~,i_highfield_field] = min(abs(rawdata.bfield-points.highfield.field));
    [~,i_highfield_frequency] = min(abs(rawdata.frequency-highfield_frequency));
    highfield_xvals = [rawdata.bfield(i_highfield_field-searchsize_field),rawdata.bfield(i_highfield_field+searchsize_field),rawdata.bfield(i_highfield_field+searchsize_field),rawdata.bfield(i_highfield_field-searchsize_field),rawdata.bfield(i_highfield_field-searchsize_field)];
    highfield_yvals = [rawdata.frequency(i_highfield_frequency-searchsize_freq),rawdata.frequency(i_highfield_frequency-searchsize_freq),rawdata.frequency(i_highfield_frequency+searchsize_freq),rawdata.frequency(i_highfield_frequency+searchsize_freq),rawdata.frequency(i_highfield_frequency-searchsize_freq)];
    high_searchmatrix = plot_data(i_highfield_field-searchsize_field:i_highfield_field+searchsize_field,i_highfield_frequency-searchsize_freq:i_highfield_frequency+searchsize_freq);
    h_max = max(high_searchmatrix(:));
    [h_row, h_col] = find(high_searchmatrix ==h_max);
    h_field_i = h_row + i_highfield_field -searchsize_field-1;
    h_field = rawdata.bfield(h_field_i);
    h_frequency_i = h_col + i_highfield_frequency -searchsize_freq-1;
    h_frequency = rawdata.frequency(h_frequency_i);
    rawdata.Peaks.high.field = h_field;
    rawdata.Peaks.high.frequency = h_frequency;
    rawdata.Peaks.high.amp = h_max;
    plot(l_field,l_frequency,'*r')
    plot(c_field,c_frequency,'*r')
    plot(h_field,h_frequency,'*r')
    if(draw_helpers)
        plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[lowfield_frequency,centerfield_frequency,highfield_frequency],'or');
        plot(lowfield_xvals,lowfield_yvals,'-r')
        plot(centerfield_xvals,centerfield_yvals,'-r')
        plot(highfield_xvals,highfield_yvals,'-r')
    end
    
    
end
%end
%surf(plot_data_corrected)
%linkaxes([ax1,ax2],'x')
%[a,b] = max(plot_data_corrected)
if(exist('points','var'))
    field_max = [l_field,c_field,h_field];
    field_max_amp = [l_max,c_max,h_max];
    plot(ax1,field_max,10.^(field_max_amp./10),'r*')

    freq_max = [l_frequency,c_frequency,h_frequency];
    plot(ax3,10.^(field_max_amp./10),freq_max,'r*')
end
hold on
legend(difftext)
%set(plot, 'EdgeColor', 'none')
grid on
shading flat
cmap = pmkmp(256, 'CubicL');
colormap (cmap)
colorb = colorbar('horiz');
set(colorb,'Position',[0.1 0.05 0.7 0.02])
linkaxes([ax1,ax2],'x')
linkaxes([ax3,ax2],'y')
hold off
if(false)
plot2 = figure("Name",plotname ,"NumberTitle","off");
set(plot2 ...
    , 'Units', 'centimeters' ...
    , 'Position', [50 20 23 23])
axis2 = axes('Parent', plot2);
surf(10.^(plot_data_corrected./10))
hold on
legend(difftext)
%set(plot, 'EdgeColor', 'none')
grid on
shading flat
cmap = pmkmp(256, 'CubicL');
colormap (cmap)
colorbar
xlabel('Frequency (GHz)', 'FontSize', 14);
ylabel('Field (G)', 'FontSize', 14);
set(axis2, 'FontName', 'Arial', 'FontSize', 12 ...
    , 'Box', 'on' ...
    , 'Position', [.12 .16 .7 .7] ...
    , 'XMinorTick', 'on' ...
    , 'YMinorTick', 'on' ...
    , 'Layer', 'top')
hold off
end

%% peak categorizer
%['amp ',num2str(h_max),' index field ',num2str(h_field_i),' index freq ',num2str(h_frequency_i)]
%['xmax_i ',num2str(xmaxima_i(h_field_i)), ' ymax_i ', num2str(ymaxima_i(h_frequency_i))]
if(exist('points','var'))
    %% 1: correlation
    %if the peak is a maximum in both y and x axis, it is a peak.
    %lowfield
    xval = l_field_i;
    yval = l_frequency_i;
    xmax = xmaxima_i(xval);
    ymax = ymaxima_i(yval);
    
    %['lowfield correlation ','xval: ', num2str(xval),' ymax: ', num2str(ymax),' yval: ', num2str(yval),' xmax: ', num2str(xmax),' result: ', mat2str((xval == ymax)&&(yval == xmax))]
    if((xval == ymax)&&(yval == xmax))
        rawdata.Peaks.low.correlation = true;
    else
        rawdata.Peaks.low.correlation = false;
    end
    %centerfield
    xval = c_field_i;
    yval = c_frequency_i;
    xmax = xmaxima_i(xval);
    ymax = ymaxima_i(yval);
    
    %['centerfield correlation ','xval: ', num2str(xval),' ymax: ', num2str(ymax),' yval: ', num2str(yval),' xmax: ', num2str(xmax),' result: ', mat2str((xval == ymax)&&(yval == xmax))]
    if((xval == ymax)&&(yval == xmax))
        rawdata.Peaks.center.correlation = true;
    else
        rawdata.Peaks.center.correlation = false;
    end
    %highfield
    xval = h_field_i;
    yval = h_frequency_i;
    xmax = xmaxima_i(xval);
    ymax = ymaxima_i(yval);
    
    %['highfield correlation ','xval: ', num2str(xval),' ymax: ', num2str(ymax),' yval: ', num2str(yval),' xmax: ', num2str(xmax),' result: ', mat2str((xval == ymax)&&(yval == xmax))]
    if((xval == ymax)&&(yval == xmax))
        rawdata.Peaks.high.correlation = true;
    else
        rawdata.Peaks.high.correlation = false;
    end
    %% statistical
    %if the peak is prominent enough in regards to the background it is a peak
    %IUPAC says: The critical limit is when a the chance of finding a peak
    %without true signal is lower than x%, where x can be defined.
    x = 0.01;
    critical_val =norminv(1-x/2);
    std_dev = 1.5*std(plot_data_corrected(:));
    mean1 = mean(plot_data_corrected(:));
    lin_l_max = 10^((l_max)/10);
    %lin_l_max = l_max;
    %['lowfield statistic ','critical= ',num2str(mean1+std_dev*critical_val), ' l val= ',num2str(lin_l_max), ' result ',mat2str(lin_l_max > mean1+std_dev*critical_val)]
    if(lin_l_max > mean1+std_dev*critical_val)
        rawdata.Peaks.low.statistical = true;
    else
        rawdata.Peaks.low.statistical = false;
    end    
    lin_c_max = 10^((c_max)/10);
    %lin_c_max = c_max;
    
    %['centerfield statistic ','critical= ',num2str(mean1+std_dev*critical_val), ' c val= ',num2str(lin_c_max), ' result ',mat2str(lin_c_max > mean1+std_dev*critical_val)]
    if(lin_c_max > mean1+std_dev*critical_val)
        rawdata.Peaks.center.statistical = true;
    else
        rawdata.Peaks.center.statistical = false;
    end    
    lin_h_max = 10^((h_max)/10);
    %lin_h_max = h_max;
    %['highfield statistic ','critical= ',num2str(mean1+std_dev*critical_val), ' h val= ',num2str(lin_h_max), ' result ',mat2str(lin_h_max > mean1+std_dev*critical_val)]
    if(lin_h_max > mean1+std_dev*critical_val)
        rawdata.Peaks.high.statistical = true;
    else
        rawdata.Peaks.high.statistical = false;
    end    
    
    %['correlation: Low ', mat2str(rawdata.Peaks.low.correlation), ' center ', mat2str(rawdata.Peaks.center.correlation),' high ' ,mat2str(rawdata.Peaks.high.correlation)]
end
end

