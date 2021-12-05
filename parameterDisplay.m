%
%   FILE NAME:
%       parameterDisplay.m
%
%   FILE PURPOSE:
%       To output the number of iterations complete for this given
%       simulation run, as well as to save a prefix header for the data
%       file.
%-------------------------------------------------------------------------

function [prefix]                                                       ...
                                                                        ...
= parameterDisplay(lumPLFileIndex, topFilterBool, botFilterBool,        ...
    testDate, iteration, numIterations)
    %   Insert a horizontal space for organization:
    fprintf('\n');
    %   Display the simulation run totals:
    disp(['Simulation ',num2str(iteration),' of ',                      ...
    num2str(numIterations),':']);
    %   If using a topside and bottomside reflector:
    if topFilterBool && botFilterBool
        prefix = strcat(testDate,'_DBRTop_DBRBottom_',                  ...
        num2str(lumPLFileIndex),'_');
    %   If using a topside reflector only:
    elseif topFilterBool && ~botFilterBool
        prefix = strcat(testDate,'_DBRTop_',num2str(lumPLFileIndex), '_');
    %   If using a bottomside reflector only:                
    elseif ~topFilterBool && botFilterBool
        prefix = strcat(testDate,'_DBRBottom_',num2str(lumPLFileIndex), ...
        '_');
    %   If no filter at all:
    else 
       prefix = strcat(testDate,'_NoDBR_',num2str(lumPLFileIndex), '_');
    end
end
        