clear all
reload = true;
T_meas = true;
directory = 'E:\Bachelor_data\TR_EPR\T\';
filenames = {'T1_1_NV','T1_2_NV','T1_3_NV','T2_1_NV','T2_2_NV','T2_3_NV'};
%filenames = {'T2_1_NV'};
wait_for_user = false;
saving = true;
for(i=1:length(filenames))
    if(reload || ~exist('x_axis','var') || ~exist('y_axis','var'))
        path = [directory,filenames{i}];
        contains_imag = T_meas;
        [x_axis,y_axis] = load_elexys(path,contains_imag);
        x_axis=x_axis(2:end);
        y_axis=y_axis(2:end,1);
    end

    %% fit
    if(wait_for_user)
        w = 0;
        while w == 0
            w = waitforbuttonpress;
        end
    end

    T_nump = filenames{i}(1:2);
    if(T_nump == 'T1')
        T1 = true;
    else
        T1 = false;
    end
    if(T_nump == 'T2')
       T_num = 'T^*_{2}';
    else
       T_num = 'T_1';
    end
    Peak_num = str2num(filenames{i}(4));
    if(Peak_num == 1)
        titlestr = [T_num,' low-field'];
    end
    if(Peak_num == 2)
        titlestr = [T_num,' center-field'];
    end
    if(Peak_num == 3)
        titlestr = [T_num,' high-field'];
        if(T_nump == 'T2')
            x_axis = x_axis(1:3332);
            y_axis = y_axis(1:3332);
        else
            x_axis = x_axis(1:3199);
            y_axis = y_axis(1:3199);
        end
    end

    [titlestr,' min:',num2str(min(x_axis)),' max:',num2str(max(x_axis)),' len:',num2str(length(x_axis))]
    %% works for T1
    %T1 = true;
    if(T1)
        fit_startvals1 = [870;1047;5e-07];
        lower = [1e+1;0;1e-10];
        upper = [1e+5;10000;1e-4];
        type = fittype('a-b*exp(-c*x)');
        %fit_startvals1 = [rawdata.debug.convergence_frequencies(end);rawdata.debug.convergence_frequencies(9);0.4];
        [myfit,gof] = fit(x_axis, y_axis, type,'Startpoint',fit_startvals1,'Algorithm','Levenberg-Marquardt');%,'lower',lower,'upper',upper);
        %[myfit1,gof1] = fit(rawdata.debug.convergence_timeaxis', datasmooth(rawdata.debug.convergence_frequencies',2), type,'Startpoint',fit_startvals1,'Weights',weights,'lower',lower,'upper',upper);
    else
        fit_startvals1 = [-2701;-84250;8.168e-5];
        lower = [-1e+5;-1e6;-inf];
        upper = [1e+5;-1e1;inf];
        type = fittype('a-b*exp(-c*x)');
        %fit_startvals1 = [rawdata.debug.convergence_frequencies(end);rawdata.debug.convergence_frequencies(9);0.4];
        [myfit,gof] = fit(x_axis, y_axis, type,'Startpoint',fit_startvals1,'Algorithm','Levenberg-Marquardt');%,'lower',lower,'upper',upper);
        %[myfit1,gof1] = fit(rawdata.debug.convergence_timeaxis', datasmooth(rawdata.debug.convergence_frequencies',2), type,'Startpoint',fit_startvals1,'Weights',weights,'lower',lower,'upper',upper);

    end
    T(i) = 1/myfit.c; %% ns
    %%



    if(T_meas)
        %num = sortrows(num,2);
        figure1 = figure(123);
        hold on
        set(figure1 ...
        , 'Units', 'pixels' ...
        , 'Position', [-560 520 560 440])
        clf(figure1)

        y_axis = datasmooth(y_axis(:,1),1); % real
        %y_axis = datasmooth(y_axis,1); % both
        %y_axis = datasmooth(y_axis(:,2),1); % imag
        sz = 1;
        if(T1)
            x_axis_plot = x_axis /10^6;
        else
            x_axis_plot = x_axis /10^3;
        end
        scatter(x_axis_plot,(y_axis),sz,'filled');
        hold on
        plot(x_axis_plot,(myfit(x_axis)));
        title(titlestr, 'FontSize', 14);
        axis tight
        if(T1)
            xlabel('Time (ms)', 'FontSize', 14);
        else
            xlabel('Time (\mus)', 'FontSize', 14);
        end
        ylabel('Intensity (A.U.)', 'FontSize', 14);
        set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
        precision = '%.2E';
        %fit_func_str=[num2str(myfit.a,precision),num2str(-myfit.b,precision),' \times e^{',num2str(myfit.c,precision),'\times t}']
        fit_func_str = 'a -b \cdote ^{-c \cdott} ';
        xpos = 0.06;
        text(xpos,0.95,fit_func_str,'Units','normalized')
        text(xpos,0.90,['a = ',num2str(myfit.a,precision)],'Units','normalized')
        text(xpos,0.85,['b = ',num2str(myfit.b,precision)],'Units','normalized')
        text(xpos,0.80,['c = ',num2str(myfit.c,precision)],'Units','normalized')
        
        if(T1)
            lgd = legend('experimental relaxation','exponential fit','Location','southeast');
            T1_(i) = 1/myfit.c;
        else
            lgd = legend('experimental relaxation','exponential fit','Location','northeast');
            T2(i) = 2/myfit.c;
        end
        %title(strjoin(['Turns: ',dat.T,' Power: ',dat.mW,' ',dat.date,' ',dat.id]))
    else
        figure1 = figure(123);
        hold on
        set(figure1 ...
        , 'Units', 'pixels' ...
        , 'Position', [-560 520 560 440])
        clf(figure1)

        y_axis = datasmooth(y_axis,1);
        plot(x_axis,y_axis);
        xlabel('Time (ns)', 'FontSize', 14);
        ylabel('Intensity (A.U.)', 'FontSize', 14);
        set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
        %title(strjoin(['Turns: ',dat.T,' Power: ',dat.mW,' ',dat.date,' ',dat.id]))
    end
    if(saving)
        export_eps(figure1,['TREPR\\',filenames{i}]);
    end
end
