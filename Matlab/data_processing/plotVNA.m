function rawdata = plotVNA(rawdata,draw_helpers)
%% get average frequency of dip
if(~exist('draw_helpers','var'))
    draw_helpers = true;
end 

if(draw_helpers)
    [rawdata,points] = get_peak_field(rawdata,true);
end
%% plotting
figure1 = figure(42);
    set(figure1 ...
    , 'Units', 'pixels' ...
    , 'Position', [-1321 620 560 440])
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

set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
if(draw_helpers)
    plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency],'or')
end
end