function get_spectrogram(Keysight, size)

fprintf(Keysight, 'INITiate:CONTinuous 0'); % set instrument to single mode
fprintf(Keysight, ['SENSe:AVERage:COUNt ', num2str(size)]);% set length
fprintf(Keysight, 'FORM:TRAC:DATA ASC,8');
fprintf(Keysight, 'INITiate:RESTart'); % Reset and Start measurement
query(Keysight, '*OPC?'); %Wait to finish
fprintf(Keysight,':MMEMory:STORe:RESults:SPECtrogram "spectrotrace.csv"'); %save to file

end