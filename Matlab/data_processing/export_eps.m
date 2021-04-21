function export_eps(figure1,filename)
%figure1
%if this does not work increase java heap memory in preferences > MATLAB > General > Java Heap Memory
directory = 'E:\\Bachelor_data\\2020-12-10_GoldRes_10mm-Res_NV\\Abbildungen\\';
set(figure1,'color','w');
%[directory,filename]
export_fig(figure1,[directory,filename],'-eps')
end