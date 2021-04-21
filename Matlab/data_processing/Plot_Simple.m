    function Plot_Simple(rawdata)
if(isfield(rawdata,'dBMag'))
    plotVNA(rawdata);
else
    spectrogramplot(rawdata,true,false,false);
end 