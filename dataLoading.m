%
%   FILE NAME:
%       dataLoading.m
%
%   FILE PURPOSE:
%       To load all external data files into the simulation in order to 
%       define the component characteristics of the luminescent solar
%       concentrator.
%-------------------------------------------------------------------------
function [reflect_lscCell, IQE_lscCell, reflect_bottomCell,             ...
          IQE_bottomCell, ...inputCellLength, inputCellThick,           ...
          lumPLSpectrum, lumAbsSpectrum,                                ...
          reflectFilterTop, transmitFilterTop, reflectFilterBottom,     ...                                     
          transmitFilterBottom, lumScattering, mirrorNameTop,           ...
          mirrorNameBottom, reflectBlueFilter, anisotropicFunc,         ...
          anisotropicFrac, energyBandgap, incidentLightSpectrumWatts,   ...
          incidentLightSpectrumAmps, incidentLightSpectrumWavelength]   ...
                                                                        ...
= dataLoading(PLFileIndex, AbsFileIndex, topFilterFileIndex,            ...
              botFilterFileIndex, BottomCellFileIndex, BlueFilterIndex, ...
              anisotropicBool, anisotropicFuncIndex, amolfAnisBool,     ...
              amolfAnisFrac, detailedBalance, lscCellFileIndex,         ...
              topFilterScalingR, filterRefFactor, topFilterScalingT,    ...
              filterTranFactor, incidentLightType)
    %   Import the file directory containing the LSC cell data:
    filesLSCCell = dir('loadingData/PVCell_Materials/RealisticSolarCells');
    %   Save the filename of the LSC cell according to user input:
    fileNameLSCCell = filesLSCCell(lscCellFileIndex).name;
    %   Now load the LSC cell Data file with the corresponding name:
    load(strcat('loadingData/PVCell_Materials/RealisticSolarCells/',fileNameLSCCell));
    %   Save the reflection spectrum for LSC:
    reflect_lscCell = dataReflectance;
    %   Save the IQE spectrum for LSC:
    IQE_lscCell = dataIQE;
    %   If using detailed balance, save the energy bandgap:
    if detailedBalance
        energyBandgap = Eg;
    else
        energyBandgap = 0;
    end
    clear dataIQE dataReflectance Eg
    %   Import the file directory containing the Bottom cell data:
    filesBottomCell = dir('loadingData/OpticalSurface_Materials');
    %   Save the filename of the Bottom cell according to user input:
    fileNameBottomCell = filesBottomCell(BottomCellFileIndex).name;
    %   Now load the Bottom cell Data file with the corresponding name:
    load(strcat('loadingData/OpticalSurface_Materials/',fileNameBottomCell));
    %   Save the reflection spectrum for Bottom cell:
    reflect_bottomCell = dataReflectance;
    %--------------------------------------------------------------
    %   Reflectance for embedded cell for the HIT Si modeling:
    %--------------------------------------------------------------
    %reflectInGaP = Reflect;
    %   Save the IQE spectrum for InGaP:
    IQE_bottomCell = dataIQE;
    %--------------------------------------------------------------
    %   IQE for embedded cell for the HIT Si modeling:
    %--------------------------------------------------------------
    %IQEInGaP = IQE;
    %--------------------------------------------------------------
    %   Save the input cell size and thickness for the Si HIT cell
    %   parameters only!!
    %--------------------------------------------------------------
    %inputCellLength = CellSize;
    %inputCellThick = CellThickness;
    %   Import the structure of luminophore PL files:
    filesPL = dir('loadingData/Luminophore_Spectra/luminophorePL/ArtificialLuminophore/FullSpectra_Vary_AbsorptionEdge_FWHM20');
    %   Set the filename of the PL file according to the
    %   user input:
    fileNamePL = filesPL(PLFileIndex).name;
    %   Now load the correct QD PL file:
    load(strcat('loadingData/Luminophore_Spectra/luminophorePL/ArtificialLuminophore/FullSpectra_Vary_AbsorptionEdge_FWHM20/',       ...
    fileNamePL));
    %   Save the pl structure:
    lumPLSpectrum = dataLumPhotolum;
    %   Import the structure of luminophore Abs files:
    filesAbs = dir('loadingData/Luminophore_Spectra/luminophoreAbs/ArtificialLuminophore/Vary_AbsorptionEdge_StokesRatio10');
    %   Set the filename of the abs file according to the
    %   user input:
    fileNameAbs = filesAbs(AbsFileIndex).name;
    %   Now load the correct luminophore Abs file:
    load(strcat('loadingData/Luminophore_Spectra/luminophoreAbs/ArtificialLuminophore/Vary_AbsorptionEdge_StokesRatio10/',      ...
    fileNameAbs));
    %   Save the Absorption (y-axis)
    lumAbsSpectrum = dataLumAbsorption;
    %   Import the structure of top mirror files:
    files = dir('loadingData/Filter_Spectra/IdealFilters/stepFunctionFilters_artificalLuminophores/Vary_AbsorptionEdge_SS200_FWHM20');
    %   Set the filename of the Top Mirror file according to the
    %   user input:
    fileNameTopFilter = files(topFilterFileIndex).name;
    %   Now load the correct Top Mirror file:
    load(strcat('loadingData/Filter_Spectra/IdealFilters/stepFunctionFilters_artificalLuminophores/Vary_AbsorptionEdge_SS200_FWHM20/',         ...
    fileNameTopFilter));
    %   Save the average reflectance data for the top mirror:
    reflectFilterTop = dataReflectance;
    %   Save the average transmittance data for the top mirror:
    transmitFilterTop = dataTransmittance;
    %   If scaling the filter reflectance or transmittance spectra:
    if topFilterScalingR
        reflectFilterTop = reflectFilterTop .* filterRefFactor;
        transmitFilterTop = 1-reflectFilterTop;
    elseif topFilterScalingT
        transmitFilterTop = transmitFilterTop .* filterTranFactor;
        reflectFilterTop = 1-transmitFilterTop;
    end
    %   Save the name of the file for output:
    mirrorNameTop = fileNameTopFilter;
    %   Clear the current loaded reflectance file:
    clear dataReflectance dataTransmittance files
    %   Import the structure of bottom filter files:
    files = dir('loadingData/Filter_Spectra/IdealFilters/stepFunctionFilters_artificalLuminophores/Vary_AbsorptionEdge_SS200_FWHM20'); 
    %   Set the filename of the Bottom Mirror file according to the
    %   user input:
    fileNameBottomFilter = files(botFilterFileIndex).name;
    %   Now load the correct Bottom Mirror file:
    load(strcat('loadingData/Filter_Spectra/IdealFilters/stepFunctionFilters_artificalLuminophores/Vary_AbsorptionEdge_SS200_FWHM20/',         ...
    fileNameBottomFilter));
    %   Save the average reflectance data for the bottom mirror:
    reflectFilterBottom = dataReflectance;
    %   Save the average transmittance data for the top mirror:
    transmitFilterBottom = dataTransmittance;
    %   Save the name of the file for output:
    mirrorNameBottom = fileNameBottomFilter;
    %   Clear the current loaded reflectance file:
    clear dataReflectance dataTransmittance files
    %   Import the structure of blue filter files:
    files = dir('loadingData/Filter_Spectra/RealisticFilters'); 
    %   Set the filename of the Bottom Mirror file according to the
    %   user input:
    fileNameBlueFilter = files(BlueFilterIndex).name;
    %   Now load the correct Bottom Mirror file:
    load(strcat('loadingData/Filter_Spectra/RealisticFilters/',         ...
    fileNameBlueFilter));
    %   Save the average reflectance data for the bottom mirror:
    reflectBlueFilter = dataReflectance;
    %   Load the Mie scattering data for QD's
    load('loadingData/LuminophoreScattering/2020-03-06_CoreShell_Luminophore_MieScattering');
    lumScattering = dataScattering;
    %   If using anisotropic emission:
    if anisotropicBool
        if amolfAnisBool
            %   Assign the anisotropic func to just be the escape cone
            %   fraction:
            anisotropicFrac = amolfAnisFrac;
            %   Import the anisotropic emission directory:
            emissionProfileDir = dir(                                   ...
            'loadingData/Luminophore_Spectra/luminophorePL_DirectionalFunct');
            %   Set the filename of the abs file according to the
            %   user input:
            emissionProfileName = emissionProfileDir(                   ...
            anisotropicFuncIndex).name;
            %   Clip the string to eliminate the '.m' characters:
            anisotropicFunc = emissionProfileName(1:end-2);
            %   Add the emission profile directory path to the call:
            addpath(genpath('loadingData/Luminophore_Spectra/luminophorePL_DirectionalFunct'));
        else
            %   Import the anisotropic emission directory:
            emissionProfileDir = dir(                                   ...
            'loadingData/Luminophore_Spectra/luminophorePL_DirectionalFunct');
            %   Set the filename of the abs file according to the
            %   user input:
            emissionProfileName = emissionProfileDir(                   ...
            anisotropicFuncIndex).name;
            %   Clip the string to eliminate the '.m' characters:
            anisotropicFunc = emissionProfileName(1:end-2);
            %   Add the emission profile directory path to the call:
            addpath(genpath('loadingData/Luminophore_Spectra/luminophorePL_DirectionalFunct'));
            %   Give an irrelevant frac data:
            anisotropicFrac = 1;
        end
    else
        anisotropicFunc = 'none';
        anisotropicFrac = 1;
    end
    %   Load the incident light type:
    if strcmp('AM0',incidentLightType)
        %   Load the AM0 spectrum:
        load('loadingData/IncidentLight_Spectra/am0');
        %   Save the spectrum for both watts and amps:
        incidentLightSpectrumWatts = am0Watts;
        incidentLightSpectrumAmps = am0Amps;
        incidentLightSpectrumWavelength = am0Wavelength;
    else
        %   Load the AM1.5g spectrum:
        load('loadingData/IncidentLight_Spectra/am15g');
        %   Save the spectrum for both watts and amps:
        incidentLightSpectrumWatts = am15gWatts;
        incidentLightSpectrumAmps = am15gAmps;
        incidentLightSpectrumWavelength = am15gWavelength;
    end
end
        
