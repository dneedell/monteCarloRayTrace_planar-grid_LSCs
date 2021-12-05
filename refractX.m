%
%   FILE NAME:
%       refractX.m
%
%   FILE DESCRIPTION:
%       This function looks at the x velocity change for a photon at a
%       given interface.  Note that this function specifically determines
%       wheter or not the photon is reflected or refracted and then outputs
%       the corresponding velocity.
%
%   FILE PARAMETER NOTES:
%       This function has three input paramters as follows:
%   
%           1. input: this is the input value that comes from the
%              interface.m function consisting of: (i) the reflection
%              probability for a p-polarized photon, (ii) the reflection
%              probability for a s-polarized photon, (iii) the angle of the
%              photon with respect to the z axis, (iv) the z velocity of
%              the photon
%           2. polarangle: the polar angle of the photon
%           3. tempvel: this is the photon's previous trajectory
%
%-------------------------------------------------------------------------

function [newvel] = refractX(input,polarangle,tempvel)

    %   Initialize a newvel that we will change later:
    newvel = tempvel;
    
    %   Define the probability of reflection based upon the probabilities
    %   from the input vector and the polar angle:
    reflectprob = sin(polarangle)^2*input(1)+cos(polarangle)^2*input(2);
    
    %   If the photon reflects:
    if rand() < reflectprob
        
        %   Send the photon in the other x-direction:
        newvel(1) = -tempvel(1);
        
    %   Else the photon refracts:    
    else
        
        %   Define the new velocity as the x-velocity from the input
        %   vector:
        newvel(1) = sign(tempvel(1))*input(4);
        
        %   Define the theta angle as the theta from the input vector:
        theta2 = input(3);
        
        %   If the z velocity of the photon is not zero:
        if tempvel(3) ~= 0
            
            %   Define a phi angle:
            phi = atan(tempvel(2)/tempvel(3));
            
            %   Update the new z-velocity with respect to the new theta
            %   angle:
            newvel(3) = abs(cos(phi)*sin(theta2))*sign(tempvel(3));
            
            %   Update the new y-velocity with respect to the new theta
            %   angle:
            newvel(2) = abs(sin(phi)*sin(theta2))*sign(tempvel(2));
        
        %   Else the z velocity of the photon is zero:
        else
            
            %   Set the new z-velocity to zero:
            newvel(3) = 0;
           
            %   Set the new y-velocity to zero:
            newvel(2) = 0;
           
        end
        
    end
    
end