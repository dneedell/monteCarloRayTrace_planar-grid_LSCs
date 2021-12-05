%
%   FILE NAME:
%       luminophoreConcentration.m
%
%   FILE PURPOSE:
%       To define the probability of light absorption via the embedded
%       luminophores within the LSC waveguide given the input optical
%       density.
%-------------------------------------------------------------------------
function [probNotAbsPolymer] =                                          ...
                                                                        ...
luminophoreConcentration(waveguideThickness, lumAbsSpectrum,            ...
                wavelengthReference_450nmIndex, lumOpticalDensity,      ...
                photonStep)
    %   Define factor taking into account thickness of waveguide and abs.
    %   of QDs (a.u.):
    thickFactor = 1/(waveguideThickness*lumAbsSpectrum(                 ...
    wavelengthReference_450nmIndex)); 
    %   Define optical desntiy (exponent) term for transmission:
    absSpecAdjusted = lumOpticalDensity * lumAbsSpectrum * thickFactor; 
    %   Finally, set the probability that a photon of a specific wavelength
    %   will not be absorbed in 1 step of the simulation by the waveguide:
    probNotAbsPolymer = 10.^(-absSpecAdjusted*photonStep); 
end