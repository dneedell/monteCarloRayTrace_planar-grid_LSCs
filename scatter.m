%
%   FILE NAME:
%       scatter.m
%-------------------------------------------------------------------------
function [vel, polarangle] = scatter()
    %   Set the temporary velocity vector as three random numbers:
    tempvel = randn(1,3);
    %   Output the final velocity vector normalized such that the magnitude
    %   of the velocity vector is 1:
    vel = tempvel./sqrt(sum(tempvel.^2,2));
    %   Set a random polarization between 0 and pi/2:
    polarangle = rand*pi/2;
end