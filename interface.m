%
%   FILE NAME:
%       interface.m
%
%   FILE DESCRIPTION:
%       This function is used in the monteCarlo.m function call.  The
%       purpose of this function is to compute the transmission and
%       reflection probabilities of a photon traveling from one medium to
%       another (i.e passing through an interface).  
%
%   FILE PARAMETER NOTES:
%       This function has three inputs which are:
%
%           1. n1: the index of refraction of the first material
%           2. n2: the index of refraction of the second material
%           3. theta1: the angle of incidence in material 1 (vertical
%              angle)
%
%-------------------------------------------------------------------------

function[output] = interface(n1, n2, theta1)

    %   If the first index of refraction is smaller than the second:
    if (sin(theta1)*n1/n2 <= 1) && (sin(theta1)*n1/n2 >= -1)
        
        %   Define the resulting angle by Snell's Law:
        theta2 = asin(sin(abs(theta1))*n1/n2);
        
        %   Define the s polarization via Fresnel's Law:
        rs = (n1*cos(theta1) - n2*cos(theta2))/(n1*cos(theta1) ...
            + n2*cos(theta2));
        
        %   Define the p polarization via Fresnel's Law:
        rp = (n1*cos(theta2) - n2*cos(theta1))/(n1*cos(theta2) ...
            + n2*cos(theta1));
        
        %   The final p polarization value:
        Rp = (rp)^2;
        
        %   The final s polarization value:
        Rs = (rs)^2;
    
    %   Else the first index of refraction is larger than the second:
    else
        
        %   For simplicity, set the p polarization to 1:
        Rp = 1;
        
        %   For simplicity, set the s polarization to 1:
        Rs = 1;
        
        %   Since the light is going from a higher to lower index of
        %   refraction, no angle change occurs:
        theta2 = abs(theta1);
        
    end
    
    %   Calculate the updated z-velocity based upon the new theta value:
    zvel = abs(cos(theta2));
    
    %   Save the output of this function: p polarization, s polarization,
    %   the new theta value, and the current z-velocity:
    output = [Rp,Rs,theta2,zvel];
    
end