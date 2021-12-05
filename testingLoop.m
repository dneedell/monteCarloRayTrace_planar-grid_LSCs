%
%   FILE NAME:
%       testingLoop.m
%
%   FILE PURPOSE:
%       To initialize all parameters for the mainMethod.m function in order
%       to simulate the optical and electrical performance of a luminescent
%       concentrator device.
%-------------------------------------------------------------------------
function [] = testingLoop(testDate)
    %   Folder name:
    folderName = strcat('testingData_',testDate);
    %   Make a folder with that name to store all the testing data:
    mkdir(folderName);
    
    %   PARAMETERS FOR THE LUMINOPHORE.
    %----------------------------------------------------------------------
    %   Luminophore PL (file index):
    lumPLFile = 3;%3:83;
    %   Luminophore absorption (file index):
    lumAbsFile = 28;
    %   Luminophore PLQY (double, %):
    lumPLQY = 1;%.9:.1:1;%[.5,.75,.8,.85,.9,.95,.975,.99,.999,1];
    %   Luminophore optical density (double, unitless):
    lumOpticalDensity = 3;%0:0.25:3;
    %   Luminophore scattering distance (double, meters):
    lumScatterDistance = 1e1;%[1e-5,1e-4,1e-2,1e-1,1e0,1e1];
    %   Luminophore anisotropic boolean (logical):
    anisotropicPLBool = true;
    %   Luminophore anisotropic function (file index):
    anisotropicPLFile = 5;%3:12;
    %   AMOLF anisotropic function boolean (logical):
    amolfAnisotropicBool = false;
    %   AMOLF anisotropic function escape cone fraction (double, %):
    amolfAnisotropicFrac = 1;%.75:0.05:1.0; 
    %----------------------------------------------------------------------
    
    %   PARAMETERS FOR THE SOLAR CELLS.
    %----------------------------------------------------------------------
    %   LSC embedded cell index (file index):
    lscCellFile = 6;
    %   LSC embedded cell thickness (double):
    lscCellThickness = 10e-6;
    %   LSC embedded cell radiative efficiency, fraction (double):
    lscCellERE = .10;%.01:.01:.10;%.10
    %   LSC embedded cell bifaciality (logical):
    lscBifacialBool = false;%[true, false];
    %   Waveguide/LSC PV edge-lined geometry (logical):
    edgeLinedBool = true;
    %   Number of LSC cells (integer):
    numCellsLSC = 4;
    %   Detailed balance modelling boolean (logical):
    detailedBalanceBool = false;
    %   Bottom cell (multijunction) cell index (file index):
    bottomCellFile = 4;
    %----------------------------------------------------------------------

    %   PARAMETERS FOR THE WAVEGUIDE.
    %----------------------------------------------------------------------
    %   Waveguide edge reflection (double, %):
    wgEdgeReflect = 0; 
    %   Waveguide edge scattering probability (double, %):
    wgEdgeScatter = 0;
    %   Waveguide top-surface area (sets GG) (double, unitless):
    wgSize = 15;%1:10:101;
    %   Waveguide thickness (double, meters):
    wgThickness = 100e-6;
    %   Waveguide refractive index (double, unitless >= 1):
    wgRefIndex = 1.49;%1:.1:3;
    %   Waveguide area illuminated fraction (double, %):
    fracIllumArea = 1;
    %----------------------------------------------------------------------
    
    %   PARAMETERS FOR THE PL-TRAPPING FILTERS.
    %----------------------------------------------------------------------
    %   Top filter boolean (logical):
    topFilterBool = false;
    %   Top filter index (file index):
    topFilterFile = 35;%3:83;
    %   Top filter reflectance scaling boolean (logical):
    topFilterReflectanceScaling = false;
    %   Top filter reflectance scaling (double, %):
    topFilterReflectanceFactor = 1;%[0:0.1:0.75,.80:.05:.90,.91:.01:.95,.96:.005:1];
    %   Top filter transmittance scaling boolean (logical):
    topFilterTransmittanceScaling = false;
    %   Top filter transmittance scaling (double, %):
    topFilterTransmittanceFactor = 1;%[0:0.1:0.75,.80:.05:.90,.91:.01:.95,.96:.005:1];
    %   Bottom filter boolean (logical):
    bottomFilterBool = false;
    %   Bottom filter index (file index):
    bottomFilterFile = 9;
    %----------------------------------------------------------------------
    
    %   PARAMETERS FOR THE INCOMING IRRADIANCE.
    %----------------------------------------------------------------------
    %   Type of incident light (string):
    irradianceType = {'AM15'};
    %   Fraction of DNI light incident (double, %):
    dniFraction = 1.0;
    %   Blue filter (c-factor analysis) boolean (logical):
    blueFilterBool = false;
    %   Blue filter file (file index):
    blueFilterFile = 9;
    %----------------------------------------------------------------------
    
    %   The total number of permutations:
    totalPermutations =                                                 ...
        size(lscCellFile,2) *                                           ...
        size(lscCellERE,2) *                                            ...
        size(lumPLFile,2) * size(lumAbsFile,2) *                        ...
        size(wgEdgeReflect,2) *                                         ...
        size(lumScatterDistance, 2) *                                   ...
        size(lumPLQY, 2) *                                              ...
        size(lumOpticalDensity, 2) *                                  	...
        size(wgSize, 2) *                                               ...
        size(topFilterFile, 2) *                                        ...
        size(bottomFilterFile,2) *                                      ...
        size(topFilterReflectanceFactor,2) *                            ...
        size(topFilterTransmittanceFactor,2) *                          ...
        size(lscBifacialBool, 2) *                                      ...
        size(edgeLinedBool,2) *                                         ...
        size(numCellsLSC,2) *                                           ...
        size(topFilterBool, 2) *                                        ...
        size(bottomFilterBool, 2) *                                     ...
        size(wgThickness, 2) *                                          ...
        size(wgRefIndex, 2) *                                           ...
        size(dniFraction,2) *                                           ...
        size(bottomCellFile,2) *                                        ...
        size(blueFilterBool,2) *                                        ...
        size(blueFilterFile,2)  *                                       ...
        size(fracIllumArea,2) *                                         ...
        size(wgEdgeScatter,2) *                                         ...
        size(anisotropicPLBool,2) *                                     ...
        size(anisotropicPLFile,2) *                                     ...
        size(amolfAnisotropicBool,2) *                                  ...
        size(amolfAnisotropicFrac,2);
        %   Initialize an empty matrix with: 1. rows = number of
        %   permutations, 2. cols = 32 (permutations) + 9 (outputs) to hold
        %   our four pieces of data of interest.
        dataOut = zeros(totalPermutations, 41);
        %   An index to keep track of the row number:
        indexRow = 1;
    %   For all lsc cell bandgaps:
    for lscCellFileIndex = lscCellFile
        %   For all lumin. PL:
        for lumPLFileIndex = lumPLFile
            %   For all lumin. Abs:
            for lumAbsFileIndex = lumAbsFile
                %   For all optical density values:
                for lumOpticalDensityIndex = lumOpticalDensity
                    %   For all scattering distance lengths:
                    for lumScatterDistanceIndex = lumScatterDistance
                        %   For all values of PLQY:
                        for lumPLQYIndex = lumPLQY
                            %   For all geometric gain values:
                            for wgSizeIndex = wgSize
                                %   For all DBR test files:
                                for topFilterFileIndex = topFilterFile
                                    %   For all bottom filter:
                                    for bottomFilterFileIndex = bottomFilterFile
                                        %   For yes/no top filter:
                                        for topFilterBoolIndex = topFilterBool
                                            %   For yes/no bottom filter:
                                            for bottomFilterBoolIndex = bottomFilterBool
                                                %   For all DNI variations:
                                                for dniFractionIndex = dniFraction
                                                    %   For all bottom PV cell types:
                                                    for bottomCellFileIndex = bottomCellFile
                                                        %   For bifacial microcells:
                                                        for lscBifacialBoolIndex = lscBifacialBool
                                                            %   Edge Reflection:
                                                            for wgEdgeReflectIndex = wgEdgeReflect
                                                                %   Blue Filter Boolean:
                                                                for blueFilerBoolIndex = blueFilterBool
                                                                    %   Blue Filter Index
                                                                    for blueFilterFileIndex = blueFilterFile
                                                                        %   Illum. area index:
                                                                        for fracIllumAreaIndex = fracIllumArea
                                                                            %   Edge scatter:
                                                                            for wgEdgeScatterIndex = wgEdgeScatter
                                                                                %   WG Thick:
                                                                                for waveguideThicknessIndex = wgThickness
                                                                                    %   Anisotropic Bool:
                                                                                    for anisotropicPLBoolIndex = anisotropicPLBool
                                                                                        %   Anisotropic Index:
                                                                                        for anisotropicPLFileIndex = anisotropicPLFile
                                                                                            %   Reflectance factor:
                                                                                            for topFilterReflectanceFactorIndex = topFilterReflectanceFactor
                                                                                                %   Transmittance factor:
                                                                                                for topFilterTransmittanceFactorIndex = topFilterTransmittanceFactor
                                                                                                    %   AMOLF's anisotropic func:
                                                                                                    for amolfAnisotropicBoolIndex = amolfAnisotropicBool
                                                                                                        %   AMOLF's anisot. func fraction:
                                                                                                        for amolfAnisotropicFracIndex = amolfAnisotropicFrac
                                                                                                            %   LSC cell thickness:
                                                                                                            for lscCellThicknessIndex = lscCellThickness
                                                                                                                %   The type of irradiance spectrum:
                                                                                                                for irradianceTypeIndex = irradianceType
                                                                                                                    %   If using PV edge-lined geometry:
                                                                                                                    for edgeLinedBoolIndex = edgeLinedBool
                                                                                                                        %   Number of LSC cells:
                                                                                                                        for numCellsLSCIndex = numCellsLSC
                                                                                                                            %   LSC cell ERE:
                                                                                                                            for lscCellEREIndex = lscCellERE
                                                                                                                                %   Waveguide refractive index:
                                                                                                                                for wgRefIndexIndex = wgRefIndex
        %   Save this permutation in the refVector cell:
        dataOut(indexRow,1) = lumPLFileIndex;
        dataOut(indexRow,2) = lumPLFileIndex;
        dataOut(indexRow,3) = lumPLQYIndex;
        dataOut(indexRow,4) = lumOpticalDensityIndex;
        dataOut(indexRow,5) = lumScatterDistanceIndex;
        dataOut(indexRow,6) = anisotropicPLBoolIndex;
        dataOut(indexRow,7) = anisotropicPLFileIndex;
        dataOut(indexRow,8) = amolfAnisotropicBoolIndex;
        dataOut(indexRow,9) = amolfAnisotropicFracIndex;
        dataOut(indexRow,10) = lumPLFileIndex+30;% lscCellFileIndex;
        dataOut(indexRow,11) = lscCellThicknessIndex;
        dataOut(indexRow,12) = lscCellEREIndex;
        dataOut(indexRow,13) = lscBifacialBoolIndex;
        dataOut(indexRow,14) = detailedBalanceBool;
        dataOut(indexRow,15) = bottomCellFileIndex;
        dataOut(indexRow,16) = wgEdgeReflectIndex;
        dataOut(indexRow,17) = wgEdgeScatterIndex;
        dataOut(indexRow,18) = wgSizeIndex;
        dataOut(indexRow,19) = waveguideThicknessIndex;
        dataOut(indexRow,20) = wgRefIndexIndex;
        dataOut(indexRow,21) = fracIllumAreaIndex;
        dataOut(indexRow,22) = edgeLinedBoolIndex;
        dataOut(indexRow,23) = numCellsLSCIndex;
        dataOut(indexRow,24) = topFilterBoolIndex;
        dataOut(indexRow,25) = topFilterFileIndex;
        dataOut(indexRow,26) = topFilterReflectanceFactorIndex;
        dataOut(indexRow,27) = topFilterTransmittanceFactorIndex;
        dataOut(indexRow,28) = bottomFilterBoolIndex;
        dataOut(indexRow,29) = bottomFilterFileIndex;
        dataOut(indexRow,30) = dniFractionIndex;
        dataOut(indexRow,31) = blueFilerBoolIndex;
        dataOut(indexRow,32) = blueFilterFileIndex;
        %   Run the Monte Carlo Simulation:
        [dataOut(indexRow,33),                                          ...
        dataOut(indexRow,34),                                           ...
        dataOut(indexRow,35),                                           ...
        dataOut(indexRow,36),                                           ...
        dataOut(indexRow,37),                                           ...
        dataOut(indexRow,38),                                           ...
        dataOut(indexRow,39),                                           ...
        dataOut(indexRow,40),                                           ...
        dataOut(indexRow,41)]                                           ...
                                                                        ...
        = mainMethod(lumPLFileIndex, lumAbsFileIndex,                   ...
        wgEdgeReflectIndex, wgEdgeScatterIndex, topFilterBoolIndex,     ...
        bottomFilterBoolIndex, lumPLQYIndex,lumOpticalDensityIndex,     ...
        lscCellThicknessIndex, lumScatterDistanceIndex,                 ...
        wgSizeIndex, testDate, topFilterFileIndex,bottomFilterFileIndex,...
        lscBifacialBoolIndex, edgeLinedBoolIndex, numCellsLSCIndex,     ...
        waveguideThicknessIndex, wgRefIndexIndex, dniFractionIndex,     ...
        bottomCellFileIndex, blueFilerBoolIndex, blueFilterFileIndex,   ...
        fracIllumAreaIndex, anisotropicPLBoolIndex,                     ...
        anisotropicPLFileIndex, amolfAnisotropicBoolIndex,              ...
        amolfAnisotropicFracIndex, detailedBalanceBool,lscCellFileIndex,...
        lscCellEREIndex, topFilterReflectanceScaling,                              ...
        topFilterReflectanceFactorIndex, topFilterTransmittanceScaling, ...
        topFilterTransmittanceFactorIndex, indexRow, totalPermutations, ...
        irradianceTypeIndex);
        %   Increment the row index
        indexRow = indexRow + 1;        
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end
                                                                                                                end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end 
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    %   Names for the data columns to be saved:
    lumPLFileIndex = dataOut(:,1);
    lumAbsFileIndex = dataOut(:,2);
    lumPLQY = dataOut(:,3);
    lumOpticalDensity = dataOut(:,4);
    lumScatteringDist = dataOut(:,5);
    anisotropicPLBoolean = dataOut(:,6);
    anisotropicPLFileIndex = dataOut(:,7);
    amolfAnisotropicBoolean = dataOut(:,8);
    amolfAnisotropicEscConeFrac = dataOut(:,9);
    lscCellFileIndex = dataOut(:,10);
    lscCellThickness = dataOut(:,11);
    lscCellERE = dataOut(:,12);
    lscCellBifaciality = dataOut(:,13);
    detailedBalanceModeBoolean = dataOut(:,14);
    bottomCellFileIndex = dataOut(:,15);
    wgEdgeReflectance = dataOut(:,16);
    wgEdgeScatterProb = dataOut(:,17);
    wgSizeIndex = dataOut(:,18);
    wgThickness = dataOut(:,19);
    wgRefractiveIndex = dataOut(:,20);
    wgFracIlluminated  = dataOut(:,21);
    wgEdgeLinedPVBoolean  = dataOut(:,22);
    numLSCEdgeCells = dataOut(:,23);
    topFilterBoolean  = dataOut(:,24);
    topFilterFileIndex  = dataOut(:,25);
    topFilterReflectanceFactor  = dataOut(:,26);
    topFilterTransmittanceFactor = dataOut(:,27);
    bottomFilterBoolean = dataOut(:,28);
    bottomFilterFileIndex  = dataOut(:,29);
    dniFraction = dataOut(:,30);
    blueFilterBoolean  = dataOut(:,31);
    blueFilterFileIndex = dataOut(:,32);
    lscCellEnergyBandgap = dataOut(:,33);
    geometricGain = dataOut(:,34);
    lscCellJsc = dataOut(:,35);
    lscCellVoc = dataOut(:,36);
    lscCellFF = dataOut(:,37);
    bottomCellJsc = dataOut(:,38);
    bottomCellVoc = dataOut(:,39);
    bottomCellFF = dataOut(:,40);
    modulePowerEfficiency = dataOut(:,41);
    %   Make the Table in the Matlab Workspace:
    Table = table(lumPLFileIndex,lumAbsFileIndex,lumPLQY,               ...
    lumOpticalDensity,lumScatteringDist,anisotropicPLBoolean,           ...
    anisotropicPLFileIndex,amolfAnisotropicBoolean,                     ...
    amolfAnisotropicEscConeFrac, lscCellFileIndex, lscCellThickness,    ...
    lscCellERE, lscCellBifaciality, detailedBalanceModeBoolean,         ...
    bottomCellFileIndex, wgEdgeReflectance, wgEdgeScatterProb,          ...
    wgSizeIndex, wgThickness, wgRefractiveIndex, wgFracIlluminated,     ...
    wgEdgeLinedPVBoolean, numLSCEdgeCells, topFilterBoolean,            ...
    topFilterFileIndex, topFilterReflectanceFactor,                     ...
    topFilterTransmittanceFactor, bottomFilterBoolean,                  ...
    bottomFilterFileIndex, dniFraction, blueFilterBoolean,              ...
    blueFilterFileIndex, lscCellEnergyBandgap, geometricGain,           ...
    lscCellJsc, lscCellVoc, lscCellFF, bottomCellJsc,                   ...
    bottomCellVoc, bottomCellFF, modulePowerEfficiency);
    %   Make the filename for the Excel Document:
    ExcelFileName = strcat(folderName,'/',testDate,'_','Results.txt');
    %   Write the Excel Document to save in the working directory:
    writetable(Table,ExcelFileName);
    %   Finally, send an email to the user to let them know that the
    %   testing is now complete:
    %emailNotification('aeolus1','MonteCarloSimulations',                ...
    %                  'dneedell@caltech.edu');
        
end








