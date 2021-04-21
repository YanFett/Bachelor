directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\Sample_Data\\';
filename = 'Frequency_converge';
file_data = Sort_tresholddata(directory);
load(file_data(3).file);
saving = true;
%file = file_data(2);
%rawdata = file.Metadata;
dbg = rawdata.debug;
x_axis = dbg.convergence_timeaxis/60;
y_axis = dbg.convergence_frequencies/1e9;
target = dbg.convergence_target/1e9;%(end);
optimum = dbg.convergence_Optimum/1e9;%(end);
targets = zeros(length(x_axis),1);
optima = zeros(length(x_axis),1);
optima(optima==0) = optimum;
targets(targets==0) = target;
figure1 = figure(23);
clf
linewidth = 1.5;
plot(x_axis,y_axis,'LineWidth',linewidth);
hold on
plot(x_axis,optimum,'LineWidth',linewidth);
plot(x_axis,target,'LineWidth',linewidth);

xlim([x_axis(1) x_axis(end)]);
ylim([y_axis(end)-0.0001 y_axis(1)]);
xlabel('Time (min)')
ylabel('Frequency (GHz)')
legend('Resonance frequency','Current projected frequency shift Limit','Current frequency target')
if(saving)
    export_eps(figure1,['Sampledata\\',filename])
end