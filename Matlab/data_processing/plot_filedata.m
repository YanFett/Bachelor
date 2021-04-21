function [figure1,points] = plot_filedata(file,draw_helpers,points,linmag,figurenum)
% coupling stuff
format_str_c = '%.5f';
    if(~exist('draw_helpers','var'))
        draw_helpers = false;
    end
    
    if(~exist('linmag','var'))
        linmag = false;
    end
    
    if(~exist('figurenum','var'))
        if(file.type == 'VNA')
            figurenum = 2;
        else
            figurenum = 1;
        end
    end 
    pos2 = [0.13 0.12 0.71 0.73];
    cbpos = [0.85 0.12 0.02 0.73];
    cmap = pmkmp(256, 'CubicL');
    if(file.type == 'VNA')
        rawdata = file.Metadata;
        [~,points] = get_peak_field(rawdata,draw_helpers);
        figure1 = figure(figurenum);
        hold on
        set(figure1 ...
        , 'Units', 'pixels' ...
        , 'Position', [-1120 520 560 440])
        clf(figure1);
        %axis1 = axes('Parent', figure1);
        ax2 =subplot('Position',pos2);
        pcolor(rawdata.bfield, rawdata.frequency/10^9, rawdata.dBMag')

        colorb = colorbar; %colorb = colorbar('horiz');
        colorb.Label.String = 'Intensity (dBm)';
        colorb.Label.FontSize = 14;
        colorb.Position = cbpos;
        xlabel('Magnetic Field (G)', 'FontSize', 14);
        ylabel('Frequency (GHz)', 'FontSize', 14);
        set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
        %strjoin(['Turns: ',file.T,' Power: ',file.mW,' ',file.date,' ',file.id])
        title({['Screw depth: ',num2str(file.T*0.75),'mm  pump laser power: ',num2str(file.mW), 'mW'],[  'center-field \kappa*: ',num2str(points.coupling,format_str_c)]})
        grid off
        shading flat
        hold on
        colormap (cmap)
        if(draw_helpers)
            xpos1 = 0.5;
            xpos2 = 0.05;
            format_str = '%.5f';
            plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency]/10^9,'ko')
            text(xpos1,0.90,['Low-field frequency: ',num2str(points.lowfield.frequency/10^9,format_str),' GHz' ],'Units','normalized', 'FontSize', 8)
            text(xpos1,0.80,['Center-field frequency: ',num2str(points.centerfield.frequency/10^9,format_str),' GHz' ],'Units','normalized', 'FontSize', 8)
            text(xpos1,0.70,['High-field frequency: ',num2str(points.highfield.frequency/10^9,format_str),' GHz' ],'Units','normalized', 'FontSize', 8)
            text(xpos1,0.95,['Low-field magnetic field: ',num2str(points.lowfield.field),' G'  ],'Units','normalized', 'FontSize', 8)
            text(xpos1,0.85,['Center-field magnetic field: ',num2str(points.centerfield.field),' G'  ],'Units','normalized', 'FontSize', 8)
            text(xpos1,0.75,['High-field magnetic field: ',num2str(points.highfield.field),' G'  ],'Units','normalized', 'FontSize', 8)
            text(xpos2,0.95,['Low-field \kappa*: ',num2str(points.lowfield.coupling,format_str_c)  ],'Units','normalized', 'FontSize', 8)
            text(xpos2,0.90,['Center-field \kappa*: ',num2str(points.centerfield.coupling,format_str_c)  ],'Units','normalized', 'FontSize', 8)
            text(xpos2,0.85,['High-field \kappa*: ',num2str(points.highfield.coupling,format_str_c)  ],'Units','normalized', 'FontSize', 8)
        end   
    else
        x_axis = file.Metadata.bfield;
        y_axis = file.Metadata.frequency/10^9;
        if(~linmag)
            plot_data = 10*log10(file.Metadata.plot_data);
%             kpwarum = true;
%             if(kpwarum)
%                plot_data = plot_data + 30; 
%             end
        else
            plot_data = file.Metadata.plot_data;
        end
        figure1 = figure(figurenum);
        hold on
        set(figure1 ...
        , 'Units', 'pixels' ...
        , 'Position', [-560 520 560 440])
        clf(figure1)


        ax2 =subplot('Position',pos2);
        pcolor(x_axis,y_axis,plot_data');

        colorb = colorbar; %colorb = colorbar('horiz');
        colorb.Label.String = 'Intensity (dBm)';
        colorb.Label.FontSize = 14;
        colorb.Position = cbpos;
        xlabel('Magnetic Field (G)', 'FontSize', 14);
        ylabel('Frequency (GHz)', 'FontSize', 14);
        set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
        
        %strjoin(['Turns: ',file.T,' Power: ',file.mW,' ',file.date,' ',file.id])
        title({['screw depth: ',num2str(file.T*0.75),'mm  pump laser power: ',num2str(file.mW), 'mW'],[  'center-field \kappa*: ',num2str(points.coupling,format_str_c)]})
        %set(colorb,'Position',[0.1 0.05 0.7 0.02])
        grid off
        shading flat
        colormap (cmap)
        hold on
        if(draw_helpers)
            plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency]/10^9 ,'ko')
        end     
        
        
    end
end