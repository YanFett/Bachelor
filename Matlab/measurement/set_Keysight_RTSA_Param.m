function set_Keysight_RTSA_Param(Keysight, freq_center, freq_span, avg_count, res_bandwidth, acq_time, attenuation)

fprintf(Keysight, [':SENS:FREQ:CENTER ', num2str(freq_center)]);
fprintf(Keysight, [':SENS:FREQ:SPAN ', num2str(freq_span)]);
fprintf(Keysight, [':SENS:AVER:COUN ', num2str(avg_count)]);
fprintf(Keysight, [':SENS:BAND:RES:SEL ', num2str(res_bandwidth)]);
fprintf(Keysight, [':SENS:ACQ:TIME ', num2str(acq_time)]);
fprintf(Keysight, [':SENS:POW:ATT ', num2str(attenuation)]);

end