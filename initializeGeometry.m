%
%   FILE NAME:
%       initializeGeometry.m
%
%   FILE PURPOSE:
%       To create the [x,y,z] geometry of the luminescent solar
%       concentrator device.
%-------------------------------------------------------------------------
function [geometry, wgSize, solarCell, geometricGain, illuminationArea] ...
                                                                        ...
= initializeGeometry(spotSize, xSize, ySize, cellThickness,             ...
                     ...inputCellThick, inputCellLength,                ...
                     gridSize, bifacialInGaP, waveguideThickness,       ...
                     edgeLined, lscCellNum)
    %
    %    We will first define the geometry of our overall LSC device.  Note
    %    that this device consists of four layers (four z-values) as
    %    follows:
    %
    %        1. 0 -> airGap: the bottom air gap between the bottom DBR
    %           and the glass layer
    %
    %        2. airGap -> airGap + glassThickness: the glass layer between
    %           the air gap and the polymer waveguide
    %
    %        3. airGap + glassThickness -> airGap + glassThickness +
    %           polymerThickness: the waveguide between the glass layer and
    %           the top air gap
    %
    %        4. airGap + glassThickness + polymerThickness -> airGap + 
    %           glassThickness + polymerThickness + topAirGap: the top air
    %           gap between the waveguide and the DBR.
    %
    %   Define the airGap Value:
    bottomAirGap = 50e-6;
    %   Define the topAirGap Value:
    topAirGap = 50e-6;       
    %   Define the Glass Thickness Value:
    glassThickness = 100e-6;
    %   Create the geometry of the LSC in a matrix form where:
    %
    %       [x-length, x-length, NA, NA, NA]
    %       [y-length, y-length, NA, NA, NA]
    %       [0, z-length(1), z-length(2), z-length(3), z-length(4)]
    geometry = [[-xSize,xSize,0,0,0,0]',[-ySize,ySize,0,0,0,0]',        ...
    [0, 0, 0 + bottomAirGap, 0 + bottomAirGap + glassThickness, 0 +     ...
    bottomAirGap + glassThickness + waveguideThickness, 0 + bottomAirGap...
    + glassThickness + waveguideThickness + topAirGap]']';
    %   Set a cell area of 800um x 800um:
    solarCell(:,:,1) = [[-400e-6, 400e-6]' , [-400e-6,400e-6]',         ...
    [geometry(3,4), geometry(3,4)+cellThickness]']';
    
    
    %   For the case of the Si HIT micro-cells only:
    %solarCell = [[-inputCellLength,inputCellLength]',                  ...
    %             [-inputCellLength,inputCellLength]',                  ...
    %             [geometry(3,4),geometry(3,4)+inputCellThick]']';

    %   The base case where there is no micro-cell at all:
    %solarCell = [[0, 0]' , [0,0]', ...
    %            [geometry(3,4), geometry(3,4)+0]']'; 
    
    
    %   This is a simplified vector of the waveguide's size:
    wgSize = [-xSize, ySize];
    %   Define the total illumination area for our LSC:
    illuminationArea = (2 * spotSize)^2;
    %   If we are using a bifacial cell:
    if bifacialInGaP
        %   Define the total output cell area for our InGaP cell
        %   (top area) + 4*(side area) + (bottom area):
        outputCellArea = 2*(solarCell(1,2) - solarCell(1,1)) *          ...
        (solarCell(2,2) - solarCell(2,1));
    %   If we are using an edge lined geometry:
    elseif edgeLined
        %   Define the total output cell area:
        outputCellArea = (xSize*2*(glassThickness+waveguideThickness))* ...
        lscCellNum;
    else
        %   Define the total output cell area for our LSC cell
        %   (top area):
        outputCellArea =   (solarCell(1,2) - solarCell(1,1)) *          ...
        (solarCell(2,2) - solarCell(2,1));
    end
    %   The definition of the Geometric Gain is the ratio of the
    %   illumination area to cell (InGaP) output area:
    geometricGain = illuminationArea / outputCellArea;
    %
    %   Finally, let's calculate the number of grid points that are
    %   directly on top fo the InGaP solar cell for simulation:
    %
    cellGridPoints = ((solarCell(1,2) - solarCell(1,1))/gridSize) *     ...
    ((solarCell(2,2)-solarCell(2,1))/gridSize); 
end
        
        
        
        
        
        
        
        
                                                             