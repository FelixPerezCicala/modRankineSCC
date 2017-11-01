function [exit_flag,c1,c2,cy_conf,FileName] = cycle_load_solution(mode)
%cycle_load_solution Load either a solution or a cy_conf

c1=[];
c2=[];
cy_conf=[];

if strcmp(mode,'configuration')
    % User wants to load a confituration cy_conf file    
    [FileName,PathName] = uigetfile('*.mat',['Open cycle',...
        ' configuration file']);
    
    if FileName==0
        % User cancelled or hit the X button
        exit_flag='user_cancelled';
    else
        % User selected mat file
        try
            filename = [PathName,'\',FileName];
            myVars = {'fcy_conf'};
            S = load(filename,myVars{:});
            
            cy_conf=S.fcy_conf;
            
            exit_flag='success';
        catch
            
            errordlg(['The selected .mat file appears to be either invalid or',...
                ' corrupt. Try again with a valid file'],'File invalid or corrupt');
            
            exit_flag='fail';
        end
    end
    
else
    % User wants to load a solution file    
    [FileName,PathName] = uigetfile('*.mat',['Open cycle',...
        ' solution file']);
    
    if FileName==0
        % User cancelled or hit the X button
        exit_flag='user_cancelled';
    else
        % User selected mat file
        try
            filename = [PathName,'\',FileName];
            myVars = {'fc1','fc2','fcy_conf'};
            S = load(filename,myVars{:});
            
            c1=S.fc1;
            c2=S.fc2;
            cy_conf=S.fcy_conf;
            
            exit_flag='success';
        catch
            errordlg(['The selected .mat file appears to be either invalid or',...
                ' corrupt. Try again with a valid file'],'File invalid or corrupt');
            
            exit_flag='fail';
        end
    end
    
end
end

