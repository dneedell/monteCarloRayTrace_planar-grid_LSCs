%
%   FILE NAME:
%       incidentPowerIntegrator.m
%-------------------------------------------------------------------------
function [incidentPower]                                                ...
                                                                        ...
= incidentPowerIntegrator(wavelengthIndex, wavelengthStep,              ...
    simWavelengthRange, cosineFactor, gridSize,                         ...
    incidentLightSpectrumWavelength, incidentLightSpectrumWatts)
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
    irradianceSum = sum(incidentLightSpectrumWatts(irradianceIndexLow:  ...
    irradianceIndexHigh));
    %   Incoming power is cosine factor times power over the wavelength 
    %   step size by the area:
    incidentPower = cosineFactor * irradianceSum * gridSize^2;









