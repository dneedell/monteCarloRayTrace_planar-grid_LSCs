%
%   FILE NAME:
%       outputCurrentIntegerator.m
%-------------------------------------------------------------------------
function [Isc]                                                          ...
                                                                        ...
= outputCurrentIntegrator(wavelengthIndex, wavelengthStep,              ...
    simWavelengthRange, cosineFactor, gridSize,                         ...
    incidentLightSpectrumAmps, incidentLightSpectrumWavelength)
    %   Irradiance is [300:1:1500] resolution, so find high/low indices:
    irradianceIndexLow = find(incidentLightSpectrumWavelength ==        ...
    simWavelengthRange(wavelengthIndex)-wavelengthStep);
    %   For C conversion set only one index (safety):
    irradianceIndexLow = irradianceIndexLow(1);
    irradianceIndexHigh = find(incidentLightSpectrumWavelength ==       ...
    simWavelengthRange(wavelengthIndex));
    %   For C conversion set only one index (safety):
    irradianceIndexHigh = irradianceIndexHigh(1);
    %   The irradiance that contributes is approximately sum over region:
    irradianceSum = sum(incidentLightSpectrumAmps(irradianceIndexLow:   ...
    irradianceIndexHigh));
    %   Incoming power is cosine factor times power over the wavelength 
    %   step size by the area:
    Isc = cosineFactor * irradianceSum * gridSize^2;









