%
%   FILE NAME:
%       initializeScattering.m
%
%   FILE PURPOSE:
%       To create two scattering probabilities of light within the
%       luminescent solar concentrator device, one for how light scatters
%       within the polymer matrix filled with quantum dots and the other
%       for how glass scatters light.
%-------------------------------------------------------------------------
function [probMatrixScatter, probGlassScatter]                          ...
                                                                        ...
= initializeScattering(lumScattering, dataWavelengthRange,              ...
                       lumScatterDistance, photonStep)
    %   Make sure all scattering values are real and non-negative:
    for i=1:length(dataWavelengthRange)            
        %   If the scattering value is not a number:
        if isnan(lumScattering(i)) || lumScattering(i) < 0
            %   Change it to zero:
            lumScattering(i)=0;
        end
    end
    %   Store the scattering value at 600 nm:
    lumScattering_600nmIndex = find(min(abs(dataWavelengthRange - 600)) ...
    == abs(dataWavelengthRange - 600),1);
    %   Normalize the scattering spectrum:
    lumScatteringNorm = lumScattering./lumScattering(                   ...
    lumScattering_600nmIndex); 
    %   Set the polymer scattering distance to an arbitrarily high
    %   value (much larger than the luminophore's scattering distance):
    polymerScatterDistance = 1;
    %   The waveguide's scattering distance will be that of the
    %   user defined luminophore scattering distance divided by the
    %   normalized values above:
    matrixScatterDistance = lumScatterDistance ./ lumScatteringNorm;
    %   The waveguide's net scattering distance will therefore be
    %   the inverse of the addition of the inverses of the polymer
    %   scattering distance and the old waveguide's scattering
    %   distance (just QD's considered):
    matrixScatterDistance = 1./...
    (1/polymerScatterDistance+1./matrixScatterDistance);
    %   Set the glass scattering distance to an arbitrarily high value
    %   (much larger than the QD's scattering distance):
    glassscatterdistance = 1; 
    %   Set the waveguide's scattering coefficient as a given step
    %   divided by the waveguide's scattering distance:
    matrixScatter = photonStep./matrixScatterDistance;
    %   Set the glass's scattering coefficient as a given step divided
    %   by the glass's scattering distance:
    glassScatter = photonStep/glassscatterdistance;
    %   Finally, set the waveguide's scattering probability:
    probMatrixScatter = 1-exp(-matrixScatter);
    %   Finally, set the glass's scattering probability:
    probGlassScatter = 1-exp(-glassScatter);
end


        
        
        
        