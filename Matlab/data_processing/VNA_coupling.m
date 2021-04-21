directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\show_Data\\';
filename = 'Processed_Data_03.29_2.mat';
wait_for_user = true;

load([directory,filename])
ii = 1;
for(i=1:length(file_data))
    if(file_data(i).type == 'VNA')
        VNA_data(ii) = file_data(i);
        ii = ii + 1;
    end
end
%% vna tests
for(i = 1: length(VNA_data))
    if(wait_for_user)
        w = 0;
        while w == 0
        w = waitforbuttonpress;
        end
    end
    file = VNA_data(i);
    rawdata = file.Metadata;
    field = rawdata.bfield;
    frequency = rawdata.frequency;
    dBMag = rawdata.dBMag;

    for(i=1:length(dBMag(:,1)))
        cut = 10.^(dBMag(i,:)/10);
        [min_,min_i] = min(cut);
        minima(i) = min_;
        minima_i(i) = min_i;
    end

    figure1 = figure(1);
    clf
    plot(field,datasmooth(minima,5));
    hold on
    yyaxis right
    plot(field,gradient(datasmooth(frequency(minima_i),5)))
end