%
%   FILE NAME:
%       outputVarCalc.m
%
%   FILE PURPOSE:
%       To calculate, given the results of the Monte Carlo ray-trace
%       function, the relevant output data of interest for the LSC device.
%-------------------------------------------------------------------------

function [collectedInGaP_Wavelength, collectedSi_Wavelength,           ...
          collectedInGaP, collectedSi,                                 ...
          IscTotal_InGaP, IscTotal_Si,                                 ...
          JscTotal_InGaP, JscTotal_Si,                                 ...  
          powerTotalIn, Voc_InGaP, Voc_Si,                             ...
          FF_InGaP, FF_Si,                                             ...
          Power_InGaP, Power_Si, powerTotalOut,                        ...
          efficiencyDevice]                                            ...
                                                                       ...
                    = outputVarCalc(photonWavelengthInGaP,             ...
                                    photonWavelengthSi,                ...
                                    shortCircuitCurrent_InGaP,         ...
                                    shortCircuitCurrent_Si,            ...
                                    numSimWavelength, illuminationArea,...
                                    incidentPower, geometricGain,      ...
                                    wavelengthStep)
                                
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
            collectedInGaP_Wavelength = zeros(numSimWavelength,      ...
                                   size(photonWavelengthInGaP,2),    ...
                                   size(photonWavelengthInGaP,3));
                               
            %   Next, let's update the collected Si matrix to account
            %   for this wavelength re-adjustment by first initializing:
            collectedSi_Wavelength = zeros(numSimWavelength,   ...
                                size(photonWavelengthSi,2),    ...
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
                            if photonWavelengthInGaP(wavelengthIndex, ...
                                                     x, y) ~= 0
                             
                                %   Then add this photon at it's specific
                                %   wavelength to the collected matrix:
                                collectedInGaP_Wavelength(photonWavelengthInGaP(  ...
                                    wavelengthIndex, x, y)/ ...
                                    wavelengthStep, x, y) =                         ...
                                collectedInGaP_Wavelength(photonWavelengthInGaP(  ...
                                    wavelengthIndex, x, y)/wavelengthStep,       ...
                                     x, y) + 1;
                                
                                %   And add one to the collected count:
                                collectedInGaP(wavelengthIndex) =  ...
                                collectedInGaP(wavelengthIndex) + 1;
                                
                            end
                            
                            %   If there was a photon collected by Si:
                            if photonWavelengthSi(wavelengthIndex, ...
                                                  x, y) ~= 0
                             
                                %   Then add this photon at it's specific
                                %   wavelength to the collected matrix:
                                collectedSi_Wavelength(photonWavelengthSi(       ...
                                    wavelengthIndex, x, y)/wavelengthStep,      ...
                                     x, y) =                           ...
                                collectedSi_Wavelength(photonWavelengthSi(       ...
                                    wavelengthIndex, x, y)/wavelengthStep,     ...
                                     x, y) + 1;
                                 
                                %   And add one to the collected count:
                                collectedSi(wavelengthIndex) =  ...
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
        JscTotal_InGaP = (IscTotal_InGaP/illuminationArea)/10;
        
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
                
                %   Define the integral lower bound for the InGaP
                %   micro-cell:
                %xgMicroCell = (1.909)/(kBeV * Tc);
                
                %   Define the integral lower bound for the GaAs
                %   micro-cell:
                xgMicroCell = (1.424)/(kBeV * Tc);
                
                %   Define the integral lower bound for the Si micro-cell:
                %xgMicroCell = (1.1)/(kBeV * Tc);
                
                %   Define the integral lower bound for the InGaAs
                %   micro-cell:
                %xgMicroCell = (1.23)/(kBeV * Tc);
                
                %   Define the integral lower bound for the Si subcell:
                xgSi = (1.1)/(kBeV * Tc);
                
                %   Define the integrand function in the dark current
                %   formula radiative limit:
                darkCurrentIntegrand = @(x) x.^2 ./ (exp(x) - 1);
                
                %   Now calculate the InGaP dark current in its radiative
                %   limit (in mA/cm2):
                J0_InGaP = (q * 15 * s * Tc^3)/(kB * pi^4) * ...
                            integral(darkCurrentIntegrand,xgMicroCell,Inf);
                
                %   The dark current calculated by the bandgap of our Si
                %   Cell (in mA/cm2):
                J0_Si = (q * 15 * s * Tc^3)/(kB * pi^4) * ...
                            integral(darkCurrentIntegrand,xgSi,Inf);
                
            %   The open circuit voltage (V) for the InGaP Cell, (n * k *
            %   T)/q * ln( Jsc/J0 + 1), where J0 is calculated by the
            %   minimum of the diode saturation current (see Lab Notebook
            %   for details!), and also include the non-radiative Voc
            %   detriment:
            Voc_InGaP = (n*kB*Tc)/(q) * log((JscTotal_InGaP)...
                          / J0_InGaP +1) + (n*kB*Tc)/(q) * ...
                          log(1/(11 + (4/JscTotal_InGaP)));
                      
            %   FOR POWER WINDOW CONCEPT ONLY USING SI MICRO-CELLS:
            %Voc_InGaP = (n*kB*Tc)/(q) * log((JscTotal_InGaP)...
            %              / J0_InGaP +1) + (n*kB*Tc)/(q) * ...
            %              log(.0057/(1 + (4/JscTotal_InGaP)));
                      
            %   The open circuit voltage (V) for the Si Cell, (n * k *
            %   T)/q * ln( Jsc/J0 + 1), where J0 is calculated by the
            %   minimum of the diode saturation current (see Lab Notebook
            %   for details!), and also include the non-radiative Voc
            %   detriment:
            Voc_Si = (n*kB*Tc)/(q) * log((JscTotal_Si)...
                          / J0_Si +1) + (n*kB*Tc)/(q) * ...
                          log(.0057/(1 + (4/JscTotal_Si)));
           
            %   Now we will calculate the Fill factor for both InGaP and Si
            %   cells with an empirical model, where we have determined the
            %   series and shunt resistances of each the Si and InGaP cells
            %   from experimental matching of Jinko's PERC Si and NREL's
            %   InGaP:
            
            %calculate the normalized v_oc for InGaP and Si
            v_oc_InGaP = (q*Voc_InGaP)/(n*kB*Tc);
            v_oc_Si = (q*Voc_Si)/(n*kB*Tc);
            
%             %%%%%%EMPIRICAL FORMULA%%%%%%%
%             %   The ideal Fill Factor for the InGaP Cell:
              %FF0_InGaP = ((q*Voc_InGaP)/(n*kB*Tc)-log((q*Voc_InGaP)/(n*kB*Tc) ...
              %            + 0.72)) / ((q*Voc_InGaP)/(n*kB*Tc) + 1);
%             
%             %   The ideal Fill Factor for the Si Cell:
%             FF0_Si = ((q*Voc_Si)/(n*kB*Tc)-log((q*Voc_Si)/(n*kB*Tc) + 0.72)) ...
%                         / ((q*Voc_Si)/(n*kB*Tc) + 1);
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%Fill Factor using Martin Green's Approach%%%%%
            %InGaP
            z0_InGaP = exp(v_oc_InGaP+1);
            W_InGaP = lambertw(z0_InGaP);
            f0_InGaP = (1-exp(-v_oc_InGaP))^(-1);
            FF0_InGaP = (W_InGaP -1)^2*f0_InGaP/(v_oc_InGaP*W_InGaP );
            IF0_InGaP = (W_InGaP-1)*f0_InGaP/W_InGaP;
            VF0_InGaP = (W_InGaP-1)/v_oc_InGaP;
            
            %Si
            z0_Si = exp(v_oc_Si+1);
            W_Si = lambertw(z0_Si);
            f0_Si = (1-exp(-v_oc_Si))^(-1);
            FF0_Si = (W_Si -1)^2*f0_Si/(v_oc_Si*W_Si);
            IF0_Si = (W_Si-1)*f0_Si/W_Si;
            VF0_Si = (W_Si-1)/v_oc_Si;
            
            %   Now let's define the series resistances for both cells:
            %   (units of Ohms cm2)
            Rs_InGaP = 0.8;
            %FOR POWER WINDOW TESTING ONLY:
            %Rs_InGaP = 1.23;
            Rs_Si = 1.23;
            
            %   Now define the shunt resistances for both cells: (units of
            %   Ohms cm2)
            Rsh_InGaP = 12500;
            %FOR POWER WINDOW TESTING ONLY:
            %Rsh_InGaP = 2000;
            Rsh_Si = 2000;
            
            %   Now calculate the characteristic resistance for both cells:
            %   (units of Ohms cm2)
            Rch_InGaP = Voc_InGaP / (JscTotal_InGaP * 10^(-3));
            Rch_Si = Voc_Si / (JscTotal_Si * 10^(-3));
            
            %   Now define the unitless series and shunt resistances for
            %   each cell:
            rs_InGaP = Rs_InGaP/Rch_InGaP;
            rs_Si = Rs_Si/Rch_Si;
            rsh_InGaP = Rsh_InGaP/Rch_InGaP;
            rsh_Si = Rsh_Si/Rch_Si;
            
            fs_InGaP = (1-exp(-v_oc_InGaP*(1-rs_InGaP)))^(-1);
            fs_Si = (1-exp(-v_oc_Si*(1-rs_Si)))^(-1);
            
           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%update with M Green approach %%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            FF_InGaP = (FF0_InGaP*(fs_InGaP/f0_InGaP)* ...
            (1 - (IF0_InGaP/VF0_InGaP)*rs_InGaP - ...
            (VF0_InGaP/IF0_InGaP)/rsh_InGaP + (rs_InGaP/rsh_InGaP)*...
            (2-min((IF0_InGaP/VF0_InGaP)*rs_InGaP,(VF0_InGaP/IF0_InGaP)/rsh_InGaP))))/ ...
            (1-1/(v_oc_InGaP*rsh_InGaP));
            
            FF_Si = (FF0_Si*(fs_Si/f0_Si)* ...
            (1 - (IF0_Si/VF0_Si)*rs_Si - ...
            (VF0_Si/IF0_Si)/rsh_Si + (rs_Si/rsh_Si)*...
            (2-min((IF0_Si/VF0_Si)*rs_Si,(VF0_Si/IF0_Si)/rsh_Si))))/ ...
            (1-1/(v_oc_Si*rsh_Si));
            
            
        %   The total power for the InGaP Cell:
        Power_InGaP = JscTotal_InGaP * Voc_InGaP * FF_InGaP;
        
        %   The total power for the Si Cell:
        Power_Si = JscTotal_Si * Voc_Si * FF_Si;
        
        %   The total combined power from the two cells:
        %powerTotalOut = Power_InGaP + Power_Si;
        powerTotalOut = Power_InGaP;
        
        %   Calculate the total incident power:
        powerTotalIn = (squeeze(sum(incidentPower,1))/illuminationArea)/10;
        
        %   The total efficiency of the device:
        efficiencyDevice = powerTotalOut;
                                            
end
