function set_Keysight_SA_Param(Keysight, freq_center, freq_span, npts, bandwidth, sweep_time, attenuation)

fprintf(Keysight, [':SENS:FREQ:CENTER ', num2str(freq_center)]);
fprintf(Keysight, [':SENS:FREQ:SPAN ', num2str(freq_span)]);
fprintf(Keysight, [':SENS:SWE:POIN ', num2str(npts)]);
fprintf(Keysight, [':SENS:BAND:RES ', num2str(bandwidth)]);
fprintf(Keysight, [':SENS:SWE:TIME ', num2str(sweep_time)]);
fprintf(Keysight, [':SENS:POW:ATT ', num2str(attenuation)]);

end