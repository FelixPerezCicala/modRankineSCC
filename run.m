function run()
% Run program

%%%%%%%%%
% Copyright (c) 2017, F�lix P�rez Cicala

% This program was developed as a Master�s degree final project. The
% project's name was:

% Modelizacion de ciclos Rankine mediante el m�todo de Spencer, Cotton y
% Cannon

% Modelling of Rankine cycles using the Spencer, Cotton and Cannon method

% The supervisor of this project was Domingo Santana Santana (Universidad Carlos
% III de Madrid)

% This program has been tested in R2016a. It is not guaranteed it will work
% in any version preceding R2016a, and it will not work in any version
% preceding R2014
%%%%%%%%%

% Add all folders to path, and subfolders
% Current file pathname
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

% Open first GUI
gui_run();
end