load('E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\freq_shift\\Y2021-02-18-Frequencyshift-longterm-heating-t=50148.mat')
filename = 'Frequency_shift';

frequencies = rawdata.debug.convergence_frequencies/10^9;
timeaxis = rawdata.debug.convergence_timeaxis/3600; %convert to hours
figure1 = figure(2123);
clf(figure1);
hold on
xlim([timeaxis(1), timeaxis(end)]);
ylim([frequencies(end), frequencies(1)]);
linewidth = 1.5;
plot(timeaxis,frequencies,'LineWidth',linewidth);
hold on
xlabel('Time (h)', 'FontSize', 14);
ylabel('Frequency (GHz)', 'FontSize', 14);
set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
legend('resonance frequency')
export_eps(figure1,filename)


return;
for(i=1:length(frequencies)-1)
   x(i) =  abs(frequencies(i)-frequencies(i+1));
end
count = 1;
x(x==0) = NaN;
for(i=1:length(x))
    if(~isnan(x(i)))
        steps(count) = x(i);
        count = count + 1;
    end
end

stepsize = min(x);
max(x)