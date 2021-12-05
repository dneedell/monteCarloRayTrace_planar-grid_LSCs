%
%   FILE NAME:
%       initializeLuminophore.m
%
%   FILE PURPOSE:
%       To ensure that the PL loaded spectrum is normalized and contains
%       only real and non-zero and non-negative values.
%-------------------------------------------------------------------------
function [lumPLSpectrum] = initializeLuminophore(lumPLSpectrum)
    %   First, normalize the photoluminescence values:
    lumPLSpectrum = lumPLSpectrum ./ max(lumPLSpectrum);
    %   Next, ensure that all photoluminescence values are real valued:
    for i=1:length(lumPLSpectrum)
        %   If any are negative or non-numbers:
        if lumPLSpectrum(i) <= 0 || isnan(lumPLSpectrum(i))
            %   Set them to zero:
            lumPLSpectrum(i) = 0; 
        end
    end
end
        
        
        
        
        
        
        
        
        
        
    