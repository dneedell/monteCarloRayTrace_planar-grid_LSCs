%
%   FILE NAME:
%       constants.m
%
%   FILE PURPOSE:
%       To define the optical and geometric contants associated with this
%       luminescent solar concentrator device and the incoming irradiance.
%-------------------------------------------------------------------------
function [wavelengthStep, simWavelengthRange, dataWavelengthRange, step,...
    nAir, nGlass, nPolymer, wavelengthReference_450nmIndex, gridSize,   ...
    spotSize, fractionCellCovered, xInject, yInject, numXPoints,        ...
    numYPoints, numSimWavelength, xSize, ySize]                         ...
                                                                        ...
= constants(...inputCellLength,                                         ...
            wgSizeIndex, fracIllumIndex, waveguideRefIndex)
    %   Wavelength Step:
    wavelengthStep = 10; 
    %   Simulation Starting Wavelength (lower limit is 300+wlstep):
    startWavelength = 300+wavelengthStep;
    %   Simulation Ending Wavelength (upper limit is 1500):
    endWavelength = 320;
    %   The overall simulation range:
    simWavelengthRange = startWavelength:wavelengthStep:endWavelength; 
    %   Lowest and highest wavelengths from data files:
    dataFiles_lowestWavelength = 300;
    dataFiles_highestWavelength = 1500;
    %   Create the data wavelength range:
    dataWavelengthRange = dataFiles_lowestWavelength:                   ...
    dataFiles_highestWavelength;
    %   Check simulation range lies within bounds:
    if startWavelength < dataFiles_lowestWavelength || endWavelength >  ...
    dataFiles_highestWavelength
        error('Please enter a wavelength range within the data range.');
    end
    %   How far to move the photon in a given iteration:
    step = 5e-6; 
    %   Refractive index of air:
    nAir = 1;
    %   Refractive index of glass:
    nGlass = 1.5;
    %   Refractive index of our waveguide:
    nPolymer = waveguideRefIndex;
    %   Wavelength used as a reference point for absorption (OD):
    wavelengthReference_450nm = 450; 
    %   Corresponding index in the simulation wavelength range array:
    wavelengthReference_450nmIndex = find(min(abs(dataWavelengthRange - ...
    wavelengthReference_450nm)) == abs(dataWavelengthRange -            ...
    wavelengthReference_450nm),1);
    %   For xSize and edge-lined (1) geometry:
    xSize = wgSizeIndex/2*200e-6*4;
    %   For xSize and coplanar:
    %xSize = sqrt(wgSizeIndex) * 400e-6;
    %----------------------------------------------------------------------
    %   For the Si HIT cells only:
    %xSize = sqrt(sizeIndex)*inputCellLength;
    %----------------------------------------------------------------------
    %   For ySize and edge-lined (1) geometry:
    ySize = wgSizeIndex/2*200e-6*4;
    %   For ySize and coplanar:
    %ySize = sqrt(wgSizeIndex) * 400e-6;
    %----------------------------------------------------------------------
    %   For the Si HIT cells only:
    %ySize = sqrt(sizeIndex)*inputCellLength;
    %----------------------------------------------------------------------
    %   Overal Grid Size - i.e. distance between sampling points:
    gridSize = 100e-6;
    %   The size of the illuminated area given by the illumIndex:
    spotSize = xSize*fracIllumIndex;
    %   The Fraction of the embedded LSC cell shadowed by contacts:
    fractionCellCovered = 0.05; 
    %   x grid for the LSC top surface:
    xInject = -spotSize:gridSize:spotSize; 
    %   y grid for the LSC top surface:
    yInject = -spotSize:gridSize:spotSize; 
    %   The number of x points in the grid:
    numXPoints = size(xInject,2);
    %   The number of y points in the grid:
    numYPoints = size(yInject,2);
    %   The overall number of wavelengths to test in our simulation:
    numSimWavelength=length(simWavelengthRange);
    %   The overall number of photons to test in our simulation:
    numPhotons = (2*spotSize/gridSize+1)*(2*spotSize/gridSize+1)*       ...
    numSimWavelength;
    %   Print out this value to the command line:
    fprintf('\nThe number of photons used: %d \n', numPhotons);
end
        
        
        
        
        
        
        
        
        
        
        