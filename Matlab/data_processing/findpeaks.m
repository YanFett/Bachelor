function [low,center,high] = findpeaks(VNA_data,SA_data,searchsize,linMag,to_plot, draw_helpers)
if(~exist('to_plot','var'))
    to_plot = true;
end
if(~exist('draw_helpers','var'))
    draw_helpers = true;
end 
if(~exist('linMag','var'))
    linMag = false;
end 
cmap = pmkmp(256, 'CubicL');
rawdata = VNA_data.Metadata;
[~,points] = get_peak_field(rawdata,draw_helpers && to_plot);
if(to_plot)
    figure1 = figure(42);
    hold on
    set(figure1 ...
    , 'Units', 'pixels' ...
    , 'Position', [-1120 520 560 440])
    clf(figure1);
    axis1 = axes('Parent', figure1);

    pcolor(rawdata.bfield, rawdata.frequency, rawdata.dBMag')

    colorbar
    xlabel('Magnetic Field (G)', 'FontSize', 14);
    ylabel('Frequency (GHz)', 'FontSize', 14);
    set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
    title(strjoin(['Turns: ',VNA_data.T,' Power: ',VNA_data.mW,' ',VNA_data.date,' ',VNA_data.id]))
    grid on
    shading flat
    hold on
    colormap (cmap)
        if(draw_helpers && to_plot)
            plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency],'or')
        end    
end

%% plot SA
rawdata = SA_data.Metadata;
if(~linMag)
    rawdata.plot_data = log10(SA_data.Metadata.plot_data)*10;
end
if(to_plot)
    figure1 = figure(44);
    hold on
    set(figure1 ...
    , 'Units', 'pixels' ...
    , 'Position', [-560 520 560 440])
    clf(figure1)
    pcolor(rawdata.bfield,rawdata.frequency,rawdata.plot_data');
    colorbar %colorb = colorbar('horiz');
    xlabel('Magnetic Field (G)', 'FontSize', 14);
    ylabel('Frequency (GHz)', 'FontSize', 14);
    set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
    title(strjoin(['Turns: ',SA_data.T,' Power: ',SA_data.mW,' ',SA_data.date,' ',SA_data.id]))
    %set(colorb,'Position',[0.1 0.05 0.7 0.02])
    grid on
    shading flat
    colormap (cmap)
    hold on
    if(draw_helpers && to_plot)
        plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency],'or')
    end  
end
%% calculate search window
field(1) = points.lowfield.field;
field(2) = points.centerfield.field;
field(3) = points.highfield.field;
searchsize_field = round(searchsize * length(rawdata.plot_data(:,1)));
for(i = 1: 3)
    [~,i_field] = min(abs(rawdata.bfield-field(i)));
    left_bound  = max(i_field-searchsize_field,1);
    right_bound = min(i_field+searchsize_field,length(rawdata.plot_data(:,1)));
    searchmatrix = imgaussfilt(rawdata.plot_data(left_bound:right_bound,:),'FilterSize',3); 
    field_xvals = [rawdata.bfield(left_bound),rawdata.bfield(right_bound),rawdata.bfield(right_bound),rawdata.bfield(left_bound),rawdata.bfield(left_bound)];
    field_yvals = [rawdata.frequency(1),rawdata.frequency(1),rawdata.frequency(end),rawdata.frequency(end),rawdata.frequency(1)];
    [amp_sm(i),~] = max(searchmatrix(:)); %get maximum --> amplitude
    [max_row, max_col] = find(searchmatrix ==amp_sm(i));
    max_frequency_i(i) = max_col;
    max_field_i(i) = max_row + i_field -searchsize_field-1;
    max_field(i) = rawdata.bfield(max_field_i(i));
    max_frequency(i) = rawdata.frequency(max_col);
    amp(i) = rawdata.plot_data(max_field_i(i),max_col);
    if(draw_helpers && to_plot)
        plot(field_xvals,field_yvals,'-r')
    end
    if(to_plot)
        plot(max_field,max_frequency,'*r')
    end
end
%['T ',num2str(T),' mW_i ',num2str(mW),' amp ',num2str(amp(2))]
low = [max_field(1),max_frequency(1),amp(1),max_field_i(1),max_frequency_i(1)];
center = [max_field(2),max_frequency(2),amp(2),max_field_i(2),max_frequency_i(2)];
high = [max_field(3),max_frequency(3),amp(3),max_field_i(3),max_frequency_i(3)];
end