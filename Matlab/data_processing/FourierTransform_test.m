load_data = true;
showdata_folder = 'E:\Bachelor_data\2020-12-10_GoldRes_10mm-Res_NV\show_Data\';
Treshold_folder = 'E:\Bachelor_data\2020-12-10_GoldRes_10mm-Res_NV\Treshold\';
if(load_data||~exist('rawdata','var'))
    %load([showdata_folder,'11T_0.3W_VNA_02-23-C.mat'])% VNA
    %load([showdata_folder,'11T_0.3W_SA_02-23-C_8.mat'])% good zoom
    %load([Treshold_folder,'11T_178mW_SA_02-19-C.mat'])%
    %load([Treshold_folder,'11T_178mW_SA_02-19-H.mat'])%
    %load([Treshold_folder,'11T_178mW_VNA_02-19-G.mat'])%
    load([Treshold_folder,'11T_162mW_VNA_01-25-F.mat'])%
    %load([showdata_folder,'11T_0.34W_SA_02-19-K.mat']) %0.34W
    %load([showdata_folder,'11T_0.33W_SA_02-19-L.mat']) %0.33W
    %load([showdata_folder,'11T_0.32W_SA_02-19-M.mat']) %0.32W
    %load([showdata_folder,'11T_0.31W_SA_02-19-N.mat']) %0.31W
    %load([showdata_folder,'11T_0.30W_SA_02-19-O.mat']) %0.30W
    %load([showdata_folder,'11T_0.29W_SA_02-19-P.mat']) %0.29W
    %load([showdata_folder,'11T_0.28W_SA_02-19-Q.mat']) %0.28W
    %load([showdata_folder,'11T_0.27W_SA_02-19-R.mat']) %0.27W
    %load([showdata_folder,'11T_0.26W_SA_02-19-S.mat']) %0.26W
    %load([showdata_folder,'11T_0.25W_SA_02-19-T.mat']) %0.25W
    %load([showdata_folder,'11T_0.24W_SA_02-19-U.mat']) %0.24W
    %load([showdata_folder,'11T_0.23W_SA_02-19-V.mat']) %0.23W
end 
%spectrogramplot(rawdata,true,false,false);
Plot_Simple(rawdata)
return
Fieldarray = rawdata.signal;
Waterfall_cell=Fieldarray(1);
Waterfall = Waterfall_cell{1,1};
plot_data = zeros(length(Fieldarray),length(Waterfall(1,:)));
return
%% iterate over field
for i = 1:length(Fieldarray)
    Waterfall_cell=Fieldarray(i);
    Waterfall = Waterfall_cell{1,1};
    intensities = zeros(length(Waterfall(1,:)),1);
    if(i == 291)
        
        index_minima = zeros(length(Waterfall(:,1)),1);
        for ii=1:length(Waterfall(:,1)')
            [Max,I] = max(Waterfall(ii,:)');
            index_maxima(ii)=I;
            %index_minima(ii) = index;
        end
        maxima = index_maxima;
        figure(8)
        clf
        pcolor(Waterfall')
        hold on
        grid on
        shading flat
        cmap = pmkmp(256, 'CubicL');
        colormap (cmap)
        colorb = colorbar('horiz');
        set(colorb,'Position',[0.1 0.05 0.7 0.02])
        maxima = smooth(maxima,10);
       
        plot(maxima,'green:')
       
        if(true)
        figure(7)
        clf
        %maxima = interp1(1:501,maxima,(1:5010)/10,'spline');
        ft = fft(maxima);
        ft_real = real(ft);
        ft_real = (abs(ft_real));
        plot((1:length(ft_real(2:end/2)))*105e-6,ft_real(2:end/2))
        
        figure(7)
        clf
        n = 2;
        ffty=fft(maxima); % ffty is the fft of y
        lfft=length(ffty); % Length of the FFT
        plot((1:lfft/2),log(ffty(1:end/2)))
        %figure(10)
        %ffty(2:end)=0; % All frequencies between n and lfft-n in the fft are set to zero.
        plot((1:lfft/2),ffty(1:end/2))
        fy=real(ifft(ffty)); % Real part of the inverse fft
        figure(8)
        plot(fy(1:end/1),'b')
        figure(9)
        clf
        plot(fy)
        end
    end
    %% iterate over frequency
    for ii = 1 :length(Waterfall(1,:)) 
        frequency_intensity = Waterfall(:,ii);
        average_intensity = sum(frequency_intensity)/length(frequency_intensity);
        intensities(ii) = average_intensity;
    end
    plot_data(i,:) = intensities;
end

%plot(1 : length(Waterfall(1,:)),rawdata.frequency,plot_data_corrected')