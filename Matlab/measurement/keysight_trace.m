% Getting and plotting trace data
% Single trace acquisition
% Initial setup
%mxa_ip = '192.168.1.127';
%mxa_port = 5025;
%mxa=tcpip(mxa_ip,               5025);
function trace =keysight_trace(mxa)
% input buffer size to receive trace data
% should be at least 4 times the number of trace
% points for 32-bit real format
%set(mxa,'InputBufferSize',100000);
% Set the data trace format to REAL, 32 bits
fprintf(mxa,':FORM:DATA               REAL,32');
% Get the nr of trace points
%nr_points = str2double(query(mxa,':SWE:POIN?'));
% Get the reference level
%ref_lev = str2num(query(mxa,'DISP:WIND:TRAC:Y:RLEV?'));
% Get the trace data
fprintf(mxa,':TRAC?               TRACE1');
trace = binblockread(mxa,'float32');

fscanf(mxa); %removes the terminator character
% % create and bring to front figure number 1
% figure(1)
% % Plot trace data vs sweep point index
% plot(1:nr_points,data)
% % Adjust the x limits to the nr of points
% % and the y limits for 100 dB of dynamic range
% xlim([1               nr_points])
% ylim([ref_lev-100               ref_lev])
% % activate the grid lines
% grid               on
% title('Swept SA trace')
% xlabel('Point               index')
% ylabel('Amplitude               (dBm)')
% % Disconnect an clean up
% fclose(mxa);
% delete(mxa);
% clear               mxa
end