function params = get_params(Field_Center, Field_Sweep, Field_Step, Keysight)
format long

%Number of points the Signal Analyzer produces
Points = 821;
read_temp= @get_temp;
%while n < size_data 
%Res=query(Keysight,'FREQ:BAND?')
params.Freq_Center = str2double(query(Keysight,'FREQuency:CENTer?'));%9.637064970e9;query(Keysight,'FREQ:CENT?')%
params.Freq_Span = str2double(query(Keysight,'FREQuency:SPAN?'));%500e3;%query(Keysight,'FREQ:SPAN?')%
params.Freq_Start = str2double(query(Keysight,'FREQuency:STARt?'));
params.Freq_End = str2double(query(Keysight,'FREQuency:STOP?')); 
params.Res_BW = str2double(query(Keysight,'BANDwidth:RESolution?'));
params.Ref_Lvl = str2double(query(Keysight,'DISPlay:WINDow:TRACe:Y:RLEVel?'));

%params.SampleTemp = read_temp("A"); % if an error appears here see Connect to Lakeshore section for help
%params.FirstStageTemp = read_temp("B"); %
%params.SecondStageTemp = read_temp("C"); %
%params.TrapTemp = read_temp("D") ;%

%params.Swe_Ti = str2double(query(Keysight,':SENSe:SWEep:TIME?'));
%params.SC_P_Di = str2double(query(Keysight,'DISPlay:SPURious:VIEW:WINDow:TRACe:Y:PDI Vision?'));
%params 
%return 

%save stream to SA.
%fprintf(Keysight,':MMEMory:STORe:RESults:SPECtrogram "MASER_stream_09.csv"');
%return

params.Freq_Vector = 1e-9*linspace(params.Freq_Start,params.Freq_End,Points);

params.Field_Center = Field_Center; %Gauss
params.Field_Sweep = Field_Sweep; %Gauss
params.Field_Step = Field_Step;%0.001; %Gauss
params.Field_Start = params.Field_Center - 0.5*params.Field_Sweep;
params.Field_End = params.Field_Center + 0.5*params.Field_Sweep;
params.Field_Vector = params.Field_Start:params.Field_Step:params.Field_End;
params.Points = Points;
end
