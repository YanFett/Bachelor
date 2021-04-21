function [rawdata,field] = get_peak_field(rawdata,plotthis)
[~,minima] = vna_average(rawdata);
rawdata.debug.vna.minima = minima;
rawdata.debug.vna.xaxis = rawdata.bfield;
smooth_minima= datasmooth(gradient(datasmooth(minima,2)),2);
[max_diff,~]= islocalmax(smooth_minima,'MinSeparation',8,'MaxNumExtrema',3);
if(plotthis)
    plot1 = figure(45);
    clf(plot1)
    set(plot1 ...
    , 'Units', 'pixels' ...
    , 'Position', [2150 1720 560 440])
    xaxis = rawdata.bfield;
    plot(xaxis,smooth_minima,xaxis(max_diff),smooth_minima(max_diff),'r*');
    xlim([xaxis(1),xaxis(end)])
end
x = find(max_diff);
legend(['center: ',num2str(rawdata.bfield(x(2)))],['Lowfield: ',num2str(rawdata.bfield(x(1))), 'Highfield: ',num2str(rawdata.bfield(x(3)))],'Location','southeast')
rawdata.debug.vna.lowfield = rawdata.bfield(x(1));
rawdata.debug.vna.centerfield = rawdata.bfield(x(2));
rawdata.debug.vna.highfield = rawdata.bfield(x(3));
rawdata.debug.vna.lowfield_frequency = minima(x(1));
rawdata.debug.vna.centerfield_frequency = minima(x(2));
rawdata.debug.vna.highfield_frequency = minima(x(3));
field.lowfield.field = rawdata.bfield(x(1));
field.centerfield.field = rawdata.bfield(x(2));
field.highfield.field = rawdata.bfield(x(3));
field.lowfield.frequency = rawdata.frequency(minima(x(1)));
field.centerfield.frequency = rawdata.frequency(minima(x(2)));
field.highfield.frequency = rawdata.frequency(minima(x(3)));
end