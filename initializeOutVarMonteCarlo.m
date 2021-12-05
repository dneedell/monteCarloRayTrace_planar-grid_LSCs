%
%   FILE NAME:
%       initializeOutVarMonteCarlo.m
%
%   FILE DESCRIPTION:
%       This file initializes all necessary variables to run the
%       monteCarlo.m method as well as creates instances of the variables
%       to be returned by the function.
%
%   FILE PARAMETER NOTES:
%       This function has four input parameters as follows:
%       
%       1. xInject: the x-locations for injected photons
%       2. yInject: the y-locations for injected photons
%       3. solarCell: the InGaP Solar Cell's device geometry
%       4. photoLumCompact: the photoluminescence data for a QD
%       
%-------------------------------------------------------------------------

function [collectPhotonOrigin_lscCell, collectPhotonOrigin_bottomCell,  ...
        collectPhotonWavelength_lscCell,                                ...
        collectPhotonWavelength_bottomCell,                             ...
        shortCircuitCurrent_lscCell,                                    ...
        shortCircuitCurrent_bottomCell, incidentPower, numFilterBounces,...
        numLSCEdgeBounces, numPLEvents, numWgModeBounces,               ...
        collectPhotonDir_lscCell, collectPhotonDir_bottomCell,          ...
        solarCell,numPhotonsLost]                                       ...
                                                                        ...
= initializeOutVarMonteCarlo(xInject, yInject, solarCell)
    %   Number of x points in the grid for injected photons:
    numXInject = size(xInject,2);        
    %   Number of y points in the grid for injected photons:
    numYInject = size(yInject,2); 
    %   LSC cell's collected photon wavelength:
    collectPhotonWavelength_lscCell = zeros(numXInject, numYInject); 
    %   Bottom cell's collected photon wavelength:
    collectPhotonWavelength_bottomCell = zeros(numXInject, numYInject);
    %   LSC cell's collected photon position:
    collectPhotonOrigin_lscCell = zeros(numXInject,numYInject,3); 
    %   Bottom cell's collected photon position:
    collectPhotonOrigin_bottomCell = zeros(numXInject, numYInject, 3);
    %   LSC cell's collected photon current contribution:
    shortCircuitCurrent_lscCell = zeros(numXInject, numYInject);
    %   Bottom cell's collected photon current contribution::
    shortCircuitCurrent_bottomCell = zeros(numXInject, numYInject);
    %   Total incident power striking the LSC:
    incidentPower = zeros(numXInject, numYInject);
    %   LSC cell's collected photon directions (cell faces):
    collectPhotonDir_lscCell = zeros(6,numXInject,numYInject,3); 
    %   Bottom cell's collected photon directions (cell faces):
    collectPhotonDir_bottomCell = zeros(6, numXInject, numYInject, 3);
    %   The number of photons lost for this particular wavelength at:
    %   1 = top surface loss
    %   2 = luminophore loss
    %   3,4,5,6 = right,left,back,front side losses
    %   7 = escape cone through top
    %   8 = bottom filter absorption
    %   9 = LSC cell parasitic absorption
    %   10 = Bottom cell parasitic absorption
    numPhotonsLost = zeros(1,10);
    %   Number of top/bottom filter bounces:
    numFilterBounces = zeros(numXInject, numYInject); 
    %   Number of waveguide edge bounces:
    numLSCEdgeBounces = zeros(numXInject, numYInject); 
    %   Number of PL events:
    numPLEvents = zeros(numXInject, numYInject); 
    %   Number of waveguide mode bounces:
    numWgModeBounces = zeros(numXInject, numYInject);
end

          
          
          
          
          
          
          