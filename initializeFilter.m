%
%   FILE NAME:
%       initializeFilter.m
%
%   FILE PURPOSE:
%       To, if applicable, create specific reflectance and transmittance
%       polarizations for the, if applicable, top and/or bottom PL-trapping
%       filters encasing the waveguide.
%-------------------------------------------------------------------------
function [reflectFilterTop_pPol, transmitFilterTop_pPol,                ...
          reflectFilterTop_sPol, transmitFilterTop_sPol,                ...
          reflectFilterBottom_pPol, transmitFilterBottom_pPol,          ...
          reflectFilterBottom_sPol, transmitFilterBottom_sPol]          ...
                                                                        ...
= initializeFilter(reflectFilterTop, transmitFilterTop,                 ...
                reflectFilterBottom, transmitFilterBottom)
    %   For now, we aren't going to include polarization dependence, so
    %   let's just assume average polarization:
    reflectFilterTop_sPol = reflectFilterTop; 
    transmitFilterTop_sPol = transmitFilterTop;
    reflectFilterBottom_sPol = reflectFilterBottom;
    transmitFilterBottom_sPol = transmitFilterBottom;
    reflectFilterTop_pPol = reflectFilterTop_sPol; 
    transmitFilterTop_pPol = transmitFilterTop_sPol;
    reflectFilterBottom_pPol = reflectFilterBottom_sPol;
    transmitFilterBottom_pPol = transmitFilterBottom_sPol;
end
        