%
%   FILE NAME:
%       initializeOutVar.m
%
%   FILE PURPOSE:
%       To initialize all the output variables in order to split the
%       simulation across cores.
%-------------------------------------------------------------------------
function [collectPhotonOrigin_lscCell, collectPhotonWavelength_lscCell, ...
    collectPhotonDir_lscCell, shortCircuitCurrent_lscCell,              ...
    collectPhotonOrigin_bottomCell, collectPhotonWavelength_bottomCell, ...
    collectPhotonDir_bottomCell, shortCircuitCurrent_bottomCell,        ...
    incidentPower, numFilterBounces, numLSCEdgeBounces,                 ...
    numWgModeBounces, numPLEvents, numPhotonsLost]                      ...
                                                                        ...
= initializeOutVar(numSimWavelength, numXPoints, numYPoints, xInject,   ...
    yInject)
    %   The current position of the photons in the simulation per grid
    %   point per wavelength, with an (x,y,z) coordinate:
    collectPhotonOrigin_lscCell = zeros(numSimWavelength,numXPoints,    ...
    numYPoints,3);
    %   The wavelength of the photon per grid point:
    collectPhotonWavelength_lscCell = zeros(numSimWavelength,numXPoints,...
    numYPoints);
    %   The direction that the photon hit the solar cell, per wavelength,
    %   for a given solar cell face,  per grid point, with an (x, y, z)
    %   velocity vector:
    collectPhotonDir_lscCell = zeros(numSimWavelength, 6, numXPoints,   ...
    numYPoints, 3);
    %   The short circuit current array for each wavelength:
    shortCircuitCurrent_lscCell = zeros(numSimWavelength,1);
    %   The current position of the photons in the simulation per grid
    %   point per wavelength, with an (x,y,z) coordinate:
    collectPhotonOrigin_bottomCell = zeros(numSimWavelength,numXPoints, ...
    numYPoints,3);
    %   The wavelength of the photon per grid point:
    collectPhotonWavelength_bottomCell = zeros(numSimWavelength,        ...
    numXPoints, numYPoints);
    %   The direction that the photon hit the solar cell, per wavelength,
    %   for a given solar cell face,  per grid point, with an (x, y, z)
    %   velocity vector:
    collectPhotonDir_bottomCell = zeros(numSimWavelength, 6, numXPoints,...
    numYPoints, 3);
    %   The short circuit current array for each wavelength:
    shortCircuitCurrent_bottomCell = zeros(numSimWavelength,1);
    %   The number of bounces off of the filters (top/bottom):
    numFilterBounces = zeros(numSimWavelength,size(xInject,2),          ...
    size(yInject,2));
    %   The number of bounces off of the LSC edge:
    numLSCEdgeBounces = zeros(numSimWavelength,size(xInject,2),         ...
    size(yInject,2));
    %   The number of bounces in the polymer waveguide:
    numWgModeBounces = zeros(numSimWavelength,size(xInject,2),          ...
    size(yInject,2));
    %   The number of photoluminescence events of the luminophores:
    numPLEvents = zeros(numSimWavelength,size(xInject,2),               ...
    size(yInject,2));
    %   The number of total photons lost:
    numPhotonsLost = zeros(numSimWavelength,10);
    %   Save the total power incident per wavelength:
    incidentPower = zeros(numSimWavelength,1);
end

        
       
                                                        