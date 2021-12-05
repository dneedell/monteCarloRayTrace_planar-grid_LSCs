function [] = parseData()
    %   load testing folder directory:
    folder = dir('testingData_2020-04-19_DetailedBalance_varyLum_matchedCell_varyGG_withFilter/');
    %   save the size of the folder minus two NA:
    folderSize = size(folder,1)-2;
    %   array for different parameters:
    lumPLFileIndex = zeros(folderSize,1);
    lumAbsFileIndex = zeros(folderSize,1);
    lumPLQY = zeros(folderSize,1);
    lumOpticalDensity = zeros(folderSize,1);
    lumScatteringDist = zeros(folderSize,1);
    anisotropicPLBoolean = zeros(folderSize,1);
    anisotropicPLFileIndex = zeros(folderSize,1);
    amolfAnisotropicBoolean = zeros(folderSize,1);
    amolfAnisotropicEscConeFrac = zeros(folderSize,1);
    lscCellFileIndex = zeros(folderSize,1);
    lscCellThickness = zeros(folderSize,1);
    lscCellBifaciality = zeros(folderSize,1);
    detailedBalanceModeBoolean = zeros(folderSize,1);
    bottomCellFileIndex = zeros(folderSize,1);
    wgEdgeReflectance = zeros(folderSize,1);
    wgEdgeScatterProb = zeros(folderSize,1);
    wgSizeIndex = zeros(folderSize,1);
    wgThickness = zeros(folderSize,1);
    wgFracIlluminated = zeros(folderSize,1);
    wgEdgeLinedPVBoolean = zeros(folderSize,1);
    topFilterBoolean = zeros(folderSize,1);
    topFilterFileIndex = zeros(folderSize,1);
    topFilterReflectanceFactor = zeros(folderSize,1);
    bottomFilterBoolean = zeros(folderSize,1);
    bottomFilterFileIndex = zeros(folderSize,1);
    dniFraction = zeros(folderSize,1);
    blueFilterBoolean = zeros(folderSize,1);
    blueFilterFileIndex = zeros(folderSize,1);
    lscCellEnergyBandgap = zeros(folderSize,1);
    GeometricGain = zeros(folderSize,1);
    lscCellJsc = zeros(folderSize,1);
    lscCellVoc = zeros(folderSize,1);
    lscCellFF = zeros(folderSize,1);
    bottomCellJsc = zeros(folderSize,1);
    bottomCellVoc = zeros(folderSize,1);
    bottomCellFF = zeros(folderSize,1);
    modulePowerEfficiency = zeros(folderSize,1);
    %   iterate through folder to save data:
    for file = 1:folderSize
        %   save the file name for loading:
        name = folder(file+2).name;
        %   load the current file's data:
        load(strcat('testingData_2020-04-19_DetailedBalance_varyLum_matchedCell_varyGG_withFilter/',name));
        %   save the appropriate data:
        lumPLFileIndex(file) = dbrFileIndexTop;
        lumAbsFileIndex(file) = dbrFileIndexTop;
        lumPLQY(file) = plqy;
        lumOpticalDensity(file) = opticalDensity;
        lumScatteringDist(file) = qdScatterDistance;
        anisotropicPLBoolean(file) = anisotropicBool;
        anisotropicPLFileIndex(file) = anisotropicFuncIndex;
        amolfAnisotropicBoolean(file) = anisotropicBool;
        amolfAnisotropicEscConeFrac(file) = anisotropicFrac;
        lscCellFileIndex(file) = EQEFileIndex;
        lscCellThickness(file) = cellThickness;
        lscCellBifaciality(file) = bifacialInGaP;
        detailedBalanceModeBoolean(file) = 1;
        bottomCellFileIndex(file) = 4;
        wgEdgeReflectance(file) = edgeReflect;
        wgEdgeScatterProb(file) = edgeScatter;
        wgSizeIndex(file) = geometricGain;
        wgThickness(file) = waveguideThickness;
        wgFracIlluminated(file) = 1;
        wgEdgeLinedPVBoolean(file) = false;
        topFilterBoolean(file) = 1;
        topFilterFileIndex(file) = dbrFileIndexTop;
        topFilterReflectanceFactor(file) = filterRefFactor;
        bottomFilterBoolean(file) = 1;
        bottomFilterFileIndex(file) = dbrFileIndexBottom;
        dniFraction(file) = 1;
        blueFilterBoolean(file) = BlueFilterBool;
        blueFilterFileIndex(file) = 9;
        lscCellEnergyBandgap(file) = bandgapEnergy;
        GeometricGain(file) = geometricGain;
        lscCellJsc(file) = JscTotal_InGaP;
        lscCellVoc(file) = Voc_InGaP;
        lscCellFF(file) = FF_InGaP;
        bottomCellJsc(file) = JscTotal_Si;
        bottomCellVoc(file) = Voc_Si;
        bottomCellFF(file) = FF_Si;
        modulePowerEfficiency(file) = efficiencyDevice;
    end
    %   Make the Table in the Matlab Workspace:
    Table = table(lumPLFileIndex,lumAbsFileIndex,lumPLQY,               ...
    lumOpticalDensity,lumScatteringDist,anisotropicPLBoolean,           ...
    anisotropicPLFileIndex,amolfAnisotropicBoolean,                     ...
    amolfAnisotropicEscConeFrac, lscCellFileIndex, lscCellThickness,    ...
    lscCellBifaciality, detailedBalanceModeBoolean, bottomCellFileIndex,...
    wgEdgeReflectance, wgEdgeScatterProb, wgSizeIndex, wgThickness,     ...
    wgFracIlluminated, wgEdgeLinedPVBoolean, topFilterBoolean,          ...
    topFilterFileIndex, topFilterReflectanceFactor, bottomFilterBoolean,...
    bottomFilterFileIndex, dniFraction,                                 ...
    blueFilterBoolean, blueFilterFileIndex, lscCellEnergyBandgap,       ...
    GeometricGain, lscCellJsc, lscCellVoc, lscCellFF, bottomCellJsc,    ...
    bottomCellVoc, bottomCellFF, modulePowerEfficiency);
    %   Make the filename for the Excel Document:
    ExcelFileName = strcat(folderName,'/',testDate,'_','Results.txt');
    %   Write the Excel Document to save in the working directory:
    writetable(Table,ExcelFileName);
end