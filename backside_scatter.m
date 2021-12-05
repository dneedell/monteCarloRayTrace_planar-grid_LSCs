%
%   FILE NAME:
%       backside_scatter.m
%
%   FILE DESCRIPTION:
%       This function gives a random velocity and polar angle of light that
%       is incident upon an arbirtrary scatterer. It is called upon by the
%       monteCarlo.m function when an incident photon hits a waveguide edge
%       where a random scattering process occurs.  
%
%   FILE PARAMETER NOTES:
%       There are no neccessary inputs for this file since it generates
%       random numbers.  However it does output a velocity vector of
%       doubles and a polar angle double.
%
%-------------------------------------------------------------------------

function [vel, polarangle] = backside_scatter()

    %   Assign a random value in radians to the Phi value of the scattered
    %   light:
    phi = rand*2*pi;
    
    %   Assign a random value in radians to the Theta value of the
    %   scattered light:
    theta = acos(rand*2-1)/2;
    
    %   Using these two angles, assign the velocity vector of the scattered
    %   light:
    vel = [sin(phi)*sin(theta), cos(phi)*sin(theta), cos(theta)];
    
    %   Finally, assign a random angle in radians to the polar angle of the
    %   light:
    polarangle = rand*pi/2;
    
end