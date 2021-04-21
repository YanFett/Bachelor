%NV Center High-field Resonance lines ==> High-field Maserlines estimate!

function [varargout] = CalcHighFieldMaserLinePos(MWFreq,varargin)

format long 

%System 

Sys.S = 1; %triplett state
Sys.Nucs = '14N'; %nuclei
Sys.g = 2.00; %approx g-factor NV 
Sys.A = [-2.7 -2.1756]; %in MHz %approx Hyperfine Constants NV A_perpendicular = -2.7; A_parallel = -2.1756/-2.1
Sys.D = [2863.2]; %in MHZ %Zero-field-splitting

%Parameter 

Par.mwFreq = MWFreq;%in GHz % Resonance frequency  
Par.Mode = 'perpendicular'; %Orientation of the mw field; perpendicular == perpendicular to external field
%Par.CrystalOrientation = [0 pi/4 0];
%Par.CrystalSymmetry = 'C3v';
Par.mwPolarization = 'linear';
if nargin == 1
delB = [0 500];
Par.Range = delB;%in mT %magnetic field range 
else
delB = varargin{1};
Par.Range = delB;
end 

% Calculation 

Bres = resfields(Sys,Par); %using matrix diagonalization
Bres = sort(Bres(Bres >= 400));


varargout{1} = Bres; 




end 