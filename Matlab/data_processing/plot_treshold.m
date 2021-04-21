function figure1 = plot_treshold(xdata,ydata,legendstr,titlestr,do_gradient,figure1,threshold)
% coupling stuff
    if(~exist('do_gradient','var'))
        do_gradient = false;
    end
    if(~exist('figure1','var'))
        figure1 = figure;
    end
    figure1;
    %figure1;
    hold on
    linewidth = 1.5;
    sz = 4;
    h = plot(xdata,ydata,'-o','LineWidth',linewidth);
    h.MarkerFaceColor = get(h,'Color'); 
    h.MarkerSize = sz; 
    try
    yval = find(xdata==threshold);
    yval
    xdata
    threshold
    h2 = plot(threshold,ydata(yval),'gd');
    h2.MarkerFaceColor = get(h2,'Color'); 
    h2.MarkerSize = sz*2; 
    end
    xlabel('Pump laser power (mW)', 'FontSize', 14);
    if(~do_gradient)
        ylabel('MASER emission intensity (dBm)', 'FontSize', 14);
    else
        ylabel({'Second derivate of MASER';' emission intensity (dBm/mW^2)'}, 'FontSize', 14);
    end
    set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
    if(exist('titlestr','var'))
        if~(titlestr == "")
            title(titlestr)
        end
    end
    if(exist('legendstr','var'))
        if~(legendstr == "")
            legappend(legendstr)
        end
    end
    leg = legend();
    leg.Location = 'northwest';
    axis tight;
    hold on
    
end