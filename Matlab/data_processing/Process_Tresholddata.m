directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\Treshold\\';
filename_save = 'Processed_Data_03.29_2.mat';
%% sort data into struct
recalculate = false;
reload = false;
check = recalculate;
linmag = false; %% carefull, there is a second linmag!
to_plot = true;
searchsize = 0.08;
wait_for_user = false;
if(recalculate)
    
file_data = Sort_tresholddata(directory);

%% strip and add metadata and generate plotdata
Baseline_correction = true;
linmag_gen = true;
wait = waitbar(0,'starting to process');
file_data = strip_metadata_Tresholddata(file_data,Baseline_correction,linmag_gen,wait);
save([directory,filename_save], 'file_data')


%%rearrange file_data, so that SA and VNA is separated and its more easily
%%accessible
file_data = split_file_data(file_data);
save([directory,filename_save], 'file_data')
end

if(~exist('file_data','var')||reload)
load([directory,filename_save])
end
%% check if every measurement has exactly one partner
if(check)
err_count = 0;
for(i=1:length(file_data(:,1)))
    for ii = 1:length(file_data(i,:))
        if(~isempty(file_data(i,ii).SA))
            if(~(file_data(i,ii).SA.mW == file_data(i,ii).VNA.mW && file_data(i,ii).SA.T == file_data(i,ii).VNA.T && file_data(i,ii).SA.id == file_data(i,ii).VNA.id))
                err_count = err_count + 1;
                T_err(err_count) = i;
                mW_err(err_count) = ii;
            end
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

%% 
cmap = pmkmp(256, 'CubicL');
draw_helpers = true;
saving = false;
for(T=1:length(file_data(:,1)))
    for mW = 1:length(file_data(T,:))
        if(~isempty(file_data(T,mW).SA))
            if(wait_for_user)
                w = 0;
                while w == 0
                w = waitforbuttonpress;
                end
            end
            %%
            file = file_data(T,mW).VNA;
            [figure2,points] = plot_filedata(file,draw_helpers);
            filename = split(file.file,'\');
            filename = filename(end);
            filename = filename{1};
            filename = filename(1:end-4);
            if(saving)
                export_eps(figure2,['Treshold\',filename])
            end
            file = file_data(T,mW).SA;
            rawdata = file.Metadata;
            [figure1,~] = plot_filedata(file,false,points,linmag);
            filename = split(file.file,'\');
            filename = filename(end);
            filename = filename{1};
            filename = filename(1:end-4);
            %export_eps(figure1,['Treshold\',filename])
                   
%             %% plot VNA
%             dat = file_data(T,mW).VNA;
%             rawdata = dat.Metadata;
%             [~,points] = get_peak_field(rawdata,draw_helpers&&to_plot);
%             if(to_plot)
%                 figure1 = figure(42);
%                 hold on
%                 set(figure1 ...
%                 , 'Units', 'pixels' ...
%                 , 'Position', [-1120 520 560 440])
%                 clf(figure1);
%                 axis1 = axes('Parent', figure1);
% 
%                 pcolor(rawdata.bfield, rawdata.frequency, rawdata.dBMag')
% 
%                 colorbar
%                 xlabel('Magnetic Field (G)', 'FontSize', 14);
%                 ylabel('Frequency (GHz)', 'FontSize', 14);
%                 set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
%                 title(strjoin(['Turns: ',dat.T,' Power: ',dat.mW,' ',dat.date,' ',dat.id]))
%                 grid on
%                 shading flat
%                 hold on
%                 colormap (cmap)
%                     if(draw_helpers && to_plot)
%                         plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency],'or')
%                     end    
%             end
% 
%             %% plot SA
%             dat = file_data(T,mW).SA;
%             rawdata = dat.Metadata;
%             if(~linMag)
%                 rawdata.plot_data = 10*log10(rawdata.plot_data);
%             end
%             if(to_plot)
%                 figure1 = figure(44);
%                 hold on
%                 set(figure1 ...
%                 , 'Units', 'pixels' ...
%                 , 'Position', [-560 520 560 440])
%                 clf(figure1)
% 
% 
%                 pcolor(rawdata.bfield,rawdata.frequency,rawdata.plot_data');
% 
%                 colorbar %colorb = colorbar('horiz');
%                 xlabel('Magnetic Field (G)', 'FontSize', 14);
%                 ylabel('Frequency (GHz)', 'FontSize', 14);
%                 set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
%                 title(strjoin(['Turns: ',dat.T,' Power: ',dat.mW,' ',dat.date,' ',dat.id]))
%                 %set(colorb,'Position',[0.1 0.05 0.7 0.02])
%                 grid on
%                 shading flat
%                 colormap (cmap)
%                 hold on
%                 if(draw_helpers && to_plot)
%                     plot([points.lowfield.field,points.centerfield.field,points.highfield.field],[points.lowfield.frequency,points.centerfield.frequency,points.highfield.frequency],'or')
%                 end  
%             end
            %% calculate search window
            field(1) = points.lowfield.field;
            field(2) = points.centerfield.field;
            field(3) = points.highfield.field;
            searchsize_field = round(searchsize * length(rawdata.plot_data(:,1)));
            figure1;
            hold on
            for(i = 1: 3)
                [~,i_field] = min(abs(rawdata.bfield-field(i)));
                left_bound  = max(i_field-searchsize_field,1);
                right_bound = min(i_field+searchsize_field,length(rawdata.plot_data(:,1)));
                searchmatrix = rawdata.plot_data(left_bound:right_bound,:);
                field_xvals = [rawdata.bfield(left_bound),rawdata.bfield(right_bound),rawdata.bfield(right_bound),rawdata.bfield(left_bound),rawdata.bfield(left_bound)];
                field_yvals = [rawdata.frequency(1),rawdata.frequency(1),rawdata.frequency(end),rawdata.frequency(end),rawdata.frequency(1)];
                amp(i) = max(searchmatrix(:)); %get maximum --> amplitude
                [max_row, max_col] = find(searchmatrix ==amp(i));
                max_field_i = max_row + i_field -searchsize_field-1;
                max_field = rawdata.bfield(max_field_i);
                max_frequency = rawdata.frequency(max_col);
                if(draw_helpers && to_plot && false)
                    plot(field_xvals,field_yvals,'-r')
                end
                if(to_plot)
                    plot(max_field,max_frequency,'*r')
                end
            end
            file_data(T,mW).amp=amp;
            file_data(T,mW).coupling(1) = points.lowfield.coupling;
            file_data(T,mW).coupling(2) = points.centerfield.coupling;
            file_data(T,mW).coupling(3) = points.highfield.coupling;
            file_data(T,mW).coupling(4) = points.coupling;
            
            %['T ',num2str(T),' mW_i ',num2str(mW),' amp ',num2str(amp(2))]
            if(saving)
                export_eps(figure1,['Treshold\\',filename])
            end
        end
    end

end
save([directory,filename_save], 'file_data')
return

%% setup 3D Plot Data
for(T=1:length(file_data(:,1)))
    for(mW = 1:length(file_data(T,:)))
        if(~isempty(file_data(T,mW).SA))
            x_axis(T,mW) = file_data(T,mW).SA.mW;
            if(linmag)
                y_axis(T,mW) = file_data(T,mW).amp(2);
            else
                y_axis(T,mW) = 10*log10(file_data(T,mW).amp(2));
            end
        end
    end
    x_axis(find(x_axis==0)) = NaN;
    y_axis(find(y_axis==0)) = NaN;
    if(to_plot)
        figure(123)
        plot(x_axis(T,:),y_axis(T,:))
        title(['screw depth: ',num2str(file_data(T,1).SA.T*0.75),'mm  \kappa*',num2str(file_data(T,1).coupling(4))])
        xlabel('Power (mW)', 'FontSize', 14);
        ylabel('Intensity (A.U.)', 'FontSize', 14);   
    end
end

%%
turns = [0 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3 3.25 3.5 3.75 4 4.25 4.5 4.75 5 5.25 5.5 5.75 6 6.25 6.5 6.75 7 7.25 7.5 7.75 8 8.25 8.5 8.75 9 9.25 9.5 9.75 10 10.25 10.5 10.75 11 11.25 11.5 11.75 12 12.25 12.5 12.75 13 13.25 13.5 13.75 14 14.25 14.5 14.75 15 15.25 15.5 15.75 16 16.25 16.5 16.75 17 17.25 17.5 17.75 18 18.25 18.5 18.75 19 19.25 19.5 19.75 20 20.25 20.5 20.75 21 21.25 21.5 21.75 22 22.25 22.5 22.75 23 23.25 23.5 23.75 24 24.25 24.5 24.75 25 25.25 25.5 25.75 26 26.25 26.5 26.75 27 27.25 27.5 27.75 28 28.25 28.5 28.75 29 29.25 29.5];
coupling_minima = [-58.5428025603646 -76.2606748716707 -67.1531028400855 -69.149259342878 -57.2570744326809 -53.998811898447 -55.9316918324192 -56.624412622278 -52.8381894858671 -52.134059902822 -55.8373563358396 -58.8209742272376 -60.4893701912433 -64.3285179229145 -61.0619764805528 -54.3559218232999 -53.7418231160312 -51.1528812066108 -47.1488150049355 -45.328145905365 -44.4617646930858 -43.2323628715613 -41.7422545435487 -40.9310935019746 -40.6174850106886 -40.2029616770813 -39.2410773817712 -38.663034574588 -38.5143800992271 -38.2229136692492 -37.8671045515985 -37.5051281402701 -37.448937570717 -37.395785122653 -37.1458130657949 -36.953533681663 -36.9708837712315 -36.9717257088172 -36.8576474210059 -36.7683838329774 -36.8274020712661 -36.853957442389 -36.8134529583833 -36.7900735797727 -36.838380273735 -36.8745393072677 -36.849124971342 -36.8529244522389 -36.8585412094371 -36.8846039730388 -36.885443855417 -36.9279263012606 -36.9667434474459 -36.9721325499529 -37.0073390499635 -37.0143287984499 -37.0434005703682 -37.0700714302794 -37.081199552596 -37.1063533059238 -37.1388621094834 -37.17432794468 -37.1770305828959 -37.2176982831927 -37.2507595955645 -37.2861361324003 -37.3318378871736 -37.3339170743928 -37.3766855409499 -37.3964851327443 -37.4091544190766 -37.4501007866928 -37.4643818230296 -37.466262641727 -37.4975031105191 -37.499544448851 -37.5152075516072 -37.5209632071438 -37.5245941558584 -37.5410294635048 -37.5386184779447 -37.5483569835526 -37.5468307236588 -37.5479286212927 -37.5512833835487 -37.5343736799524 -37.5738408122559 -37.5523877075222 -37.5612988991942 -37.5605362576374 -37.5502265388232 -37.5461339532573 -37.5526418335656 -37.5520923266874 -37.5581135810338 -37.5629404544106 -37.54654153934 -37.5471790423792 -37.544127981699 -37.5607242374415 -37.5459048077763 -37.5445878053355 -37.5506022332696 -37.5639165356371 -37.537937867778 -37.5344667458299 -37.564014653562 -37.5527128864287 -37.5520837757869 -37.5557601521913 -37.556570305958 -37.5484269919385 -37.5516454589348 -37.5426672735313 -37.5476007122352 -37.5528314551934 -37.5508207090211 -37.558057726453 -37.5537395893234];
vis_thresholds = [0,519,371,344,267,222,179,161,152,146,138,154];
for(T=1:length(file_data(:,1)))
    filename = ['T_',num2str(file_data(T,1).SA.T)];
    w = 1 ;
    while w == 0
    w = waitforbuttonpress;
    end
    figure1 = figure(12341);
    clf
    legendstr = 'Centerpeak height';
    coup_pos = turns==file_data(T,1).SA.T;
    coupling = coupling_minima(coup_pos);
    titlestr = ['screw depth: ',num2str(file_data(T,1).SA.T*0.75),'mm  \kappa*: ',num2str(file_data(T,1).coupling(4))];
    
    figure1 = plot_treshold(x_axis(T,:),datasmooth(y_axis(T,:),1),legendstr,titlestr,false,figure1,vis_thresholds(T));
    %plot(1:length(y_axis(T,:)),y_axis(T,:))
    
    %plot(x_axis(T,:),datasmooth(y_axis(T,:),1))
    %title(['Turns: ',num2str(T)])
    %title(['Turns: ',num2str(file_data(T,1).SA.T)])
    %xlabel('Power (mW)', 'FontSize', 14);
    %ylabel('Intensity (A.U.)', 'FontSize', 14);            
    if(saving)
        export_eps(figure1,['Treshold\\graphs\\',filename])
    end
end

return
%% 3D Plot
x = 1;
for(i = 1 : length(x_axis(:,1)))
    filename = '3D_Plot'
    for(ii = 1 : length(x_axis(1,:)))
        if(~isnan(x_axis(i,ii)))
            plot_matrix(i,ii,1) = file_data(i,1).SA.T;
            plot_matrix(i,ii,2) = x_axis(i,ii);
            plot_matrix(i,ii,3) = y_axis(i,ii);
            plot_array_x(x) = file_data(i,1).SA.T;
            plot_array_y(x) = x_axis(i,ii);
            plot_array_z(x) = (y_axis(i,ii));
            x = x + 1;
        end
    end
end
figure1 = figure(584)
clf
plot_matrix(find(plot_matrix==0)) = NaN;
scatterbar3(plot_array_x,plot_array_y,plot_array_z,0.45,5,y_axis(1,1))
xlabel('Screw Turns', 'FontSize', 14);
ylabel('Pump Laser Power (mW)', 'FontSize', 14);
zlabel('Intensity (dBm)', 'FontSize', 14);
%legend('Center Peak intensities')
grid on
set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
%savethis = false
if(false)
    export_eps(figure1,['Treshold\\graphs\\',filename])
end
%% plot


return
x = 14;
dat = file_data(x);
rawdata = file_data(x).Metadata;
if(file_data(x).type == 'SA')
    figure1 = figure(44);
    hold on
    set(figure1 ...
    , 'Units', 'pixels' ...
    , 'Position', [-560 520 560 440])
    clf(figure1)
    pcolor(rawdata.bfield,rawdata.frequency/10^9,rawdata.plot_data');
    colorbar %colorb = colorbar('horiz');
    xlabel('Magnetic Field (G)', 'FontSize', 14);
    ylabel('Frequency (GHz)', 'FontSize', 14);
    set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
    title(strjoin(['Turns: ',dat.T,' Power: ',dat.mW,' ',dat.date,' ',dat.id]))
    %set(colorb,'Position',[0.1 0.05 0.7 0.02])
else
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
    title(strjoin(['Turns: ',dat.T,' Power: ',dat.mW,' ',dat.date,' ',dat.id]))
end
    grid on
    shading flat
    colormap (cmap)
    
return
%% mean time frequency convergence
sum = 0;
num = 0;
for(T=1:length(file_data(:,1)))
    for mW = 1:length(file_data(T,:))
         if(~isempty(file_data(T,mW).SA))
             try
             sum = sum + file_data(T, mW).VNA.Metadata.debug.convergence_timeaxis(end);
             num = num + 1;
             catch
                 T
                 mW
             end
         end
    end
end
mean = sum/num;