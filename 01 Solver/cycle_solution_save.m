function [exit_flag, fname] = cycle_solution_save(fc1,fc2,fcy_conf,mode)
%cycle_solution_save Stores solution and cycle configuration in mat_file,
% or cycle configuration only.
% Set mode to 'configuration' to store only cy_conf

fname='';

[FileName,PathName]=uiputfile('*.mat','Save as');

if FileName==0
    % User cancelled
    exit_flag='cancelled';
    return
end

% Split at extension
splt=strsplit(FileName,'.');

Name=splt{1};
Ext=splt{end};

try
    if strcmp(mode,'configuration')
        filename=[PathName,Name,'.conf.',Ext];
        
        save(filename,'fcy_conf');
        
        fname=[Name,'.conf.',Ext];
    else
        filename=[PathName,Name,'.sol.',Ext];
        
        save(filename,'fc1','fc2','fcy_conf');
        
        fname=[Name,'.sol.',Ext];
    end
    
    exit_flag='success';    
    
catch
    errordlg('Selected folder or filename invalid',['Something went wrong when saving the file. ',...
        'Please try again, change the filename.']);
    
    exit_flag='fail';
end

end

