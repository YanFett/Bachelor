%close all
%clear all
coupling = false;
saving = true;
linmag = true;
if(~coupling)
    filename = 'visual_plot';
else
    filename = 'visual_plot_dd';
end
% %Threshold Laser plot over number of turns
% 
% %NumTurnsScrew1 = [4.6;5.5;6;6.5;7;8;10;12;14;16;18;20;22]; %iris screw turns
% NumTurnsScrew1 = [4.5;5;5.5;6;6.5;7;8;9;10;11;12]; %iris screw turns %4
% Coupling1 = 10^-3*[0.00279921000000000,0.00377244500000000,0.00495245400000000,0.00538317700000000,0.00619945900000000,0.00683184300000000,0.00773462400000000,0.00815895700000000,0.00850627700000000,0.00860810600000000,0.00864381700000000]';
% %LP_1line = [745;303;253;208;225;187;170;140;179;171;171;179;178];%threshold laserpower for 1 Maser line
% LP_1line = [401;345;303;253;195;164;153;139;138;138;140];%threshold laserpower for 1 Maser line %704
% 
% %NumTurnsScrew2 = [5.5;6;6.5;8;10;14;16;18;20;22]; 
% NumTurnsScrew2 = [4.5;5.5;6;6.5;7;9;11]; 
% Coupling2 = 10^-3*[0.00279921000000000,0.00495245400000000,0.00538317700000000,0.00619945900000000,0.00683184300000000,0.00815895700000000,0.00860810600000000]';
% %LP_2line = [328;272;200;203;194.5;187;179;178.5;187;187]; %threshold laserpower for 2 Maser line
% LP_2line = [408;328;272;200;187;145;148]; %threshold laserpower for 2 Maser line
% %LP_2line 12 löschen
% 
% %NumTurnsScrew3 = [5;5.5;6;6.5;7;8;10;12;14;16;18;20;22]; 
% NumTurnsScrew3 = [4.5;5;5.5;6;6.5;7;8;9;10;11;12]; 
% 
% %LP_3line = [650;344;291;195;300;217;194.5;163;203;187;201;209.5;209]; %threshold laserpower for 3 Maser line
% LP_3line = [448;381;344;280;208;193;172;152;160;154;163]; %threshold laserpower for 3 Maser line
% Coupling3 = 10^-3*[0.00279921000000000,0.00377244500000000,0.00495245400000000,0.00538317700000000,0.00619945900000000,0.00683184300000000,0.00773462400000000,0.00815895700000000,0.00850627700000000,0.00860810600000000,0.00864381700000000]';

%NumTurnsScrew1 = [4.6;5.5;6;6.5;7;8;10;12;14;16;18;20;22]; %iris screw turns
NumTurnsScrew1 = [4.5;5;5.5;6;6.5;7;8;9;10;11;12]*0.75; %iris screw turns %4
Coupling1 = [0.98916;0.98674;0.98349;0.98162;0.97879;0.97717;0.97492;0.97389;0.97366;0.97393;0.97341];
LP_1line = [401;345;303;253;195;164;153;139;138;138;140];%threshold laserpower for 1 Maser line %704
%Coupling1 = 10^-3*[1.304,1.809,3.102,3.174,3.854,4.069,6.112,7.301,8.396,8.923,7.011]';
%LP_1line = [745;303;253;208;225;187;170;140;179;171;171;179;178];%threshold laserpower for 1 Maser line
%NumTurnsScrew2 = [5.5;6;6.5;8;10;14;16;18;20;22]; 


%Coupling2 = 10^-3*[1.712,2.839,3.424,4.220,4.397,7.518,8.200]';
%LP_2line = [328;272;200;203;194.5;187;179;178.5;187;187]; %threshold laserpower for 2 Maser line
NumTurnsScrew2 = [4.5;5.5;6;6.5;7;9;11]*0.75; 
Coupling2 = [0.98913;0.98320;0.98189;0.97865;0.97725;0.97397;0.97383];
LP_2line = [408;328;272;208;187;148;148]; %threshold laserpower for 2 Maser line
%LP_2line 12 löschen

%NumTurnsScrew3 = [5;5.5;6;6.5;7;8;10;12;14;16;18;20;22]; 
NumTurnsScrew3 = [4.5;5;5.5;6;6.5;7;8;9;10;11;12]*0.75; 
LP_3line = [448;381;344;280;208;193;172;152;160;153;163]; %threshold laserpower for 3 Maser line
Coupling3 = [0.98925;0.98674;0.98322;0.98201;0.97870;0.97739;0.97506;0.97417;0.97383;0.97395;0.97336];
%LP_3line = [650;344;291;195;300;217;194.5;163;203;187;201;209.5;209]; %threshold laserpower for 3 Maser line
%Coupling3 = 10^-3*[1.236,1.765,2.588,3.533,4.184,4.287,6.270,8.338,9.129,9.285,7.121]';


%%fit
y1 = LP_1line;
y2 = LP_2line;
y3 = LP_3line;
if(~coupling)
x1 = NumTurnsScrew1;
x2 = NumTurnsScrew2;
x3 = NumTurnsScrew3;
xx1 = linspace(3.375,9,50); 
xx3 = linspace(3.375,9,50);
xx2 = linspace(3.375,9,50);
g1 = fittype('a-b*exp(-c*x)');
f01 = fit(x1,y1,g1,'StartPoint',[[ones(size(x1)), -exp(-x1)]\y1; 1]);
f03 = fit(x3,y3,g1,'StartPoint',[[ones(size(x3)), -exp(-x3)]\y3; 1]);%,'lower',lower,'upper',upper);
lower = [f01.a;f03.b;f01.c];
upper = [f03.a;f01.b;f03.c];
f02 = fit(x2,y2,g1,'StartPoint',[[ones(size(x2)), -exp(-x2)]\y2; 1]);%,'lower',lower,'upper',upper);
else
    x1 = Coupling1;
    x2 = Coupling2;
    x3 = Coupling3;
    if(~linmag)
        xx1 = linspace(-36,-50,50); 
        xx3 = linspace(-36,-50,50);
        xx2 = linspace(-36,-50,50);
        g1 = fittype('a*x+b');

        f01 = fit(x1(1:end-end1),y1(1:end-end1),g1,'StartPoint',[-30;-1000]);
        f02 = fit(x2(1:end-end2),y2(1:end-end2),g1,'StartPoint',[-30;-1000]);
        f03 = fit(x3(1:end-end3),y3(1:end-end3),g1,'StartPoint',[-30;-1000]);
    else
        end1 = 0;%5;
        end2 = 0;%3;
        end3 = 0;% 5;
        xx1 = linspace(min(x3),max(x3),50); 
        xx3 = linspace(min(x3),max(x3),50);
        xx2 = linspace(min(x3),max(x3),50);
        g1 = fittype('poly1');
        f01 = fit(x1(1:end-end1),y1(1:end-end1),g1);%,'StartPoint',[[ones(size(x1)), exp(-x1)]\y1; 1]);
        f03 = fit(x3(1:end-end3),y3(1:end-end3),g1);%,'StartPoint',[[ones(size(x3)), exp(-x3)]\y3; 1]);%,'lower',lower,'upper',upper);
        %lower = [f01.p1;-inf];
        %upper = [f03.p1;f03.p2];
        f02 = fit(x2(1:end-end2),y2(1:end-end2),g1);%,'lower',lower,'upper',upper);%,'StartPoint',[[ones(size(x2)), exp(-x2)]\y2; 1],'lower',lower,'upper',upper);
    end
   

end



figure1 = figure(1);
clf
sz = 30;

if(~coupling)
    newcolors = [0 0 0
                 0 0.5 0];
    colororder(newcolors)
    scatter(NumTurnsScrew1,LP_1line,sz,'ro','filled')
    hold on
    scatter(NumTurnsScrew2,LP_2line,sz,'bd','filled')
    hold on 
    scatter(NumTurnsScrew3,LP_3line,sz,'k<','filled')
    hold on
    xlabel('depth of screw (mm)', 'FontSize', 14)
    xlim([3.375 9])
    ylim([100 450])
    yyaxis right
    plot(NumTurnsScrew1,Coupling1,'--')
    %plot(NumTurnsScrew2,Coupling2,'--b')
    %plot(NumTurnsScrew3,Coupling3,'--k')
    ylabel('\kappa*', 'FontSize', 14)
    yyaxis left
else
    scatter(x1,LP_1line,sz,'ro','filled')
    hold on
    scatter(x2,LP_2line,sz,'bd','filled')
    hold on 
    scatter(x3,LP_3line,sz,'k<','filled')
    hold on
    if(~linmag)
        xlabel('Dip Depth (dBm)', 'FontSize', 14)    
    else
        xlabel('\kappa*', 'FontSize', 14)    
    end
    xlim([min(x3) max(x3)])
end
lw = .25;
if(coupling)
plot(xx1,f01(xx1),'r--','LineWidth',lw);
plot(xx2,f02(xx2),'b--','LineWidth',lw);
plot(xx3,f03(xx3),'k--','LineWidth',lw);
end
ylabel('Threshold pump laser power (mW)', 'FontSize', 14)
set(gca, 'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on', 'Layer', 'top')
grid off
%fit_func_str = 'a -b \cdote ^{-c \cdott} ';
%xpos = 0.8;
%text(xpos,0.75,fit_func_str,'Units','normalized')
%ylim([0 500])
%axis tight
if(coupling)
    legend('1 Maser Line','2 Maser Lines','3 Maser Lines','Location','northwest')
else
    legend('1 Maser Line','2 Maser Lines','3 Maser Lines','\kappa* center-field peak','Location','northeast')
end
if(saving)
export_eps(figure1,['Treshold\\graphs\\',filename])
end