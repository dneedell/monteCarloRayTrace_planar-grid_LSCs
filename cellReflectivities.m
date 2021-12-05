%
%   FILE NAME:
%       cellReflectivities.m
%
%   FILE DESCRIPTION:
%       This file defines the reflectivity values for both the InGaP Cell
%       and also the Si Cell.  These are based on the absorption values
%       imported via the dataLoading.m function.  Note that the actual data
%       of absorption values imported by that dataLoading.m function are
%       given from absorption measurements of both Si and InGaP solar cells
%       by the National Renewable Energy Laboratory (NREL).
%
%   FILE PARAMETER NOTES:
%       This function has four input parameters as follows:
%       
%       1. absInGaP: the absorption spectrum of an InGaP Solar Cell
%       2. absSi: the absorption spectrum of a Si Solar Cell
%       3. lambda: the wavelength range used for data analysis
%       4. absDataRange: the wavelength range's size used in the absorption
%          data
%       
%-------------------------------------------------------------------------

function [reflectInGaP, reflectSi] = cellReflectivities(absInGaP, absSi,...
                                                        lambda, ...
                                                        absDataRange)
                                                    
    %
    %   First set the reflectivity spectrum with respect to incident angle
    %   of the light and the wavelength for the InGaP Solar Cell: 
    %
    
        reflectInGaP = 1 - absInGaP;
        
    %
    %   Next set the reflectivity spectrum with respect to incident angle
    %   of the light and the wavelength for the Si Solar Cell: 
    %
    
        %   Set the Si cell absorption values to decimal, NOT percentage:
        absSi = absSi./100;
        
        %   Set the absorption of the Si cell to 0 for parallel light
        %   rays:
        absSi(:,end) = 0;
        
        %   Adjust and define the spectrum of wavelength and the incident
        %   angle data to match that of our data analysis via
        %   interpolation where, Reflection = 1 - Absorption:
        reflectSi = interp2([0:5:85]',lambda,1-absSi,...
                               [0:90]',absDataRange);
                           
        
        %   For all angles of the incident light:
        for i=1:size(reflectSi,1)
            
            %    For all wavelengths of the incident light:
            for j=1:size(reflectSi,2)
                   
                %   If the reflection value is negative or a non-number:  
                if isnan(reflectSi(i,j)) || reflectSi(i,j) < 0
                    
                    %   Set the value to zero:    
                    reflectSi(i,j) = 0; 
                    
                end
                  
            end
               
        end
        
    %
    %   Finally, near 90 degrees the reflectivity values are incorrect
    %   since FDTD cannot calculate them directly.  Thus, set them to
    %   approximate values by matching them with high angles (i.e. 86
    %   degrees):
    %
    
        %   For angles higher than 86 degrees:
        for i = 87:91
            
            %   Set the reflectivity of the Si Cell to match the value
            %   at 86 degrees:
            reflectSi(:,i) = reflectSi(:,86);
            
        end
        
end
        
        
        
        