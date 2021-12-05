%
%   FILE NAME:
%       emailNotification.m
%
%   FILE DESCRIPTION:
%       This function will trigger once the entire testing loop has
%       terminated, and it will send an email alerting you to the status
%       once that is the case.
%
%   FILE PARAMETER NOTES:
%       This function only requires 2 input parameters which are:
%       
%       1. computerName: the name of the computer the simulation is running
%          on (i.e. 'aeolus2').
%       2. simulationName: the name of the current simulation running
%       3. emailName: the email address for the intended recipient.
%   
%-------------------------------------------------------------------------

function emailNotification(computerName,simulationName,emailName)

    setpref('Internet','E_mail','monteCarloSimulationStatus@gmail.com');
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username','monteCarloSimulationStatus@gmail.com');
    setpref('Internet','SMTP_Password','crep8ZES.youk9psof');
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    sendmail(emailName,[num2str(simulationName) ' has completed on ' num2str(computerName)]);





