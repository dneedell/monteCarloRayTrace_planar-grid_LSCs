%
%   FILE NAME:
%       anisotropicScatter.m
%
%   FILE DESCRIPTION:
%       This function generates a velocity and polarization angle for a
%       certain type of anisotropic luminohpore emission profile. This
%       function requires no inputs.
%-------------------------------------------------------------------------

function [vel, polarangle] = anisotropicScatter_Fesc(Fesc) %Fesc is the fraction of light emitted into the escape cone

    %   Set the azimuthal angle (angle of the xy plane to proj. vector)
    %   randomly between 0 and 2pi:
    azimuthalAngle = 2*pi*rand();
    
    %   We have not yet found a polar angle of emission:
    angleFound = false;
    
    %   Set a temporary random final angle to prevent errors:
    finalAngle = pi * rand();
    
    %   While we haven't yet found our polar angle of emission:
    while angleFound == false
    
        %   Pick a random start angle from 0 to pi:
        newAngle = pi*rand();
        
        %   If a random number between 0 and 1 is smaller than the
        %   probability of emission at that random start angle and the new
        %   angle won't result in NAN errors:
        if rand < anisotropicFunc_Fesc(Fesc,newAngle) &&                ...
           newAngle ~= 0
            
            %   Then the set the polar angle as such:
            finalAngle = newAngle;
            
            %   And we have found our angle
            angleFound = true;
            
        end
    
    end
    
    %  Now set the x, y, and z velocities from the spherical coordinates:
    tempvelX = cos(azimuthalAngle)*sin(finalAngle);
    tempvelY = sin(azimuthalAngle)*sin(finalAngle);
    tempvelZ = cos(finalAngle);
    
    %   Now combine the X, Y, and Z velocities into one:
    tempvel = [tempvelX, tempvelY, tempvelZ];

    %   Output the final velocity vector normalized such that the magnitude
    %   of the velocity vector is 1:
    vel = tempvel./sqrt(sum(tempvel.^2,2));

    %   Calculate the polar angle:
    polarangle = pi/2;
    
end