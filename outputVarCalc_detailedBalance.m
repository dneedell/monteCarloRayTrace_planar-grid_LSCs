%
%   FILE NAME:
%       outputVarCalc_detailedBalance.m
%
%   FILE PURPOSE:
%       To calculate, given the results of the Monte Carlo ray-trace
%       function, the relevant output data of interest for the LSC device,
%       where we input the bandgap energy of the PV cell used to output
%       these data.
%-------------------------------------------------------------------------

function [collectedInGaP_Wavelength, collectedSi_Wavelength,            ...
          collectedInGaP, collectedSi,                                  ...
          IscTotal_InGaP, IscTotal_Si,                                  ...
          JscTotal_LSC, JscTotal_Si,                                    ...  
          powerTotalIn, Voc_LSC, Voc_Si,                                ...
          FF_LSC, FF_Si,                                                ...
          Power_LSC, Power_Si, powerTotalOut,                           ...
          efficiencyDevice]                                             ...
                                                                        ...
                    = outputVarCalc_detailedBalance(                    ...
                                     photonWavelengthInGaP,             ...
                                     photonWavelengthSi,                ...
                                     shortCircuitCurrent_InGaP,         ...
                                     shortCircuitCurrent_Si,            ...
                                     numSimWavelength, illuminationArea,...
                                     incidentPower, geometricGain,      ...
                                     wavelengthStep, bandgapEnergy,     ...
                                     ERE_LSC)
                                
    %
    %   Let's calculate the short circuit current for both the InGaP
    %   Cell and the Si cell with no filter consideration:
    %   
    
        %
        %   First, we need to re-distribute the photons collected by both
        %   the InGaP and Si cells to match simulation - since the QD's
        %   cause the energy down-shift:
        %
        
            %   First, we need to round the wavelengths of the photons
            %   collected by the InGaP to match the simulated spectrum:
            photonWavelengthInGaP = roundn(photonWavelengthInGaP,1);
            
            %   Next, we need to round the wavelengths of the photons
            %   collected by the Si to match the simulated spectrum:
            photonWavelengthSi = roundn(photonWavelengthSi,1);
            
            %   Next, let's update the collected InGaP matrix to account
            %   for this wavelength re-adjustment by first initializing:
            collectedInGaP_Wavelength = zeros(numSimWavelength,         ...
                                   size(photonWavelengthInGaP,2),       ...
                                   size(photonWavelengthInGaP,3));
                               
            %   Next, let's update the collected Si matrix to account
            %   for this wavelength re-adjustment by first initializing:
            collectedSi_Wavelength = zeros(numSimWavelength,            ...
                                size(photonWavelengthSi,2),             ...
                                size(photonWavelengthSi,3));
                            
            %   Next, we want to initialize a count for the photons
            %   collected by the InGaP cell for power calculation:
            collectedInGaP = zeros(numSimWavelength, 1);
            
            %   Finally, initialize a count for the photons collected by
            %   the Si cell for power calculation:
            collectedSi = zeros(numSimWavelength, 1);
                            
            %                
            %   Now, update the collected InGaP and Si matrices with these
            %   photons:
            %
            
                %   Loop through the x points:
                for x = 1:size(photonWavelengthInGaP,2)
                    
                    %   Loop through the y points:
                    for y = 1:size(photonWavelengthInGaP,3)
                        
                        %   Loop through the wavelength indices:
                        for wavelengthIndex = 1:numSimWavelength
                            
                            %   If there was a photon collected by InGaP:
                            if photonWavelengthInGaP(wavelengthIndex,   ...
                                                     x, y) ~= 0
                             
                                %   Then add this photon at it's specific
                                %   wavelength to the collected matrix:
                                collectedInGaP_Wavelength(photonWavelengthInGaP(    ...
                                    wavelengthIndex, x, y)/             ...
                                    wavelengthStep, x, y) =                         ...
                                collectedInGaP_Wavelength(photonWavelengthInGaP(    ...
                                    wavelengthIndex, x, y)/wavelengthStep,          ...
                                     x, y) + 1;
                                
                                %   And add one to the collected count:
                                collectedInGaP(wavelengthIndex) =       ...
                                collectedInGaP(wavelengthIndex) + 1;
                                
                            end
                            
                            %   If there was a photon collected by Si:
                            if photonWavelengthSi(wavelengthIndex,      ...
                                                  x, y) ~= 0
                             
                                %   Then add this photon at it's specific
                                %   wavelength to the collected matrix:
                                collectedSi_Wavelength(photonWavelengthSi(      ...
                                    wavelengthIndex, x, y)/wavelengthStep,      ...
                                     x, y) =                            ...
                                collectedSi_Wavelength(photonWavelengthSi(      ...
                                    wavelengthIndex, x, y)/wavelengthStep,      ...
                                     x, y) + 1;
                                 
                                %   And add one to the collected count:
                                collectedSi(wavelengthIndex) =          ...
                                collectedSi(wavelengthIndex) + 1;
                                
                            end
                            
                        end
                        
                    end
                    
                end
                                    
    %
    %   Next, let's make a vector for each total short circuit values for
    %   both InGaP and Si:
    %
    
        %   Total Short Circuit Values for InGaP (A):
        IscTotal_InGaP = squeeze(sum(shortCircuitCurrent_InGaP,1));
            
        %   Total Short Circuit Values for Si (A):
        IscTotal_Si = squeeze(sum(shortCircuitCurrent_Si,1));
          
    %
    %   Finally, let's calculate the overall device efficiency:
    %
    
        %   The short circuit current density (mA/cm^2) for the InGaP Cell:
        JscTotal_LSC = (IscTotal_InGaP/illuminationArea)/10;
        
        %   The short circuit current density (mA/cm^2) for the Si Cell:
        JscTotal_Si = (IscTotal_Si/illuminationArea)/10;
        
        %
        %   Using the Diode Equation to calculate the open circuit
        %   voltages and Fill Factors:
        %
        
            %
            %   Define some constants used in this section:
            %
            
                %   The ideality factor, which we will assume is one:
                n = 1;
                
                %   The Boltzmann constant in [J][K]^-1:
                kB = 1.38064852*10^(-23);
                
                %   The Boltzmann constant in [eV][K]^-1:
                kBeV = 8.617e-5;
                
                %   Approximate value of Stefan Boltzmann constant
                %   [W][m-2][K-4]:
                s = 5.670e-8;
                
                %   The Temperature of our cell which, we will assume, is
                %   at room temperaure [K]:
                Tc = 300;
                                
                %   The charge of an electron:
                q = 1.602176*10^(-19);
                
                %   Define the integral lower bound for the embedded
                %   micro-cell:
                xgMicroCell = (bandgapEnergy)/(kBeV * Tc);
                
                %   Define the integral lower bound for the Si subcell:
                xgSi = (1.1)/(kBeV * Tc);
                
                %   Define the integrand function in the dark current
                %   formula radiative limit:
                darkCurrentIntegrand = @(x) x.^2 ./ (exp(x) - 1);
                
                %   Now calculate the InGaP dark current in its radiative
                %   limit (in mA/cm2):
                J0_LSC = (q * 15 * s * Tc^3)/(kB * pi^4) *              ...
                            integral(darkCurrentIntegrand,xgMicroCell,Inf);
                
                %   The dark current calculated by the bandgap of our Si
                %   Cell (in mA/cm2):
                J0_Si = (q * 15 * s * Tc^3)/(kB * pi^4) *               ...
                            integral(darkCurrentIntegrand,xgSi,Inf);
                        
            %   The open circuit voltage (V) for the embedded cell, to also
            %   include the non-radiative Voc detriment and a factor to
            %   influence that factor:
            Voc_LSC = (n*kB*Tc)/(q) * log((JscTotal_LSC)                ...
                          / J0_LSC +1) + (n*kB*Tc)/(q) *                ...
                          log(ERE_LSC);%log(1/(10 + (1/JscTotal_LSC)));
                      
            %   A Dummy Voc (since we aren't really looking at this):
            Voc_Si = (n*kB*Tc)/(q) * log((JscTotal_Si) / J0_Si +1);
            
            %   The ideal Fill Factor for the embedded cell:
            FF_LSC = ((q*Voc_LSC)/(n*kB*Tc)-log((q*Voc_LSC)/            ...
                (n*kB*Tc) + 0.72)) / ((q*Voc_LSC)/(n*kB*Tc) + 1);
             
            %   The ideal Fill Factor for the Si Cell:
            FF_Si = ((q*Voc_Si)/(n*kB*Tc)-log((q*Voc_Si)/               ...
                (n*kB*Tc) + 0.72)) / ((q*Voc_Si)/(n*kB*Tc) + 1);
            
        %   The total power for the InGaP Cell:
        Power_LSC = JscTotal_LSC * Voc_LSC * FF_LSC;
        
        %   The total power for the Si Cell:
        Power_Si = JscTotal_Si * Voc_Si * FF_Si;
        
        %   The total combined power from the embedded cell:
        powerTotalOut = Power_LSC;
        
        %   Calculate the total incident power:
        powerTotalIn = (squeeze(sum(incidentPower,1))/illuminationArea)/10;
        
        %   The total efficiency of the device:
        efficiencyDevice = powerTotalOut;
end
                        
