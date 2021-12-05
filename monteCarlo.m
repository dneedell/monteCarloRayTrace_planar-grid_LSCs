%
%   FILE NAME:
%       monteCarlo.m
%
%   FILE PURPOSE:
%       To trace incident photons through the luminescent solar
%       concentrator device, determing if photons are either: a) collected
%       by a solar cell (embedded or underyling), or b) lost/terminated via
%       one of the loss mechanisms.
%-------------------------------------------------------------------------
function [collectPhotonOrigin_lscCell, collectPhotonWavelength_lscCell, ...
    collectPhotonDir_lscCell, shortCircuitCurrent_lscCell,              ...
    collectPhotonOrigin_bottomCell, collectPhotonWavelength_bottomCell, ...
    collectPhotonDir_bottomCell, shortCircuitCurrent_bottomCell,        ...
    incidentPower, numPhotonsLost, numFilterBounces, numPLEvents,       ...
    numLSCEdgeBounces, numWgModeBounces]                                ...
                                                                        ...
= monteCarlo(lumPLQY, solarCell, fractionCellCovered, xInject, yInject, ...
    geometry, plmaSize, probMatrixScatter,                              ...
    probGlassScatter, simWavelengthIndex, wavelengthStep,               ...
    probNotAbsPolymer, photonStep, reflect_lscCell, IQE_lscCell,        ...
    reflect_bottomCell, IQE_bottomCell, lumPLSpectrum, nAir,            ...
    nGlass, nPolymer, topFilterBool, botFilterBool,                     ...
    reflectFilterTop_sPol, transmitFilterTop_sPol,                      ...
    reflectFilterTop_pPol, transmitFilterTop_pPol,                      ...
    reflectFilterBottom_pPol, transmitFilterBottom_pPol,                ...
    reflectFilterBottom_sPol, transmitFilterBottom_sPol, wgEdgeReflect, ...
    wgEdgeScatter, lscCellBifacialBool, simWavelengthRange,             ...
    dataWavelengthRange, gridSize, percentNormal, BlueFilterBool,       ...
    reflectBlueFilter, anisotropicBool, amolfAnisBool, anisotropicFrac, ...
    incidentLightSpectrumWatts, incidentLightSpectrumAmps,              ...
    incidentLightSpectrumWavelength, lscCellEdgeLinedBool, lscCellNum) 
    
    %   Initialize the data structures for this iteration:
    [collectPhotonOrigin_lscCell, collectPhotonOrigin_bottomCell,       ...
        collectPhotonWavelength_lscCell,                                ...
        collectPhotonWavelength_bottomCell,                             ...
        shortCircuitCurrent_lscCell,                                    ...
        shortCircuitCurrent_bottomCell, incidentPower, numFilterBounces,...
        numLSCEdgeBounces, numPLEvents, numWgModeBounces,               ...
        collectPhotonDir_lscCell, collectPhotonDir_bottomCell,          ...
        solarCell,numPhotonsLost]                                       ...
                                                                        ...
    = initializeOutVarMonteCarlo(xInject, yInject, solarCell);
    %   Import the random number generator, 'rng':
    coder.extrinsic('rng'); 
    %   Initialize the random number generator:
    rng('shuffle'); 
    
    %   BEGINNING OF THE MONTE CARLO RAY-TRACE.
    %----------------------------------------------------------------------
    %   For all x gridpoints:
    for xPos = 1:size(xInject,2)
        %   For all y gridpoints:
        for yPos = 1:size(yInject,2)
            % Termination boolean:
            done = false; 
            
            
            %   INITIALIZE THE PHOTON.
            %--------------------------------------------------------------
            %   If photon strikes at normal incidence:
            if rand < percentNormal
                %   Initilize the photon's temporary velocity:
                tempVel = [0 0 -1];
                %   Initilize the polarization angle of the photon:
                photonPolarization = 0;
                %   Set the cosineFactor to 1:
                cosineFactor = 1;
            else
                %   Generate a random value:
                angleGen = rand;
                %   Generate a random polar angle (wrt z axis):
                polarAngle = (pi/2)*angleGen + pi/2;
                %   Generate a random azimuthal angle (wrt x axis):
                azimuthalAngle = (2*pi)*rand;
                %   Now convert this into Cartesian:
                tempVel = [cos(azimuthalAngle)*sin(polarAngle)          ...
                sin(azimuthalAngle)*sin(polarAngle) cos(polarAngle)];
                %   Initilize the polarization of the photon:
                photonPolarization = 0;
                %   Calculate cosine loss factor:
                cosineFactor = abs(cos(polarAngle));
            end
            
            
            %   CALCULATE SPECTRA DETAILS.
            %--------------------------------------------------------------
            %   Calculate the wavelength index for the spectral data
            %   (300:1500nm):
            dataWavelengthIndex = find(simWavelengthRange(              ...
            simWavelengthIndex)== dataWavelengthRange);
            %   Convert to scalar for C compatability:
            dataWavelengthIndex = dataWavelengthIndex(1);
            %   Incident power from this photon:
            incidentPower(xPos,yPos)                                    ...
            = incidentPowerIntegrator(simWavelengthIndex,               ...
            wavelengthStep, simWavelengthRange, cosineFactor, gridSize, ...
            incidentLightSpectrumWavelength, incidentLightSpectrumWatts);
            
        
            %   ASSIGN THE INITIAL POSITION FOR THE INCOMING PHOTON.
            %--------------------------------------------------------------
            %   Assign start position directly at top of LSC:
            startPos = [xInject(xPos) yInject(yPos) geometry(3,5)];
            %   Update position given velocity and step:
            tempPos = startPos + tempVel/2*photonStep;
            %   Keep track of previous position:
            oldPos = startPos - tempVel/2*photonStep;
            
            
            %   CHECK IF THERE IS ANY TOP REFLECTION.
            %--------------------------------------------------------------
            %   If we are using a blue-filter:
            if BlueFilterBool
                %   Calculate current polar angle:
                polarAngleTemp = acos(abs(tempVel(3)));
                %   Calculate current polar angle (degrees) (+1 for index):
                polarAngleTemp_deg = floor(polarAngleTemp*180/pi) + 1;
                %   Calculate s-part of polarization:
                s_part = cos(photonPolarization)^2; 
                %   Calculate p-part of polarization:
                p_part = sin(photonPolarization)^2;
                %   If filter reflects incident photon:
                if rand < (s_part * reflectBlueFilter(                  ...
                dataWavelengthIndex,polarAngleTemp_deg) + p_part *      ...
                reflectBlueFilter(dataWavelengthIndex, polarAngleTemp_deg)) 
                    %   Add to photons lost (1 = top surf. loss):
                    numPhotonsLost(1) = numPhotonsLost(1) + 1;
                    %   Then this photon is lost:
                    done = true;
                end
            end
            %   If there we are using a top filter:
            if topFilterBool
                %   Calculate current polar angle:
                polarAngleTemp = acos(abs(tempVel(3)));
                %   Calculate current polar angle (degrees) (+1 for index):
                polarAngleTemp_deg = floor(polarAngleTemp*180/pi) + 1;
                %   Calculate s-part of polarization:
                s_part = cos(photonPolarization)^2; 
                %   Calculate p-part of polarization:
                p_part = sin(photonPolarization)^2;
                %   If filter reflects or absorbs photon:
                if rand > (s_part * transmitFilterTop_sPol(             ...
                dataWavelengthIndex,polarAngleTemp_deg) + p_part *      ...
                transmitFilterTop_pPol(dataWavelengthIndex,             ...
                polarAngleTemp_deg)) 
                    %   Add to photons lost (1 = top surf. loss):
                    numPhotonsLost(1) = numPhotonsLost(1) + 1;
                    %   Then this photon is lost:
                    done = true;
                end
            end
            
            
            %   LOOP THROUGH UNTIL PHOTON IS LOST OR COLLECTED.
            %--------------------------------------------------------------
            %   While the photon is not lost:
            while done == false
                
                
                %   CHECK IF PHOTON HITS SOLAR CELL(S).
                %----------------------------------------------------------
                %   If the photon position is within the LSC solar cell:
                if tempPos(1) <= solarCell(1,2) &&                      ...
                   tempPos(1) >= solarCell(1,1) &&                      ...
                   tempPos(2) <= solarCell(2,2) &&                      ...
                   tempPos(2) >= solarCell(2,1) &&                      ...
                   tempPos(3) <= solarCell(3,2) &&                      ...
                   tempPos(3) >= solarCell(3,1) &&                      ...
                   ~lscCellEdgeLinedBool
                    %   If the photon strikes solar cell top or bottom:
                    if oldPos(3) > solarCell(3,2) ||                    ...
                       oldPos(3) < solarCell(3,1) 
                        %   If the photon came in from the top: 
                        if oldPos(3) > solarCell(3,2)
                            %   Record the photon's direction:
                            collectPhotonDir_lscCell(1,xPos, yPos,:)    ...
                            = tempVel; 
                        else
                            %   Record the photon's direction:
                            collectPhotonDir_lscCell(2,xPos, yPos,:)    ...
                            = tempVel;
                        end
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If LSC cell top doesn't reflect photon:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg) && rand >                   ...
                        fractionCellCovered && oldPos(3) >              ...
                        solarCell(3,2)
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   If LSC cell bottom doesn't reflect (bifacial):
                        elseif rand > reflect_lscCell(                  ...
                        dataWavelengthIndex, polarAngleTemp_deg) &&     ...
                        rand > fractionCellCovered && oldPos(3) <       ...
                        solarCell(3,1) && lscCellBifacialBool
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect z-velocity:
                            tempVel(3) = -tempVel(3);
                            %   Update the temporary position:
                            tempPos(3) = tempPos(3) + tempVel(3) *      ...
                            photonStep;
                        end
                    %   Photon strikes front or back:
                    elseif oldPos(2) > solarCell(2,2) ||                ...
                           oldPos(2) < solarCell(2,1) 
                        %   If the photon came in from the front:
                        if oldPos(2) > solarCell(2,2)
                            %   Record the photon's direction:
                            collectPhotonDir_lscCell(3,xPos, yPos,:)    ...
                            = tempVel; 
                        else
                            %   Record the photon's direction:
                            collectPhotonDir_lscCell(4,xPos, yPos,:)    ...
                            = tempVel; 
                        end
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If the photon is not reflected by the
                        %   solar cell:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg)
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect y-velocity:
                            tempVel(2) = -tempVel(2);
                            %   Update the temporary position:
                            tempPos(2) = tempPos(2) + tempVel(2) *      ...
                            photonStep;
                        end
                    %   Photon strikes left or right sides:
                    else
                        %   If the photon came in from the right side:
                        if oldPos(1) > solarCell(2,2)
                            %   Record the photon's direction:
                            collectPhotonDir_lscCell(5,xPos,yPos,:)     ...
                            = tempVel; 
                        else
                            %   Record the photon's direction:
                            collectPhotonDir_lscCell(6,xPos,yPos,:)     ...
                            = tempVel; 
                        end
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If the photon is not reflected by the
                        %   solar cell:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg)
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect x-velocity:
                            tempVel(1) = -tempVel(1);
                            %   Update the temporary position:
                            tempPos(1) = tempPos(1) + tempVel(1) *      ...
                            photonStep;
                        end
                    end
                end
                
                
                %   UPDATING PHOTON POSITION.
                %----------------------------------------------------------
                %   Save old position before moving:
                oldPos = tempPos; 
                %   Move photon given current velocity:
                tempPos = oldPos + photonStep*tempVel; 
                
                
                %   CHECK FOR PHOTON TRAVELING THROUGH WAVEGUIDE.
                %----------------------------------------------------------
                %   If the photon position is within LSC waveguide:
                if tempPos(1) >= plmaSize(1) &&                         ...
                   tempPos(1) <= plmaSize(2) &&                         ...
                   tempPos(2) >= plmaSize(1) &&                         ...
                   tempPos(2) <= plmaSize(2) 
                    %   Check if z lies within the waveguide layer:
                    if tempPos(3) <= geometry(3,5) &&                   ...
                       tempPos(3) >= geometry(3,4)
                        %   If the photon is absorbed by the LSC waveguide:
                        if rand > probNotAbsPolymer(dataWavelengthIndex) 
                            %   If the photon is parasitically absorbed:
                            if rand > lumPLQY 
                                %   Add to photons lost (2 = lum. loss):
                                numPhotonsLost(2) = numPhotonsLost(2) + 1;
                                %   Photon is lost:
                                done = true;
                                %   Break from the while loop:
                                break;
                            %   Else photon is emitted:
                            else
                                %   Add PL event:
                                numPLEvents(xPos,yPos) = numPLEvents(   ...
                                xPos,yPos) + 1;
                                %   Boolean for wavelength emission:
                                reEmmited = false;
                                %   While searching for emission:
                                while reEmmited == false
                                    %   Generate a random wavelength index:
                                    newWavelengthIndex = ceil(rand *    ...
                                    size(dataWavelengthRange,2));
                                    %   If PL occurs at new wavelength:
                                    if rand < lumPLSpectrum(            ...
                                    newWavelengthIndex)
                                        %   Update the photon wavelength:
                                        dataWavelengthIndex =           ...
                                        newWavelengthIndex;
                                        %   If using anisotropic emitter:
                                        if anisotropicBool
                                            %   If using AMOLF's function:
                                            if amolfAnisBool
                                                %   PL direction:
                                                [tempVel,               ...
                                                photonPolarization]     ...
                                                                        ...
                                                = anisotropicScatter_Fesc(anisotropicFrac);
                                                %   The photon is emitted:
                                                reEmmited = true;
                                            else
                                                %   PL direction:
                                                [tempVel,               ...
                                                 photonPolarization]    ...
                                                                        ...
                                                = anisotropicScatter();
                                                %   The photon is emitted:
                                                reEmmited = true;
                                            end
                                        %   Else using isotropic:
                                        else
                                            %   PL direction:
                                            [tempVel,photonPolarization]...
                                                                        ...
                                            = scatter();
                                            %   The photon is emitted:
                                            reEmmited = true;
                                        end
                                    end
                                end
                            end
                        end
                        %   If the photon is scattered within the
                        %   waveguide:
                        if rand < probMatrixScatter(dataWavelengthIndex)
                            %   Scatter the photon:
                            [tempVel, photonPolarization] = scatter();
                        end
                    end
                    %   Else if z lies in the glass layer (under WG):
                    if tempPos(3) < geometry(3,4) &&                    ...
                       tempPos(3) > geometry(3,3) &&                    ...
                       rand < probGlassScatter  
                        %   Scatter the photon:
                        [tempVel, photonPolarization] = scatter();
                    %   Else if z lies in the glass layer (on bottom cell):
                    elseif tempPos(3) < geometry(3,2) &&                ...
                           tempPos(3) > geometry(3,1) &&                ...
                           rand < probGlassScatter
                       %    Scatter the photon:
                       [tempVel, photonPolarization] = scatter();
                    end
                end
                
                
                %   CHECK FOR PHOTON REACHING EDGES OF LSC.
                %----------------------------------------------------------
                %   If the photon hits the right side of the LSC:
                if tempPos(1) >= geometry(1,2) 
                    %   If using edge-lined PV cells and at least one cell:
                    if lscCellEdgeLinedBool && lscCellNum >= 1
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If PV cell doesn't reflect photon:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg) && rand > fractionCellCovered
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect the x-velocity:
                            tempVel(1) = -abs(tempVel(1));
                            %   Move the photon through by one step:
                            tempPos(1) = geometry(1,2) - photonStep;
                        end
                    %   Else we don't have a PV cell at the edge:    
                    else
                        %   Add one to the number of edge bounces:
                        numLSCEdgeBounces(xPos,yPos) =                  ...
                        numLSCEdgeBounces(xPos,yPos) + 1;
                        %   If the photon is not reflected:
                        if rand > wgEdgeReflect
                            %   Add one to the photonsLost variable:
                            numPhotonsLost(3) = numPhotonsLost(3) + 1;
                            %   The photon is lost and terminated:
                            done=true;
                            %   Now break from the while loop:
                            break;
                        %   Else the photon is reflected or scattered:
                        else
                            %   If the photon is scattered:
                            if rand < wgEdgeScatter
                                %   Scatter the photon by the waveguide
                                %   edge:
                                [tempVel, photonPolarization] =         ...
                                backside_scatter();
                                %   Shift the temporary velocity:
                                tempVel = circshift(tempVel,[1,1]);
                            end
                            %   Reflect the x-velocity:
                            tempVel(1) = -abs(tempVel(1));
                            %   Move the photon through by one step:
                            tempPos(1) = geometry(1,2) - photonStep;
                        end
                    end
                %   If the photon hits the left side of the LSC:
                elseif tempPos(1) <= geometry(1,1) 
                    %   If using edge-lined PV cells and at least two
                    %   cells:
                    if lscCellEdgeLinedBool && lscCellNum >= 2
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If PV cell doesn't reflect photon:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg) && rand > fractionCellCovered
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect the x-velocity:
                            tempVel(1) = abs(tempVel(1));
                            %   Move the photon through by one step:
                            tempPos(1) = geometry(1,1) + photonStep;
                        end
                    %   Else we don't have a PV cell at the edge: 
                    else
                        %   Add one to the number of edge bounces:
                        numLSCEdgeBounces(xPos,yPos) =                  ...
                        numLSCEdgeBounces(xPos,yPos) + 1;
                        %   If the photon is not reflected:
                        if rand > wgEdgeReflect
                            %   Add one to the photonsLost variable:
                            numPhotonsLost(4) = numPhotonsLost(4) + 1;
                            %   The photon is lost and terminated:
                            done=true;
                            %   Now break from the while loop:
                            break;
                        %   Else the photon is reflected or scattered:
                        else
                            %   If the photon is scattered:
                            if rand < wgEdgeScatter
                                %   Scatter the photon by the waveguide
                                %   edge:
                                [tempVel, photonPolarization] =         ...
                                backside_scatter();
                                %   Shift the temporary velocity:
                                tempVel = circshift(tempVel,[1,1]);
                            end
                            %   Reflect the x-velocity:
                            tempVel(1) = abs(tempVel(1));
                            %   Move the photon through by one step:
                            tempPos(1) = geometry(1,1) + photonStep;
                        end
                    end
                %   If the photon hits the back side of the LSC:
                elseif tempPos(2) >= geometry(2,2) 
                    %   If using edge-lined PV cells and at least three
                    %   cells:
                    if lscCellEdgeLinedBool && lscCellNum >= 3
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If PV cell doesn't reflect photon:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg) && rand > fractionCellCovered
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect the y-velocity:
                            tempVel(2) = -abs(tempVel(2));
                            %   Move the photon by one step:
                            tempPos(2) = geometry(2,2) - photonStep;
                        end
                    %   Else we don't have a PV cell at the edge: 
                    else
                        %   Add one to the number of edge bounces:
                        numLSCEdgeBounces(xPos,yPos) =                  ...
                        numLSCEdgeBounces(xPos,yPos) + 1;
                        %   If the photon is not reflected:
                        if rand > wgEdgeReflect
                            %   Add one to the photonsLost variable:
                            numPhotonsLost(5) = numPhotonsLost(5) + 1;
                            %   The photon is lost and terminated:
                            done=true;
                            %   Now break from the while loop:
                            break;
                        %   Else the photon is reflected or scattered:
                        else
                            %   If the photon is scattered:
                            if rand < wgEdgeScatter
                                %   Scatter the photon by the waveguide
                                %   edge:
                                [tempVel, photonPolarization] =         ...
                                backside_scatter();
                                %   Shift the temporary velocity:
                                tempVel = circshift(tempVel,[2,2]);
                            end
                            %   Reflect the y-velocity:
                            tempVel(2) = -abs(tempVel(2));
                            %   Move the photon by one step:
                            tempPos(2) = geometry(2,2) - photonStep;
                        end
                    end
                %   If the photon hits the front side of the LSC:
                elseif tempPos(2) <= geometry(2,1) 
                    %   If using edge-lined PV cells and at least four
                    %   cells:
                    if lscCellEdgeLinedBool && lscCellNum >= 4
                        %   Calculate current polar angle (degrees) (+1 for
                        %   index):
                        polarAngleTemp_deg = floor(180/pi * acos(abs(   ...
                        tempVel(3)))) + 1; 
                        %   If PV cell doesn't reflect photon:
                        if rand > reflect_lscCell(dataWavelengthIndex,  ...
                        polarAngleTemp_deg) && rand > fractionCellCovered
                            %   If exciton is collected:
                            if rand < IQE_lscCell(dataWavelengthIndex,  ...
                            polarAngleTemp_deg) 
                                %   Record the position:
                                collectPhotonOrigin_lscCell(xPos,yPos,:)...
                                = tempPos; 
                                %   Record the original wavelength:
                                collectPhotonWavelength_lscCell(xPos,   ...
                                yPos) = simWavelengthIndex; 
                                %   Calculate short circuit current:
                                shortCircuitCurrent_lscCell(xPos, yPos) ...
                                = outputCurrentIntegrator(              ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, cosineFactor,       ...
                                gridSize, incidentLightSpectrumAmps,    ...
                                incidentLightSpectrumWavelength);
                                %   Photon is terminated:
                                done=true; 
                                %   Break from the while loop:
                                break;
                            %   Else is non-radiatively recombined:
                            else
                                %   Add to photons lost (9=lsc cell loss):
                                numPhotonsLost(9) = numPhotonsLost(9)+1;
                                %   Photon is terminated:
                                done = true;
                                %   Break from the while loop:
                                break;   
                            end
                        %   Else the photon is reflected from LSC cell:
                        else
                            %   Reflect the y-velocity:
                            tempVel(2) = abs(tempVel(2));
                            %   Move the photon by one step:
                            tempPos(2) = geometry(2,1) + photonStep;
                        end
                    %   Else we don't have a PV cell at the edge: 
                    else
                        %   Add one to the number of edge bounces:
                        numLSCEdgeBounces(xPos,yPos) =                  ...
                        numLSCEdgeBounces(xPos,yPos) + 1;
                        %   If the photon is not reflected:
                        if rand > wgEdgeReflect
                            %   Add one to the photonsLost variable:
                            numPhotonsLost(6) = numPhotonsLost(6) + 1;
                            %   The photon is lost and terminated:
                            done=true;
                            %   Now break from the while loop:
                            break;
                        %   Else the photon is reflected or scattered:   
                        else
                            %   If the photon is scattered:
                            if rand < wgEdgeScatter
                                %   Scatter the photon by the waveguide
                                %   edge:
                                [tempVel, photonPolarization] =         ...
                                backside_scatter();
                                %   Shift the temporary velocity:
                                tempVel = circshift(tempVel,[2,2]);
                            end
                            %   Reflect the y-velocity:
                            tempVel(2) = abs(tempVel(2));
                            %   Move the photon by one step:
                            tempPos(2) = geometry(2,1) + photonStep;
                        end
                    end
                end
    
     
                %   CHECK FOR PHOTON MATERIALS' INTERFACE INTERACTIONS.
                %----------------------------------------------------------
                %   Calculate temp polar angle (wrt z axis):
                polarAngleTemp = acos(abs(tempVel(3)));
                %   Calculate current polar angle (degrees) (+1 for index):
                polarAngleTemp_deg = floor(polarAngleTemp*180/pi) + 1;
                %   If the photon goes from Glass to Polymer:
                if (tempPos(3) > geometry(3,4)) &&                      ...
                    (oldPos(3) < geometry(3,4)) 
                    %   Change the photon velocity given the change of
                    %   refractive index:
                    tempVel = refract( interface(nGlass,nPolymer,       ...
                    polarAngleTemp), photonPolarization, tempVel);
                    %   Update the position of the photon's z-direction:
                    tempPos(3) = geometry(3,4) + photonStep*tempVel(3);
                %   If the photon goes from the Polymer into Air:
                elseif (tempPos(3) > geometry(3,5)) &&                  ...
                        (oldPos(3) < geometry(3,5)) 
                    %   Change the photon velocity given the change of
                    %   refractive index:
                    tempVel = refract(interface(nPolymer,nAir,          ...
                    polarAngleTemp), photonPolarization, tempVel);
                    %   Update the position of the photon's z-direction:
                    tempPos(3) = geometry(3,5) + photonStep*tempVel(3);
                    %   If the photon reflects at the Polymer's surface:
                    if tempPos(3) < geometry(3,5)
                        %   Add one to the waveguide number of bounces:
                        numWgModeBounces(xPos,yPos) =                   ...
                        numWgModeBounces(xPos,yPos) + 1; 
                    end
                %   If the photon is travelling in the top Air of the LSC
                %   device:
                elseif tempPos(3) > geometry(3,6) 
                    %   If the simulation uses a top filter:
                    if topFilterBool
                        %   Define the s-polarization component of the
                        %   photon:
                        s_part = cos(photonPolarization)^2; 
                        %   Define the p-polarization component of the
                        %   photon:
                        p_part = sin(photonPolarization)^2;
                        %	If the photon reflects off of the filter:
                        if rand < (s_part * reflectFilterTop_sPol(      ...
                        dataWavelengthIndex, polarAngleTemp_deg) +      ...
                        p_part * reflectFilterTop_pPol(                 ...
                        dataWavelengthIndex, polarAngleTemp_deg))
                            %   Update the z-component of the velocity to
                            %   reflect downward:
                            tempVel(3) = -abs(tempVel(3));
                            %   Update the z-component of the position of
                            %   the photon:
                            tempPos(3) = geometry(3,6) + photonStep *   ...
                            tempVel(3);
                            %   Add one to the number of photon bounces off
                            %   of the DBR:
                            numFilterBounces(xPos,yPos)                 ...
                            = numFilterBounces(xPos,yPos) + 1;
                        %   Else the photon passes through the filter:
                        else
                            %   Add one to the photonsLost variable:
                            numPhotonsLost(7) = numPhotonsLost(7) + 1;
                            %   The photon is lost and terminated:
                            done = true;
                            %   Now break from the while loop:
                            break;
                        end
                    %   Else there is no filter at all to stop the photon:
                    else
                        %   Add one to the photonsLost variable:
                        numPhotonsLost(7) = numPhotonsLost(7) + 1;
                        %   The photon is lost and terminated:
                        done=true;
                        %   Now break from the while loop:
                        break;
                    end
                %   If the photon goes from the top Air to the Polymer:
                elseif tempPos(3) < geometry(3,5) &&                    ...
                        oldPos(3) >= geometry(3,5) 
                    %   Change the photon velocity given the change of
                    %   refractive index:
                    tempVel = refract(interface(nAir,nPolymer,          ...
                    polarAngleTemp), photonPolarization, tempVel);
                    %   Update the position of the photon's z-direction:
                    tempPos(3) = geometry(3,5) + photonStep*tempVel(3);
                %   If the photon goes from the polymer to the glass:
                elseif tempPos(3) < geometry(3,4) &&                    ...
                        oldPos(3) >= geometry(3,4) 
                    %   Change the photon velocity given the change of
                    %   refractive index:
                    tempVel = refract(interface(nPolymer, nGlass,       ...
                    polarAngleTemp), photonPolarization, tempVel);
                    %   Update the position of the photon's z-direction:
                    tempPos(3) = geometry(3,4) + photonStep*tempVel(3);
                %   If the photon goes from glass to the bottom air:
                elseif tempPos(3) < geometry(3,3) &&                    ...
                        oldPos(3) >= geometry(3,3) 
                    tempVel = refract(interface(nGlass,nAir,            ...
                        polarAngleTemp), photonPolarization, tempVel);
                    tempPos(3) = geometry(3,3) + photonStep*tempVel(3);
                    % want to know how many times the photon
                    % reflects off the waveguide surface
                    if tempPos(3) > geometry(3,3)
                        numWgModeBounces(xPos,yPos) =                   ...
                        numWgModeBounces(xPos,yPos) + 1; 
                    end
                %   If the photon goes from the bottom air gap to the
                %   bottom glass superstrate:
                elseif tempPos(3) < geometry(3,2) &&                    ...
                       oldPos(3) >= geometry(3,2) 
                   tempVel = refract(interface(nAir,nGlass,             ...
                   polarAngleTemp), photonPolarization, tempVel);
                   tempPos(3) = geometry(3,2) + photonStep*tempVel(3);
                %   If the photon is travelling in the bottom glass
                %   superstrate of the LSC device:
                elseif tempPos(3) < geometry(3,2)
                    %   If the simulation uses a bottom filter:
                    if botFilterBool
                        %   Define the s-polarization component of the
                        %   photon:
                        s_part = cos(photonPolarization)^2; 
                        %   Define the p-polarization component of the
                        %   photon:
                        p_part = sin(photonPolarization)^2;
                        %	If the photon reflects off of the filter:
                        if rand < (s_part * reflectFilterBottom_sPol(   ...
                        dataWavelengthIndex,polarAngleTemp_deg) +       ...
                        p_part *  reflectFilterBottom_pPol(             ...
                        dataWavelengthIndex, polarAngleTemp_deg)) 
                            %   Update the z-component of the velocity to
                            %   reflect upward:
                            tempVel(3) = abs(tempVel(3));
                            tempPos(3) = geometry(3,2) + photonStep *   ...
                            tempVel(3);
                            %   Add one to the number of photon bounces off
                            %   of the filter:
                            numFilterBounces(xPos,yPos)                 ...
                            = numFilterBounces(xPos,yPos) + 1;
                        %   Else if the photon passes through:
                        elseif rand < (s_part *                         ...
                        transmitFilterBottom_sPol(dataWavelengthIndex,  ...
                        polarAngleTemp_deg)+ p_part *                   ...
                        transmitFilterBottom_pPol(dataWavelengthIndex,  ...
                        polarAngleTemp_deg)) 
                            %   Record the photon's direction:
                            collectPhotonDir_bottomCell(1,xPos,yPos,:) =...
                            tempVel;
                            %   Now convert radians to degrees to for the
                            %   z-incident angle of the photon:
                            polarAngleTemp_deg = floor(180/pi*acos(abs(...
                            tempVel(3))));
                            %   If the photon is not reflected by the Si
                            %   solar cell:
                            if rand > reflect_bottomCell(               ...
                            dataWavelengthIndex, polarAngleTemp_deg+1)
                                %   If the photon is absorbed and e-h pair
                                %   is extracted:
                                if rand < IQE_bottomCell(               ...
                                dataWavelengthIndex,polarAngleTemp_deg+1) 
                                    %   Record the position it hits at:
                                    collectPhotonOrigin_bottomCell(xPos,...
                                    yPos,:) = tempPos; 
                                    %   Record the wavelength it hits at:
                                    collectPhotonWavelength_bottomCell( ...
                                    xPos, yPos) = simWavelengthIndex; 
                                    %   Calculate the short circuit current
                                    %   from this photon (given the cosine
                                    %   factor):
                                    shortCircuitCurrent_bottomCell(     ...
                                    xPos, yPos) =                       ...
                                    outputCurrentIntegrator(            ...
                                    simWavelengthIndex, wavelengthStep, ...
                                    simWavelengthRange, gridSize,       ...
                                    cosineFactor,                       ...
                                    incidentLightSpectrumAmps,          ...
                                    incidentLightSpectrumWavelength);
                                    %   The photon is absorbed and
                                    %   terminated:
                                    done=true; 
                                    %   Now break from the while loop:
                                    break;
                                %   Else the photon is absorbed and
                                %   non-radiatively recombined:
                                else
                                    %   Count the lost photon in
                                    %   non-radiative recombination for
                                    %   Si losses:
                                    numPhotonsLost(10) =                ...
                                    numPhotonsLost(10)+1;
                                    %   Then the photon is lost:
                                    done = true;
                                    %   Now break from the while loop:
                                    break;   
                                end
                            %   Else the photon is reflected from
                            %   the Si cell:
                            else
                                %   Make the z-velocity travel in
                                %   the opposite direction:
                                tempVel(3) = abs(tempVel(3));
                                %   Update the temporary position:
                                tempPos(3) = geometry(3,2) +            ...
                                             photonStep*tempVel(3);
                            end
                        %   Else the photon is lost due to absorption
                        %   of the bottom filter:
                        else
                            %   Count the lost photon in bottom filter
                            %   absorption:
                            numPhotonsLost(8) = numPhotonsLost(8)+1;
                            %   Then the photon is lost:
                            done = true;
                            %   Now break from the while loop:
                            break;   
                        end
                    %   If there is no bottom filter, then the photon
                    %   travels through to the bottom cell directly
                    else
                        %   Record the photon's direction:
                        collectPhotonDir_bottomCell(1,xPos,yPos,:) =    ...
                        tempVel;
                        %   Now convert radians to degrees to
                        %   for the z-incident angle of the
                        %   photon:
                        polarAngleTemp_deg = floor(180/pi*acos(abs(     ...
                        tempVel(3))));
                        %   If the photon is not reflected by the
                        %   Si solar cell:
                        if rand > reflect_bottomCell(                   ...
                        dataWavelengthIndex, polarAngleTemp_deg+1)
                            %   If the photon is absorbed and e-h pair is
                            %   extracted:
                            if rand < IQE_bottomCell(                   ...
                            dataWavelengthIndex, polarAngleTemp_deg+1) 
                                %   Record the position it hits at:
                                collectPhotonOrigin_bottomCell(xPos,    ...
                                yPos,:) = tempPos; 
                                %   Record the wavelength it hits at:
                                collectPhotonWavelength_bottomCell(     ...
                                xPos, yPos) = simWavelengthIndex; 
                                %   Calculate the short circuit current
                                %   from this photon (given the cosine
                                %   factor):
                                shortCircuitCurrent_bottomCell(         ...
                                xPos, yPos) =                           ...
                                outputCurrentIntegrator(                ...
                                simWavelengthIndex, wavelengthStep,     ...
                                simWavelengthRange, gridSize,           ...
                                cosineFactor, incidentLightSpectrumAmps,...
                                incidentLightSpectrumWavelength);
                                %   The photon is absorbed and terminated:
                                done=true; 
                                %   Now break from the while loop:
                                break;
                            %   Else the photon is absorbed and
                            %   non-radiatively recombined:
                            else
                                %   Count the lost photon in non-radiative
                                %   recombination for Si losses:
                                numPhotonsLost(10) = numPhotonsLost(10)+1;
                                %   Then the photon is lost:
                                done = true;
                                %   Now break from the while
                                %   loop:
                                break;   
                            end
                        %   Else the photon is reflected from
                        %   the Si cell:
                        else
                            %   Make the z-velocity travel in
                            %   the opposite direction:
                            tempVel(3) = abs(tempVel(3));
                            %   Update the temporary position:
                            tempPos(3) = geometry(3,2) +                ...
                                         photonStep*tempVel(3);
                        end
                    end
                %   If the photon goes from the bottom glass
                %   superstrate into the bottom air gap:
                elseif tempPos(3) > geometry(3,2) &&                    ...
                        oldPos(3) <= geometry(3,2)
                    %   Change the photon velocity given the change
                    %   of refractive index:
                    tempVel = refract(interface(nGlass, nAir,           ...
                    polarAngleTemp), photonPolarization, tempVel);
                    %   Update the position of the photon's
                    %   z-direction:
                    tempPos(3) = geometry(3,2) + photonStep*tempVel(3);
                %   If the photon goes from the bottom air into the
                %   glass:
                elseif tempPos(3) > geometry(3,3) &&                    ...
                        oldPos(3) <= geometry(3,3) 
                    %   Change the photon velocity given the change
                    %   of refractive index:
                    tempVel = refract(interface(nAir,nGlass,            ...
                        polarAngleTemp), photonPolarization, tempVel);
                    %   Update the position of the photon's
                    %   z-direction:
                    tempPos(3) = geometry(3,3) + photonStep*tempVel(3);
                end
            end
        end
    end
    
    %   ADD UP COLLECTED CURRENTS AND INCIDENT POWER.
    %----------------------------------------------------------------------
    %   Now, add up the collected current by the lsc Cell:
    shortCircuitCurrent_lscCell = squeeze(sum(sum(                      ...
    shortCircuitCurrent_lscCell,1),2));
    %   Now, add up the collected current by the bottom Cell:
    shortCircuitCurrent_bottomCell = squeeze(sum(sum(                   ...
    shortCircuitCurrent_bottomCell, 1), 2));
    %   Finally, add up the incident power for this given wavelength:
    incidentPower = squeeze(sum(sum(incidentPower,1),2));    
end
