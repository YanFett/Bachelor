%% sources
%1: https://www.cv.nrao.edu/~sransom/web/Ch2.html
%2: Lotka-Volterra equations describing the dynamical behaviour of maser pulse. J. Breeze, C. Kay
%3: Algorithms for Computing In-band Radiance: https://www.spectralcalc.com/blackbody/appendixA.html
%and https://www.spectralcalc.com/blackbody/inband_radiance.html equation
%24
clear all
close all
%% constants
const.h = 6.6261e-34; % (J s) Planck's constant
const.c = 299792485;  % (m/s) speed of light in a vacuum
const.k = 1.3807e-23; % (J/K) Boltzmann constant
const.sigma = 5.67e-5;

%% script

    %% manual Variables
    time_resolution = 5e-10; %the timestep taken in each step of calculation
    time_length = 10; % in microseconds
    v_min = 9.21165*10^9; %min/max frequency that is able to cause Masing
    v_max = 9.21168*10^9; 
    T = 298;
    Nactive = 4e13; % Number of Active NV-centers
    polarized = 0.5; %ratio of polarized NV-centers (random number)
    w= 9*10^9; %angular frequency (random number)
    Q=30000; %loaded quality factor
    B = 5E-7; %Einstein Factor (random number)
    %% calculated Variables
    maxlength = time_length/(10^6*time_resolution); %length of the simulation in steps 10^6 for microseconds
    dw = w/Q;
    N0 = polarized * Nactive;
    Bright = spectral_brightness(const, T, v_min, v_max); % this can be used as an approximation for q, if corrected for the resonator
    % see 2: text below eqn 11
    q0 = Bright * 0.000001; % random factor that seems more ore less realistic
    %% differential equations
    %initialize matrix
    Ndata = zeros(1,maxlength);
    qdata = zeros(1,maxlength);
    Ndata(1) = N0;
    newN = N0;
    qdata(1) = q0;
    i=2;
    while(i<=maxlength+1)
        lastN = Ndata(i-1);
        lastq = qdata(i-1);
        newN = lastN-2*B*lastN*lastq*time_resolution;
        newq = lastq+(B*lastN - dw)*lastq*time_resolution;
        Ndata(i) = max(newN,0);
        qdata(i) = max(newq,0);
        i = i + 1;
    end
    %% data processing
    time = (1:length(Ndata)).*time_resolution*10^6; %10^6 for micro second
    [qstar,qstar_index] = max(qdata);
    Nstar = Ndata(qstar_index);
    left_half = qdata(1:qstar_index);
    right_half = qdata(qstar_index:end);
    [ ~, t1_index ] = min( abs( left_half-qstar/2 ) );
    t1_q = qdata(t1_index);
    [ ~, t2_index ] = min( abs( right_half-qstar/2 ) );
    t2_index = t2_index+length(left_half)-1;
    t2_q = qdata(t2_index);
    t1 = time(t1_index);
    t2 = time(t2_index);
    FWHMstar = t2 - t1;
    %% plotting
    

    plot(time,Ndata,time,qdata);
    hold on
    xlim([0 time(end)])
    %semilogy(t,Ndata,t,qdata);
    %loglog(t,Ndata,t,qdata);
    xlabel('time[\musec]')
    ylabel('Microwave photon population')
    marker1 = plot(time(t1_index),qdata(t1_index),'.');
    marker2 = plot(time(t2_index),qdata(t2_index),'.');
    marker3 = plot(time(qstar_index),qdata(qstar_index),'.');
    set(marker1(1),'Color','black');
    set(marker2(1),'Color','black');
    set(marker3(1),'Color','black');
%% functions

function photons =  planck_photon_integral(const, v_min, T)
    %this function calculates the spectral photon density from v_min to
    %infinity. it was taken from source 3. to understand it i recommend
    %comparing my code and comments with their formula.
    %my code is an adapted copy of theirs.
    %this calculation uses Wavenumbers, first step is to transform.
    wn = v_min/const.c;

    %compute powers of x, the dimensionless spectral coordinate
    c1 = const.h*const.c/const.k;
    x = c1*100*wn/T; %does the substitution in eqn 21
    x2 = x^2;

    %decide how many terms of sum are needed
    iterations = ceil(2 + 20/x);
    if(iterations > 512) % sets limit for number of sums, they say it converges to at least 10 digits
        iterations = 512;
    end

    %add up terms of sum
    sum = 0;
    n = 1;
    while (n<iterations)
        dn = 1/n;
        sum = sum + exp(-n*x) * (x2+ 2*(x+dn)*dn)*dn;
        n = n + 1;
    end
    %return result in units of photons/s/m^2/sr
    photons = 2*((const.k*T)/(const.h*const.c))^3*const.c * sum;
    %returns in photons/s/m^2/sr
end

function BT = spectral_brightness (const, T, v_min, v_max)
    BT = planck_photon_integral(const,v_min,T)-planck_photon_integral(const,v_max,T);
end

%% stuff that does not work but might be interesting to keep
%this also does not work
%syms N(t) q(t)
%eqns = [diff(N,t) == -2*B*N(t)*q(t), diff(q,t) == (B*N(t)-dw)*q(t) ];
%Solutions = dsolve(eqns);
    
% shamelessly stolen from https://de.mathworks.com/matlabcentral/answers/116782-how-to-plot-phase-plane-in-matlab#answer_125728
% and sadly does not return
%     opts = odeset('RelTol', 1e-3);
%     [~,X] = ode45(@EOM,[0 1],[N0 q0],opts);
%     u = X(:,1);
%     w = X(:,2);
%     plot(u,w)
%     xlabel('u')
%     ylabel('w')
%     grid
function dX = EOM(t, y)
dX = zeros(2,1);
N  = y(1);
q  = y(2);
B  = 5;
dw = 9*10^9/30000;
dX = [-2*B*N*q;...
      (B*N - dw)*q];
end
%this function does not work as intended but is kept until the other one is
%proven to work
function BT = spec_brightness (const, T,v_min,v_max)
    %spectral brightness, see 1: 2.86, 2.89
    spec_brightness_freq = @(v) (2*const.h*v^3)/((exp(const.h*v/(const.k*T))-1)*const.c^2);    
    BT = integral(spec_brightness_freq, v_min, v_max, 'ArrayValued', true);
end


