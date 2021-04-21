function freq = get_Peakfreq(Keysight)
%fprintf(Keysight, ':CALCulate:MARKer:CPSearch:STATe OFF'); % turn continous peak search off
%fprintf(Keysight, ':CALCulate:MARKer:MAXimum'); % Set marker to highest point in spectrogram
freq = str2double(query(Keysight, ':CALCulate:MARKer:X:CENTer?')); %query center of Peak