function [average_frequency,minima] = vna_average(rawdata)
vna_signal=rawdata.LinMag;
index_minima = zeros(length(vna_signal(:,1)),1);
for i=1:length(vna_signal(:,1)')
    [~,I] = min(vna_signal(i,:)');
    index_minima(i)=I;
    %index_minima(i) = index;
end
minima = index_minima;
average_frequency=rawdata.frequency(round(mean(index_minima)));
return