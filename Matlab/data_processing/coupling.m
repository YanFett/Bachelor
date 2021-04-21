clear all
directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\coupling_stuff\\';
savedir = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\Abbildungen\\coupling\\';
filename_out = 'Processed_Data_03.29_2.mat';
filename_in = '2021_02_24_A_DarkMeasurement_Coupling.mat';
filename_plot = 'coupling';




measured_turns_1 = [4.5;5;5.5;6;6.5;7;8;9;10;11;12];
measured_turns_2 = [4.5;5.5;6;6.5;7;9;11]; 
measured_turns_3 = [4.5;5;5.5;6;6.5;7;8;9;10;11;12]; 

load([directory,filename_in]);
turns = rawdata.turns*0.75;
dBMag = rawdata.dBMag;
imag = rawdata.Imag;
linmag = rawdata.LinMag;
reald = rawdata.Real;
absi = sqrt(imag.^2+reald.^2);
frequency = rawdata.frequency/10^9;
saving = true;

    %figure1 = figure(422);
    for(i=1:length(imag(:,1)))

        w=1;
        while w == 0
            w = waitforbuttonpress;
        end
        %clf
        [mini,minpos] = min(absi(i,:));
        %plot(frequency,imag(i,:));
        vz = reald(i,minpos);
        A_val = absi(i,minpos);
        if(vz>0)
            coupling_num(i) = (1-A_val)/(1+A_val);
        else
            coupling_num(i) = (1+A_val)/(1-A_val);    
        end
        %hold on
        %yyaxis right
        %plot(frequency,dBMag(i,:));

        %title(['turns: ',num2str(turns(i)),' coupling: ',num2str(coupling_num(i))]);
    end
figure2 =figure(456);
clf
newcolors = [0 0.4470 0.741 
             0 0.5 0];
colororder(newcolors)
yyaxis left
linewidth = 1.5;
plot(turns,coupling_num,'LineWidth',linewidth);
hold on

hold on

ylabel('\kappa* ', 'FontSize', 14);
for(i=1:length(dBMag(:,1)))
  [dBMin,dBMin_i]=min(dBMag(i,:));
  [dBMax,dBMax_i]=max(dBMag(i,:));
  minima(i) = dBMin;
  minima_i(i) = dBMin_i;
  maxima(i) = dBMax;
  maxima_i(i) = dBMax_i;
  min_freq(i) = frequency(dBMin_i);
end
%%testing
    yyaxis right
   plot(turns,minima);
    hold on
    plot(turns,maxima);

    xlim([0 29.5*0.75]);
    ymin = -77;
    ymax = -32;
    ylim([ymin ymax])
    x1 = 0.6;
    x2 = 2.52;
    x3 = 6;
    plot([x1,x1],[ymin,ymax],'--k')
    plot([x2,x2],[ymin,ymax],'--k')
    plot([x3 x3],[ymin,ymax],'--b')
    xlabel('Screw depth (mm)', 'FontSize', 14);
    ylabel('Dip depth (dBmW)', 'FontSize', 14);
    legend('coupling','dip depth','baseline height','critical coupling','','length of the resonator cavity','Location','east')
    % yyaxis right
    % plot(turns,smooth(min_freq,5));
    % x = turns(14:53);
    % y = minima(14:53);%10.^(minima(14:end)/10);
figure1 = figure(42);
pos2 = [0.13 0.12 0.71 0.83];
cbpos = [0.85 0.12 0.02 0.83];

    set(figure1 ...
    , 'Units', 'pixels' ...
    , 'Position', [-1120 520 560 440])
clf(figure1);
ax2 =subplot('Position',pos2);
%axis1 = axes('Parent', figure1);

cmap = pmkmp(256, 'CubicL');

plot(turns,min_freq,'k');
hold on
pcolor(ax2,turns, frequency, dBMag')
plot(turns,min_freq,'k');

x1 = 0.6;
x2 = 2.52;
x3 = 6;
ymin = min(frequency);
ymax = max(frequency);
plot([x1 x1],[ymin,ymax],'--k')
plot([x2 x2],[ymin,ymax],'--k')
plot([x3 x3],[ymin,ymax],'--b')
grid off
shading flat
ylim([9.1267 9.1275])
xlim([0 29.5*0.75])
hold on
colormap (cmap)
colorb = colorbar;
colorb.Label.String = 'Intensity (dBmW)';
colorb.Label.FontSize = 14;
colorb.Position = cbpos;
legend('resonance frequency','','','critical coupling','','length of the resonator cavity','Location','southeast')


xlabel('Screw depth (mm)', 'FontSize', 14);
ylabel('Frequency (GHz)', 'FontSize', 14);

set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
% coupling try





if(saving)
    export_eps(figure1,'\\coupling\\Dip_shift')%[savedir,'Dip_shift'])
    export_eps(figure2,'\\coupling\\coupling')
end
return
%% transfer dip depth to measured turns
for(i=1:length(measured_turns_1))
    index = find(turns == measured_turns_1(i));
    dip_depths_1(i)=coupling_num(index);
end

for(i=1:length(measured_turns_2))
    index = find(turns == measured_turns_2(i));
    dip_depths_2(i)=coupling_num(index);
end

for(i=1:length(measured_turns_3))
    index = find(turns == measured_turns_3(i));
    dip_depths_3(i)=coupling_num(index);
end