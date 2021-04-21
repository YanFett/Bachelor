function file_data = strip_metadata_Tresholddata(file_data,Baseline_correction,linmag, wait)
timeobj = tic;
length_fd = length(file_data);
for i=1:length_fd
    file = matfile(file_data(i).file);
    type = file_data(i).type;
    if (type == 'SA')
        [plot_data,~,~] = spectrogramplot(file.rawdata,Baseline_correction,false,linmag,true,false,false);
        rawdata = rmfield(file.rawdata,'signal');
        rawdata.plot_data = plot_data;
    
    
    
    
    else
        if(type == 'VNA')
            try
                delete(file.rawdata.debug.converence_plot.hFigure);
            end
            try
                rawdata = file.rawdata;
                if isfield(rawdata.debug, 'converence_plot') 
                    rawdata.debug = rmfield(rawdata.debug, 'converence_plot');
                    clear file
                    save(file_data(i).file,'rawdata');
                    file = matfile(file_data(i).file);
                end
            end
           
            
        else
            'error, neither VNA nor SA',i
        end
    end
    file_data(i).Metadata = rawdata;
    
    elapsed = toc(timeobj);
    elapsed = seconds(round(elapsed));
    remaining = round((elapsed/i*length_fd)-elapsed);
    elapsed.Format = 'mm:ss';
    remaining.Format = 'mm:ss';
    waitbar(i/length_fd,wait,['File ', num2str(i),' of ',num2str(length_fd),' time: ',char(elapsed), ' remaining: ', char(remaining)]);
end
close(wait)
end