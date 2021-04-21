function set_VNA_Param(vna, freq_center, freq_span, npts, bw, avg, S_para)

fprintf(vna, ['SENS:FREQ:CENT ', num2str(freq_center)]);
fprintf(vna, ['SENS:FREQ:SPAN ', num2str(freq_span)]);
fprintf(vna, ['SENS:SWE:POIN ', num2str(npts)]);
fprintf(vna, ['SENS:BAND ', num2str(bw)]);
fprintf(vna, ['SENS:AVER ', num2str(avg)]);
fprintf(vna, ['CALC:PAR:DEF ', S_para]);

fprintf(vna, 'FORM:DATA ASCII');

end