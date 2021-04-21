function  data = split_file_data(file_data)
Turns_old = -1; % damit Turnscounter immer beim ersten aufruf
Turnscounter = 0; % damit man kein "wenn erstes mal" braucht
Powercounter_VNA = 1;
Powercounter_SA = 1;
for(i=1:length(file_data))
    file = file_data(i);
    Turns = file.T;
    if(Turns_old < Turns)
        Turnscounter = Turnscounter + 1;
        Turns_old = Turns;
        Powercounter_VNA = 1;
        Powercounter_SA = 1;
    end
    if(file.type == 'VNA')
        if(~exist('data','var'))
            data(1,1).VNA = file;
        else
            data(Turnscounter, Powercounter_VNA).VNA = file;
            %['VNA ',num2str(Turnscounter),' ' ,num2str(Powercounter_VNA)]
        end
        Powercounter_VNA = Powercounter_VNA + 1;
    else
       if(~exist('data','var'))
            data(1,1).SA = file;
        else
            data(Turnscounter, Powercounter_SA).SA = file;
            %['SA ',num2str(Turnscounter),' ' ,num2str(Powercounter_SA)]
        end
        Powercounter_SA = Powercounter_SA + 1;
    end
end


end